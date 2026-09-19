import '../entities/booking.dart';
import '../entities/booking_quote.dart';
import '../entities/pos_payment_result.dart';
import '../entities/seat_hold_session.dart';

abstract class BookingRepository {
  Future<List<Booking>> getBookings();
  Future<Booking> createBooking({
    required String showtimeId,
    required List<String> seatIds,
    required String seatHoldGroupId,
  });
  Future<BookingQuote> quoteBooking({
    required String showtimeId,
    required List<String> seatIds,
  });
  Future<SeatHoldSession> holdSeats({
    required String showtimeId,
    required List<String> seatIds,
  });
  Future<void> releaseHold(String holdGroupId);
  Future<PosPaymentResult> confirmPosCash({
    required String bookingId,
    required String idempotencyKey,
  });
  Future<PosPaymentResult> cancelPos({
    required String bookingId,
    required String idempotencyKey,
    required String reasonCode,
  });
}
