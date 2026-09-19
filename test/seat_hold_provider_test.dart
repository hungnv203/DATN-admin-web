import 'dart:async';

import 'package:datn_web/core/error/seat_hold_exceptions.dart';
import 'package:datn_web/domain/entities/seat_hold_session.dart';
import 'package:datn_web/domain/entities/seat_realtime_state.dart';
import 'package:datn_web/domain/entities/showtime_seat.dart';
import 'package:datn_web/domain/repositories/booking_repository.dart';
import 'package:datn_web/domain/repositories/seat_realtime_repository.dart';
import 'package:datn_web/domain/repositories/showtime_repository.dart';
import 'package:datn_web/presentation/providers/booking_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prevents selecting a ninth seat before sending a hold request', () {
    final provider = _createProvider(_FakeBookingRepository());
    addTearDown(provider.dispose);

    for (var index = 0; index < 8; index++) {
      expect(provider.toggleSeat(_seat(index)), isTrue);
    }

    expect(provider.toggleSeat(_seat(8)), isFalse);
    expect(provider.isSeatSelected('seat-8'), isFalse);
    expect(provider.errorMessage, 'Mỗi lượt chỉ được giữ tối đa 8 ghế.');
  });

  test('stores server expiry and moves an elapsed hold to expired', () async {
    var now = DateTime.utc(2026, 9, 19, 2);
    final repository = _FakeBookingRepository(
      session: SeatHoldSession(
        holdGroupId: 'group-1',
        showtimeId: 'showtime-1',
        seatIds: const ['seat-0'],
        status: 'Active',
        expiresAtUtc: now.add(const Duration(minutes: 5)),
        serverTimeUtc: now,
      ),
    );
    final provider = _createProvider(repository, nowUtc: () => now);
    addTearDown(provider.dispose);
    await provider.fetchSeatsForShowtime('showtime-1');

    final held = await provider.holdSeats('showtime-1', const ['seat-0']);

    expect(held, isTrue);
    expect(provider.currentHoldGroupId, 'group-1');
    expect(provider.holdRemaining, const Duration(minutes: 5));

    now = now.add(const Duration(minutes: 5, seconds: 1));
    provider.refreshHoldExpiry();

    expect(provider.phase, PosBookingPhase.expired);
    expect(provider.currentHoldGroupId, isNull);
    expect(provider.holdRemaining, Duration.zero);
  });

  test('maps rate limiting to a retryable POS state', () async {
    final repository = _FakeBookingRepository(
      holdError: const SeatHoldRateLimited('Too many requests'),
    );
    final provider = _createProvider(repository);
    addTearDown(provider.dispose);
    await provider.fetchSeatsForShowtime('showtime-1');

    final held = await provider.holdSeats('showtime-1', const ['seat-0']);

    expect(held, isFalse);
    expect(provider.phase, PosBookingPhase.retryableError);
    expect(provider.errorMessage, contains('Thao tác quá nhanh'));
  });

  test(
    'clears the full local selection when an atomic hold conflicts',
    () async {
      final repository = _FakeBookingRepository(
        holdError: const SeatHoldConflict(
          'One or more seats are unavailable',
          errorCode: 'SEAT_NOT_AVAILABLE',
        ),
      );
      final provider = _createProvider(repository);
      addTearDown(provider.dispose);
      await provider.fetchSeatsForShowtime('showtime-1');
      expect(provider.toggleSeat(provider.seats[0]), isTrue);
      expect(provider.toggleSeat(provider.seats[1]), isTrue);

      final held = await provider.holdSeats(
        'showtime-1',
        provider.selectedSeats.map((seat) => seat.seatId).toList(),
      );

      expect(held, isFalse);
      expect(provider.currentHoldGroupId, isNull);
      expect(provider.selectedSeats, isEmpty);
      expect(provider.currentQuote, isNull);
      expect(provider.phase, PosBookingPhase.conflict);
      expect(
        provider.errorMessage,
        'Một hoặc nhiều ghế vừa được người khác giữ.',
      );
    },
  );

  test('locks seat editing after hold until release succeeds', () async {
    final now = DateTime.utc(2026, 9, 19, 2);
    final repository = _FakeBookingRepository(
      session: SeatHoldSession(
        holdGroupId: 'group-1',
        showtimeId: 'showtime-1',
        seatIds: const ['seat-0'],
        status: 'Active',
        expiresAtUtc: now.add(const Duration(minutes: 5)),
        serverTimeUtc: now,
      ),
    );
    final provider = _createProvider(repository, nowUtc: () => now);
    addTearDown(provider.dispose);
    await provider.fetchSeatsForShowtime('showtime-1');
    expect(await provider.holdSeats('showtime-1', const ['seat-0']), isTrue);

    expect(provider.toggleSeat(_seat(0)), isFalse);
    expect(await provider.cancelCurrentFlow(), isTrue);
    expect(repository.releaseCalls, 1);
    expect(provider.currentHoldGroupId, isNull);
    expect(provider.toggleSeat(_seat(0)), isTrue);
  });
}

BookingProvider _createProvider(
  BookingRepository bookingRepository, {
  DateTime Function()? nowUtc,
}) {
  return BookingProvider(
    bookingRepository: bookingRepository,
    showtimeRepository: _FakeShowtimeRepository(),
    seatRealtimeRepository: _FakeSeatRealtimeRepository(),
    nowUtc: nowUtc,
  );
}

ShowtimeSeat _seat(int index) => ShowtimeSeat(
  seatId: 'seat-$index',
  rowLabel: 'A',
  seatNumber: index + 1,
  type: 'Standard',
  status: 'Available',
);

class _FakeBookingRepository implements BookingRepository {
  final SeatHoldSession? session;
  final Object? holdError;
  int releaseCalls = 0;

  _FakeBookingRepository({this.session, this.holdError});

  @override
  Future<SeatHoldSession> holdSeats({
    required String showtimeId,
    required List<String> seatIds,
  }) async {
    if (holdError != null) throw holdError!;
    return session!;
  }

  @override
  Future<void> releaseHold(String holdGroupId) async {
    releaseCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeShowtimeRepository implements ShowtimeRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSeatRealtimeRepository implements SeatRealtimeRepository {
  final _events = StreamController<SeatStateEvent>.broadcast();
  final _states = StreamController<SeatRealtimeConnectionState>.broadcast();

  @override
  Stream<SeatStateEvent> get events => _events.stream;

  @override
  Stream<SeatRealtimeConnectionState> get connectionStates => _states.stream;

  @override
  Future<SeatStateSnapshot> getSnapshot(String showtimeId) async =>
      SeatStateSnapshot(0, [_seat(0), _seat(1)]);

  @override
  Future<void> connect(String showtimeId) async {}

  @override
  Future<void> disconnect(String showtimeId) async {}

  @override
  Future<void> dispose() async {
    await _events.close();
    await _states.close();
  }
}
