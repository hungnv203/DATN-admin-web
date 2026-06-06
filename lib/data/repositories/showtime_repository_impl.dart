import '../../domain/entities/showtime.dart';
import '../../domain/entities/showtime_seat.dart';
import '../../domain/repositories/showtime_repository.dart';
import '../datasources/showtime_remote_data_source.dart';

class ShowtimeRepositoryImpl implements ShowtimeRepository {
  final ShowtimeRemoteDataSource remoteDataSource;

  ShowtimeRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Showtime>> getShowtimes() async {
    final showtimes = await remoteDataSource.getShowtimes();
    return List<Showtime>.from(showtimes);
  }

  @override
  Future<Showtime> createShowtime({
    required String movieId,
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    required double basePrice,
    required String status,
  }) async {
    return await remoteDataSource.createShowtime(
      movieId: movieId,
      roomId: roomId,
      startTime: startTime,
      endTime: endTime,
      basePrice: basePrice,
      status: status,
    );
  }

  @override
  Future<bool> updateShowtime(
    String id, {
    required String movieId,
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    required double basePrice,
    required String status,
  }) async {
    return await remoteDataSource.updateShowtime(
      id,
      movieId: movieId,
      roomId: roomId,
      startTime: startTime,
      endTime: endTime,
      basePrice: basePrice,
      status: status,
    );
  }

  @override
  Future<bool> deleteShowtime(String id) async {
    return await remoteDataSource.deleteShowtime(id);
  }

  @override
  Future<List<ShowtimeSeat>> getSeatsForShowtime(String showtimeId) async {
    final seats = await remoteDataSource.getSeatsForShowtime(showtimeId);
    return List<ShowtimeSeat>.from(seats);
  }
}
