import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/cinema_model.dart';

abstract class CinemaRemoteDataSource {
  Future<List<CinemaModel>> getCinemas();
  Future<CinemaModel> createCinema({required String name, required String address, required String city});
  Future<bool> updateCinema(String id, {required String name, required String address, required String city});
  Future<bool> deleteCinema(String id);
  
  Future<List<RoomModel>> getRooms();
  Future<RoomModel> createRoom({required String cinemaId, required String name, required int totalSeats, required String type});
  Future<bool> deleteRoom(String id);

  Future<void> createSeat({required String roomId, required String row, required int number, required String type});
}

class CinemaRemoteDataSourceImpl implements CinemaRemoteDataSource {
  final DioClient client;

  CinemaRemoteDataSourceImpl(this.client);

  @override
  Future<List<CinemaModel>> getCinemas() async {
    final response = await client.get(ApiConstants.cinemas);
    final List<dynamic> data = response.data;
    return data.map((json) => CinemaModel.fromJson(json)).toList();
  }

  @override
  Future<CinemaModel> createCinema({required String name, required String address, required String city}) async {
    final response = await client.post(
      ApiConstants.cinemas,
      data: {
        'name': name,
        'address': address,
        'city': city,
      },
    );
    return CinemaModel.fromJson(response.data);
  }

  @override
  Future<bool> updateCinema(String id, {required String name, required String address, required String city}) async {
    final response = await client.put(
      '${ApiConstants.cinemas}/$id',
      data: {
        'id': id,
        'name': name,
        'address': address,
        'city': city,
      },
    );
    return response.statusCode == 204 || response.statusCode == 200;
  }

  @override
  Future<bool> deleteCinema(String id) async {
    final response = await client.delete('${ApiConstants.cinemas}/$id');
    return response.statusCode == 204 || response.statusCode == 200;
  }

  @override
  Future<List<RoomModel>> getRooms() async {
    final response = await client.get(ApiConstants.rooms);
    final List<dynamic> data = response.data;
    return data.map((json) => RoomModel.fromJson(json)).toList();
  }

  @override
  Future<RoomModel> createRoom({required String cinemaId, required String name, required int totalSeats, required String type}) async {
    final response = await client.post(
      ApiConstants.rooms,
      data: {
        'cinemaId': cinemaId,
        'name': name,
        'totalSeats': totalSeats,
        'type': type,
      },
    );
    return RoomModel.fromJson(response.data);
  }

  @override
  Future<bool> deleteRoom(String id) async {
    final response = await client.delete('${ApiConstants.rooms}/$id');
    return response.statusCode == 204 || response.statusCode == 200;
  }

  @override
  Future<void> createSeat({required String roomId, required String row, required int number, required String type}) async {
    await client.post(
      ApiConstants.seats,
      data: {
        'roomId': roomId,
        'rowLabel': row,
        'seatNumber': number,
        'type': type,
      },
    );
  }
}
