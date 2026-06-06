import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Booking>> getBookings() async {
    final bookings = await remoteDataSource.getBookings();
    return List<Booking>.from(bookings);
  }

  @override
  Future<Booking> createBooking({
    required String showtimeId,
    required List<String> seatIds,
    required String status,
    String? userId,
  }) async {
    return await remoteDataSource.createBooking(
      showtimeId: showtimeId,
      seatIds: seatIds,
      status: status,
      userId: userId,
    );
  }

  @override
  Future<bool> holdSeats({
    required String showtimeId,
    required List<String> seatIds,
  }) async {
    return await remoteDataSource.holdSeats(
      showtimeId: showtimeId,
      seatIds: seatIds,
    );
  }
}
