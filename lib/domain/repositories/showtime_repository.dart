import '../entities/showtime.dart';
import '../entities/showtime_seat.dart';

abstract class ShowtimeRepository {
  Future<List<Showtime>> getShowtimes();
  Future<Showtime> createShowtime({
    required String movieId,
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    required double basePrice,
    required String status,
  });
  Future<bool> updateShowtime(
    String id, {
    required String movieId,
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    required double basePrice,
    required String status,
  });
  Future<bool> deleteShowtime(String id);
  Future<List<ShowtimeSeat>> getSeatsForShowtime(String showtimeId);
}
