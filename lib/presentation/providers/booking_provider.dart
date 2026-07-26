import 'dart:async';

import 'package:flutter/material.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_quote.dart';
import '../../domain/entities/showtime_seat.dart';
import '../../domain/entities/seat_hold_session.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/showtime_repository.dart';

class BookingProvider extends ChangeNotifier {
  final BookingRepository bookingRepository;
  final ShowtimeRepository showtimeRepository;

  List<ShowtimeSeat> _seats = [];
  bool _isLoading = false;
  String? _errorMessage;
  BookingQuote? _currentQuote;
  SeatHoldSession? _holdSession;
  Duration _holdRemaining = Duration.zero;
  Timer? _holdTimer;
  int _quoteRequestVersion = 0;

  BookingProvider({
    required this.bookingRepository,
    required this.showtimeRepository,
  });

  List<ShowtimeSeat> get seats => _seats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  BookingQuote? get currentQuote => _currentQuote;
  Duration get holdRemaining => _holdRemaining;
  bool get hasActiveHold =>
      _holdSession?.isActive == true && _holdRemaining > Duration.zero;

  Future<void> fetchSeatsForShowtime(
    String showtimeId, {
    bool silent = false,
  }) async {
    if (!silent) {
      _isLoading = true;
    }
    _errorMessage = null;
    if (!silent) {
      notifyListeners();
    }
    try {
      _seats = await showtimeRepository.getSeatsForShowtime(showtimeId);
      if (!silent) {
        _isLoading = false;
      }
      notifyListeners();
    } catch (e) {
      if (!silent) {
        _isLoading = false;
      }
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> holdSeats(String showtimeId, List<String> seatIds) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final session = await bookingRepository.holdSeats(
        showtimeId: showtimeId,
        seatIds: seatIds,
        holdSessionId: _holdSession?.id,
      );
      _applyHoldSession(session);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<Booking?> checkoutBooking({
    required String showtimeId,
    required List<String> seatIds,
    String? userId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final booking = await bookingRepository.createBooking(
        showtimeId: showtimeId,
        seatIds: seatIds,
        userId: userId,
      );
      _holdTimer?.cancel();
      _holdSession = null;
      _holdRemaining = Duration.zero;
      _isLoading = false;
      notifyListeners();
      return booking;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _parseError(e);
      notifyListeners();
      return null;
    }
  }

  void _applyHoldSession(SeatHoldSession session) {
    _holdTimer?.cancel();
    if (!session.isActive) {
      _holdSession = null;
      _holdRemaining = Duration.zero;
      return;
    }

    _holdSession = session;
    final serverRemaining =
        session.expiresAt!.difference(session.serverTime);
    _holdRemaining =
        serverRemaining.isNegative ? Duration.zero : serverRemaining;
    _holdTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_holdRemaining <= const Duration(seconds: 1)) {
        _holdTimer?.cancel();
        _holdSession = null;
        _holdRemaining = Duration.zero;
      } else {
        _holdRemaining -= const Duration(seconds: 1);
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  Future<void> quoteBooking(String showtimeId, List<String> seatIds) async {
    final requestVersion = ++_quoteRequestVersion;
    if (seatIds.isEmpty) {
      _currentQuote = null;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _currentQuote = null;
    _errorMessage = null;
    notifyListeners();
    try {
      final quote = await bookingRepository.quoteBooking(
        showtimeId: showtimeId,
        seatIds: seatIds,
      );
      if (requestVersion != _quoteRequestVersion) return;
      _currentQuote = quote;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      if (requestVersion != _quoteRequestVersion) return;
      _currentQuote = null;
      _errorMessage = _parseError(e);
      notifyListeners();
    }
  }

  String _parseError(dynamic e) {
    final str = e.toString();
    if (str.contains('message:')) {
      try {
        final regExp = RegExp(r'"message":\s*"([^"]+)"');
        final match = regExp.firstMatch(str);
        if (match != null) {
          return match.group(1)!;
        }
      } catch (_) {}
    }
    return str.replaceAll('Exception: ', '');
  }
}
