import 'package:datn_web/data/datasources/booking_remote_data_source.dart';
import 'package:datn_web/data/models/booking_model.dart';
import 'package:datn_web/data/models/booking_quote_model.dart';
import 'package:datn_web/data/models/pos_payment_result_model.dart';
import 'package:datn_web/data/models/seat_hold_session_model.dart';
import 'package:datn_web/data/repositories/booking_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'POS booking forwards existing hold group without hidden hold',
    () async {
      final remote = _FakeBookingRemoteDataSource();
      final repository = BookingRepositoryImpl(remote);

      final booking = await repository.createBooking(
        showtimeId: 'showtime',
        seatIds: const ['A1', 'A2'],
        seatHoldGroupId: 'random-hold-group',
      );

      expect(booking.status, 'Pending');
      expect(remote.createCalls, 1);
      expect(remote.holdCalls, 0);
      expect(remote.lastHoldGroupId, 'random-hold-group');
    },
  );

  test('cash confirmation forwards stable idempotency key', () async {
    final remote = _FakeBookingRemoteDataSource();
    final repository = BookingRepositoryImpl(remote);

    final result = await repository.confirmPosCash(
      bookingId: 'booking',
      idempotencyKey: '11111111-1111-4111-8111-111111111111',
    );

    expect(result.paymentState, 'Paid');
    expect(remote.lastIdempotencyKey, '11111111-1111-4111-8111-111111111111');
  });
}

class _FakeBookingRemoteDataSource implements BookingRemoteDataSource {
  int createCalls = 0;
  int holdCalls = 0;
  String? lastHoldGroupId;
  String? lastIdempotencyKey;

  @override
  Future<BookingModel> createBooking({
    required String showtimeId,
    required List<String> seatIds,
    required String seatHoldGroupId,
  }) async {
    createCalls++;
    lastHoldGroupId = seatHoldGroupId;
    return BookingModel(
      id: 'booking',
      userId: 'cashier',
      showtimeId: showtimeId,
      status: 'Pending',
      totalPrice: 100,
      seatIds: seatIds,
      createdAt: DateTime.now(),
      showtimeStartTime: DateTime.now(),
    );
  }

  @override
  Future<PosPaymentResultModel> confirmPosCash({
    required String bookingId,
    required String idempotencyKey,
  }) async {
    lastIdempotencyKey = idempotencyKey;
    return const PosPaymentResultModel(
      success: true,
      isReplay: false,
      paymentState: 'Paid',
      errorCode: '',
    );
  }

  @override
  Future<SeatHoldSessionModel> holdSeats({
    required String showtimeId,
    required List<String> seatIds,
  }) async {
    holdCalls++;
    final now = DateTime.now().toUtc();
    return SeatHoldSessionModel(
      holdGroupId: 'hold',
      showtimeId: showtimeId,
      seatIds: seatIds,
      status: 'Active',
      expiresAtUtc: now.add(const Duration(minutes: 5)),
      serverTimeUtc: now,
    );
  }

  @override
  Future<List<BookingModel>> getBookings() async => [];

  @override
  Future<void> releaseHold(String holdGroupId) async {}

  @override
  Future<BookingQuoteModel> quoteBooking({
    required String showtimeId,
    required List<String> seatIds,
  }) => throw UnimplementedError();

  @override
  Future<PosPaymentResultModel> cancelPos({
    required String bookingId,
    required String idempotencyKey,
    required String reasonCode,
  }) => throw UnimplementedError();
}
