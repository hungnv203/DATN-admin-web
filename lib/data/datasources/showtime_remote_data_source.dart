import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/showtime_model.dart';
import '../models/showtime_seat_model.dart';

abstract class ShowtimeRemoteDataSource {
  Future<List<ShowtimeModel>> getShowtimes();
  Future<ShowtimeModel> createShowtime({
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
  Future<List<ShowtimeSeatModel>> getSeatsForShowtime(String showtimeId);
}

class ShowtimeRemoteDataSourceImpl implements ShowtimeRemoteDataSource {
  final DioClient client;

  ShowtimeRemoteDataSourceImpl(this.client);

  @override
  Future<List<ShowtimeModel>> getShowtimes() async {
    final response = await client.get(ApiConstants.showtimes);
    final List<dynamic> data = response.data;
    return data.map((json) => ShowtimeModel.fromJson(json)).toList();
  }

  @override
  Future<ShowtimeModel> createShowtime({
    required String movieId,
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    required double basePrice,
    required String status,
  }) async {
    final response = await client.post(
      ApiConstants.showtimes,
      data: {
        'movieId': movieId,
        'roomId': roomId,
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
        'basePrice': basePrice,
        'status': status,
      },
    );
    return ShowtimeModel.fromJson(response.data);
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
    final response = await client.put(
      '${ApiConstants.showtimes}/$id',
      data: {
        'id': id,
        'movieId': movieId,
        'roomId': roomId,
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
        'basePrice': basePrice,
        'status': status,
      },
    );
    return response.statusCode == 204 || response.statusCode == 200;
  }

  @override
  Future<bool> deleteShowtime(String id) async {
    final response = await client.delete('${ApiConstants.showtimes}/$id');
    return response.statusCode == 204 || response.statusCode == 200;
  }

  @override
  Future<List<ShowtimeSeatModel>> getSeatsForShowtime(String showtimeId) async {
    final response = await client.get('${ApiConstants.showtimes}/$showtimeId/seats');
    final List<dynamic> data = response.data;
    return data.map((json) => ShowtimeSeatModel.fromJson(json)).toList();
  }
}
