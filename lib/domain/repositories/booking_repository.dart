import '../entities/booking.dart';

abstract class BookingRepository {
  Future<List<Booking>> getBookings();
  Future<Booking> createBooking({
    required String showtimeId,
    required List<String> seatIds,
    required String status,
    String? userId,
  });
  Future<bool> holdSeats({
    required String showtimeId,
    required List<String> seatIds,
  });
}
