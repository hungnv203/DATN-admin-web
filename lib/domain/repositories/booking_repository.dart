import '../entities/booking.dart';
import '../entities/booking_quote.dart';

abstract class BookingRepository {
  Future<List<Booking>> getBookings();
  Future<Booking> createBooking({
    required String showtimeId,
    required List<String> seatIds,
    String? userId,
  });
  Future<BookingQuote> quoteBooking({
    required String showtimeId,
    required List<String> seatIds,
  });
  Future<bool> holdSeats({
    required String showtimeId,
    required List<String> seatIds,
  });
}
