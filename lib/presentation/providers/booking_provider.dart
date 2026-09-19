import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/error/seat_hold_exceptions.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_quote.dart';
import '../../domain/entities/seat_realtime_state.dart';
import '../../domain/entities/showtime_seat.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/seat_realtime_repository.dart';
import '../../domain/repositories/showtime_repository.dart';

enum PosBookingPhase {
  idle,
  loadingSeats,
  selectingLocal,
  holding,
  held,
  creatingPendingBooking,
  pendingPayment,
  confirmingCash,
  paid,
  retryableError,
  conflict,
  expired,
  reviewRequired,
}

class BookingProvider extends ChangeNotifier {
  static const int maxSeatsPerHold = 8;

  final BookingRepository bookingRepository;
  final ShowtimeRepository showtimeRepository;
  final SeatRealtimeRepository seatRealtimeRepository;
  final DateTime Function() _nowUtc;

  BookingProvider({
    required this.bookingRepository,
    required this.showtimeRepository,
    required this.seatRealtimeRepository,
    DateTime Function()? nowUtc,
  }) : _nowUtc = nowUtc ?? (() => DateTime.now().toUtc());

  List<ShowtimeSeat> _seats = [];
  final List<String> _selectedSeatIds = [];
  bool _isLoading = false;
  String? _errorMessage;
  BookingQuote? _currentQuote;
  Booking? _pendingBooking;
  String? _currentHoldGroupId;
  String? _cashIdempotencyKey;
  String? _cancellationIdempotencyKey;
  String? _activeShowtimeId;
  DateTime? _holdExpiresAtUtc;
  Duration _serverClockOffset = Duration.zero;
  Timer? _holdExpiryTimer;
  int _quoteRequestVersion = 0;
  int _seatStateVersion = 0;
  int _flowGeneration = 0;
  bool _installingSnapshot = false;
  bool _resyncing = false;
  final List<SeatStateEvent> _buffer = [];
  final Set<String> _eventIds = {};
  final Set<String> _pendingOwnedSeatIds = {};
  StreamSubscription<SeatStateEvent>? _eventSubscription;
  StreamSubscription<SeatRealtimeConnectionState>? _stateSubscription;

  PosBookingPhase phase = PosBookingPhase.idle;
  SeatRealtimeConnectionState realtimeState =
      SeatRealtimeConnectionState.disconnected;

