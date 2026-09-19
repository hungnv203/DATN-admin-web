import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_quote.dart';
import '../../domain/entities/pos_payment_result.dart';
import '../../domain/entities/seat_hold_session.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Booking>> getBookings() async =>
      List<Booking>.from(await remoteDataSource.getBookings());

  @override
  Future<Booking> createBooking({
    required String showtimeId,
    required List<String> seatIds,
    required String seatHoldGroupId,
  }) => remoteDataSource.createBooking(
    showtimeId: showtimeId,
    seatIds: seatIds,
    seatHoldGroupId: seatHoldGroupId,
  );

  @override
  Future<BookingQuote> quoteBooking({
    required String showtimeId,
    required List<String> seatIds,
  }) => remoteDataSource.quoteBooking(showtimeId: showtimeId, seatIds: seatIds);

  @override
  Future<SeatHoldSession> holdSeats({
    required String showtimeId,
    required List<String> seatIds,
  }) => remoteDataSource.holdSeats(showtimeId: showtimeId, seatIds: seatIds);

  @override
  Future<void> releaseHold(String holdGroupId) =>
      remoteDataSource.releaseHold(holdGroupId);

  @override
  Future<PosPaymentResult> confirmPosCash({
    required String bookingId,
    required String idempotencyKey,
  }) => remoteDataSource.confirmPosCash(
    bookingId: bookingId,
    idempotencyKey: idempotencyKey,
  );

  @override
  Future<PosPaymentResult> cancelPos({
    required String bookingId,
    required String idempotencyKey,
    required String reasonCode,
  }) => remoteDataSource.cancelPos(
    bookingId: bookingId,
    idempotencyKey: idempotencyKey,
    reasonCode: reasonCode,
  );
}