  List<ShowtimeSeat> get seats => List.unmodifiable(_seats);
  List<ShowtimeSeat> get selectedSeats => _seats
      .where((seat) => _selectedSeatIds.contains(seat.seatId))
      .toList(growable: false);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  BookingQuote? get currentQuote => _currentQuote;
  String? get currentHoldGroupId => _currentHoldGroupId;
  DateTime? get holdExpiresAtUtc => _holdExpiresAtUtc;
  Duration get holdRemaining {
    final expiresAt = _holdExpiresAtUtc;
    if (expiresAt == null) return Duration.zero;
    final remaining = expiresAt.difference(_nowUtc().add(_serverClockOffset));
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String get holdRemainingLabel {
    final remaining = holdRemaining;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Booking? get pendingBooking => _pendingBooking;
  bool isSeatSelected(String seatId) => _selectedSeatIds.contains(seatId);

  void clearSelectedSeats() {
    if (_isLoading || phase == PosBookingPhase.pendingPayment) return;
    _selectedSeatIds.clear();
    _currentQuote = null;
    notifyListeners();
  }

  void resetAfterPaidSale() {
    if (phase != PosBookingPhase.paid) return;
    _selectedSeatIds.clear();
    _currentQuote = null;
    _pendingBooking = null;
    _currentHoldGroupId = null;
    _clearHoldExpiry();
    _cashIdempotencyKey = null;
    _cancellationIdempotencyKey = null;
    _errorMessage = null;
    phase = PosBookingPhase.selectingLocal;
    notifyListeners();
  }

  bool toggleSeat(ShowtimeSeat seat) {
    if (_isLoading ||
        _currentHoldGroupId != null ||
        phase == PosBookingPhase.pendingPayment ||
        phase == PosBookingPhase.confirmingCash ||
        phase == PosBookingPhase.paid) {
      return false;
    }
    if (seat.status != 'Available' && !seat.heldByCurrentUser) return false;
    if (_selectedSeatIds.contains(seat.seatId)) {
      _selectedSeatIds.remove(seat.seatId);
    } else {
      if (_selectedSeatIds.length >= maxSeatsPerHold) {
        _errorMessage = 'Mỗi lượt chỉ được giữ tối đa 8 ghế.';
        notifyListeners();
        return false;
      }
      _selectedSeatIds.add(seat.seatId);
    }
    _errorMessage = null;
    phase = PosBookingPhase.selectingLocal;
    notifyListeners();
    return true;
  }

  Future<void> fetchSeatsForShowtime(String showtimeId) async {
    final generation = ++_flowGeneration;
    _isLoading = true;
    phase = PosBookingPhase.loadingSeats;
    _errorMessage = null;
    notifyListeners();
    try {
      await _startRealtime(showtimeId, generation);
      if (generation != _flowGeneration) return;
      _isLoading = false;
      phase = PosBookingPhase.selectingLocal;
      notifyListeners();
    } catch (error) {
      if (generation != _flowGeneration) return;
      _isLoading = false;
      phase = PosBookingPhase.retryableError;
      _errorMessage = _parseError(error);
      notifyListeners();
    }
  }

  Future<void> _startRealtime(String showtimeId, int generation) async {
    if (_activeShowtimeId != showtimeId) {
      final prior = _activeShowtimeId;
      if (prior != null) await seatRealtimeRepository.disconnect(prior);
      await _eventSubscription?.cancel();
      await _stateSubscription?.cancel();
      if (generation != _flowGeneration) return;
      _activeShowtimeId = showtimeId;
      _currentHoldGroupId = null;
      _clearHoldExpiry();
      _pendingBooking = null;
      _cashIdempotencyKey = null;
      _cancellationIdempotencyKey = null;
      _pendingOwnedSeatIds.clear();
      _eventSubscription = seatRealtimeRepository.events.listen(_handleEvent);
      _stateSubscription = seatRealtimeRepository.connectionStates.listen((
        state,
      ) {
        realtimeState = state;
        if (state == SeatRealtimeConnectionState.connected &&
            _seatStateVersion > 0 &&
            _activeShowtimeId != null) {
          _resync(_activeShowtimeId!, _flowGeneration);
        }
        notifyListeners();
      });
      await seatRealtimeRepository.connect(showtimeId);
    }
    await _installSnapshot(showtimeId, generation);
  }

  Future<void> _installSnapshot(String showtimeId, int generation) async {
    _installingSnapshot = true;
    late List<ShowtimeSeat> loaded;
    var version = 0;
    try {
      final snapshot = await seatRealtimeRepository.getSnapshot(showtimeId);
      loaded = snapshot.seats;
      version = snapshot.version;
    } catch (_) {
      loaded = await showtimeRepository.getSeatsForShowtime(showtimeId);
      realtimeState = SeatRealtimeConnectionState.disconnected;
    }
    if (generation != _flowGeneration || showtimeId != _activeShowtimeId) {
      return;
    }
    _seats = loaded;
    _seatStateVersion = version;
    final selectableIds = _seats
        .where((seat) => seat.status == 'Available' || seat.heldByCurrentUser)
        .map((seat) => seat.seatId)
        .toSet();
    final before = _selectedSeatIds.length;
    _selectedSeatIds.removeWhere((id) => !selectableIds.contains(id));
    if (_selectedSeatIds.length < before) {
      _errorMessage = 'A selected seat is no longer available.';
    }
    _installingSnapshot = false;
    _drain();
  }

  Future<bool> holdSeats(String showtimeId, List<String> seatIds) async {
    if (_isLoading || seatIds.isEmpty) return false;
    final generation = _flowGeneration;
    _isLoading = true;
    phase = PosBookingPhase.holding;
    _errorMessage = null;
    _pendingOwnedSeatIds.addAll(seatIds);
    notifyListeners();
    try {
      final session = await bookingRepository.holdSeats(
        showtimeId: showtimeId,
        seatIds: seatIds,
      );
      if (generation != _flowGeneration || showtimeId != _activeShowtimeId) {
        return false;
      }
      _currentHoldGroupId = session.holdGroupId;
      _holdExpiresAtUtc = session.expiresAtUtc;
      _serverClockOffset = session.serverTimeUtc.difference(_nowUtc());
      _startHoldExpiryTimer();
      _pendingOwnedSeatIds.clear();
      _isLoading = false;
      phase = PosBookingPhase.held;
      _drain();
      notifyListeners();
      return true;
    } catch (error) {
      _pendingOwnedSeatIds.clear();
      _isLoading = false;
      await _resync(showtimeId, generation);
      if (generation != _flowGeneration || showtimeId != _activeShowtimeId) {
        return false;
      }
      if (error is SeatHoldConflict) {
        // The server treats a multi-seat hold as one atomic command. If any
        // seat conflicts, none of the requested seats were held, so do not
        // leave the remaining seats looking like a partially successful hold.
        _selectedSeatIds.clear();
        _currentQuote = null;
      }
      _applySeatHoldError(error);
      notifyListeners();
      return false;
    }
  }

  Future<Booking?> createPendingBooking({
    required String showtimeId,
    required List<String> seatIds,
  }) async {
    final holdGroupId = _currentHoldGroupId;
    if (_isLoading || holdGroupId == null) return null;
    final generation = _flowGeneration;
    _isLoading = true;
    phase = PosBookingPhase.creatingPendingBooking;
    _errorMessage = null;
    notifyListeners();
    try {
      final booking = await bookingRepository.createBooking(
        showtimeId: showtimeId,
        seatIds: seatIds,
        seatHoldGroupId: holdGroupId,
      );
      if (generation != _flowGeneration || showtimeId != _activeShowtimeId) {
        return null;
      }
      _pendingBooking = booking;
      if (booking.expiredAt != null) {
        _holdExpiresAtUtc = booking.expiredAt!.toUtc();
        _startHoldExpiryTimer();
      }
      _cashIdempotencyKey ??= _newUuidV4();
      _cancellationIdempotencyKey ??= _newUuidV4();
      _isLoading = false;
      phase = PosBookingPhase.pendingPayment;
      notifyListeners();
      return booking;
    } catch (error) {
      _isLoading = false;
      phase = PosBookingPhase.retryableError;
      _errorMessage = _parseError(error);
      notifyListeners();
      return null;
    }
  }

  Future<Booking?> confirmPendingCashPayment() async {
    final booking = _pendingBooking;
    final key = _cashIdempotencyKey;
    if (_isLoading || booking == null || key == null) return null;
    _isLoading = true;
    phase = PosBookingPhase.confirmingCash;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await bookingRepository.confirmPosCash(
        bookingId: booking.id,
        idempotencyKey: key,
      );
      _isLoading = false;
      if (!result.success || result.booking == null) {
        phase = result.paymentState == 'ReviewRequired'
            ? PosBookingPhase.reviewRequired
            : PosBookingPhase.conflict;
        _errorMessage = result.errorCode.isEmpty
            ? 'Payment confirmation was not completed.'
            : result.errorCode;
        notifyListeners();
        return null;
      }
      _pendingBooking = result.booking;
      phase = result.paymentState == 'Paid'
          ? PosBookingPhase.paid
          : PosBookingPhase.reviewRequired;
      notifyListeners();
      return phase == PosBookingPhase.paid ? result.booking : null;
    } catch (error) {
      _isLoading = false;
      phase = PosBookingPhase.retryableError;
      _errorMessage = _parseError(error);
      notifyListeners();
      return null;
    }
  }

  Future<bool> cancelCurrentFlow() async {
    if (_isLoading) return false;
    final booking = _pendingBooking;
    final holdGroupId = _currentHoldGroupId;
    if (booking == null && holdGroupId == null) return true;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (booking != null) {
        final key = _cancellationIdempotencyKey ??= _newUuidV4();
        final result = await bookingRepository.cancelPos(
          bookingId: booking.id,
          idempotencyKey: key,
          reasonCode: 'OperatorCancelled',
        );
        if (!result.success) {
          phase = result.paymentState == 'ReviewRequired'
              ? PosBookingPhase.reviewRequired
              : PosBookingPhase.conflict;
          _errorMessage = result.errorCode;
          return false;
        }
      } else {
        await bookingRepository.releaseHold(holdGroupId!);
      }

      _selectedSeatIds.clear();
      _currentQuote = null;
      _pendingBooking = null;
      _currentHoldGroupId = null;
      _clearHoldExpiry();
      _cashIdempotencyKey = null;
      _cancellationIdempotencyKey = null;
      phase = PosBookingPhase.selectingLocal;
      final showtimeId = _activeShowtimeId;
      if (showtimeId != null) {
        await _resync(showtimeId, _flowGeneration);
      }
      return true;
    } catch (error) {
      phase = PosBookingPhase.retryableError;
      _errorMessage = _parseError(error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> quoteBooking(String showtimeId, List<String> seatIds) async {
    final request = ++_quoteRequestVersion;
    if (seatIds.isEmpty) {
      _currentQuote = null;
      notifyListeners();
      return;
    }
    try {
      final quote = await bookingRepository.quoteBooking(
        showtimeId: showtimeId,
        seatIds: seatIds,
      );
      if (request != _quoteRequestVersion) return;
      _currentQuote = quote;
      notifyListeners();
    } catch (error) {
      if (request != _quoteRequestVersion) return;
      _errorMessage = _parseError(error);
      notifyListeners();
    }
  }

  void _handleEvent(SeatStateEvent event) {
    if (event.showtimeId != _activeShowtimeId ||
        _eventIds.contains(event.eventId)) {
      return;
    }
    if (_currentHoldGroupId == null &&
        event.changes.any(
          (change) => _pendingOwnedSeatIds.contains(change.seatId),
        )) {
      _buffer.add(event);
      return;
    }
    if (_installingSnapshot || event.version > _seatStateVersion + 1) {
      _buffer.add(event);
      if (!_installingSnapshot && _activeShowtimeId != null) {
        _resync(_activeShowtimeId!, _flowGeneration);
      }
      return;
    }
    if (event.version > _seatStateVersion) _applyEvent(event);
  }

  void _applyEvent(SeatStateEvent event) {
    _eventIds.add(event.eventId);
    for (final change in event.changes) {
      final index = _seats.indexWhere((seat) => seat.seatId == change.seatId);
      if (index < 0) continue;
      final owned = change.holdGroupId == _currentHoldGroupId;
      _seats[index] = _seats[index].copyWith(
        status: change.status,
        heldByCurrentUser: owned,
        expiresAtUtc: change.expiresAtUtc,
      );
      if ((change.status == 'Held' && !owned) || change.status == 'Booked') {
        _selectedSeatIds.remove(change.seatId);
      }
    }
    _seatStateVersion = event.version;
    notifyListeners();
  }

  void _drain() {
    _buffer.sort((left, right) => left.version.compareTo(right.version));
    final pending = List<SeatStateEvent>.from(_buffer);
    _buffer.clear();
    for (final event in pending) {
      if (event.version == _seatStateVersion + 1) {
        _applyEvent(event);
      } else if (event.version > _seatStateVersion + 1) {
        _buffer.add(event);
      }
    }
  }

  Future<void> _resync(String showtimeId, int generation) async {
    if (_resyncing) return;
    _resyncing = true;
    try {
      await _installSnapshot(showtimeId, generation);
    } finally {
      _resyncing = false;
    }
  }

  String _parseError(Object error) =>
      error.toString().replaceAll('Exception: ', '');

  void _applySeatHoldError(Object error) {
    if (error is SeatHoldRateLimited) {
      phase = PosBookingPhase.retryableError;
      _errorMessage = 'Thao tác quá nhanh. Vui lòng chờ một chút rồi thử lại.';
    } else if (error is SeatHoldShowtimeNotBookable) {
      phase = PosBookingPhase.conflict;
      _errorMessage = 'Suất chiếu đã bắt đầu hoặc không còn nhận đặt vé.';
    } else if (error is SeatHoldLimitExceeded) {
      phase = PosBookingPhase.conflict;
      _errorMessage = 'Mỗi lượt chỉ được giữ tối đa 8 ghế.';
    } else if (error is SeatHoldAlreadyBooked) {
      phase = PosBookingPhase.conflict;
      _errorMessage = 'Lượt giữ ghế đã được chuyển thành đơn đặt vé.';
    } else if (error is SeatHoldBookingAlreadyPending) {
      phase = PosBookingPhase.conflict;
      _errorMessage = 'Đã có một đơn chờ thanh toán cho suất chiếu này.';
    } else if (error is SeatHoldUnavailable) {
      phase = PosBookingPhase.expired;
      _errorMessage = 'Lượt giữ ghế không còn hiệu lực. Vui lòng chọn lại.';
    } else if (error is SeatHoldAuthenticationRequired) {
      phase = PosBookingPhase.retryableError;
      _errorMessage = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    } else if (error is SeatHoldTransportFailure) {
      phase = PosBookingPhase.retryableError;
      _errorMessage = error.message;
    } else if (error is SeatHoldConflict) {
      phase = PosBookingPhase.conflict;
      _errorMessage = 'Một hoặc nhiều ghế vừa được người khác giữ.';
    } else {
      phase = PosBookingPhase.retryableError;
      _errorMessage = _parseError(error);
    }
  }

  void _startHoldExpiryTimer() {
    _holdExpiryTimer?.cancel();
    refreshHoldExpiry();
    if (_holdExpiresAtUtc == null || phase == PosBookingPhase.expired) return;
    _holdExpiryTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => refreshHoldExpiry(),
    );
  }

  void refreshHoldExpiry() {
    if (_holdExpiresAtUtc == null) return;
    if (holdRemaining > Duration.zero) {
      notifyListeners();
      return;
    }
    _holdExpiryTimer?.cancel();
    _holdExpiryTimer = null;
    _currentHoldGroupId = null;
    _pendingOwnedSeatIds.clear();
    if (phase != PosBookingPhase.paid) {
      phase = PosBookingPhase.expired;
      _errorMessage = 'Lượt giữ ghế đã hết hạn. Vui lòng giữ lại ghế.';
    }
    notifyListeners();
  }

  void _clearHoldExpiry() {
    _holdExpiryTimer?.cancel();
    _holdExpiryTimer = null;
    _holdExpiresAtUtc = null;
    _serverClockOffset = Duration.zero;
  }

  String _newUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int value) => value.toRadixString(16).padLeft(2, '0');
    final value = bytes.map(hex).join();
    return '${value.substring(0, 8)}-${value.substring(8, 12)}-'
        '${value.substring(12, 16)}-${value.substring(16, 20)}-'
        '${value.substring(20)}';
  }

  @override
  void dispose() {
    _holdExpiryTimer?.cancel();
    _eventSubscription?.cancel();
    _stateSubscription?.cancel();
    final showtimeId = _activeShowtimeId;
    if (showtimeId != null) seatRealtimeRepository.disconnect(showtimeId);
    super.dispose();
  }
}
