import '../../domain/entities/cinema.dart';
import '../../domain/entities/room.dart';
import '../../domain/repositories/cinema_repository.dart';
import '../datasources/cinema_remote_data_source.dart';

class CinemaRepositoryImpl implements CinemaRepository {
  final CinemaRemoteDataSource remoteDataSource;

  CinemaRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Cinema>> getCinemas() async {
    return await remoteDataSource.getCinemas();
  }

  @override
  Future<Cinema> createCinema({required String name, required String address, required String city}) async {
    return await remoteDataSource.createCinema(name: name, address: address, city: city);
  }

  @override
  Future<bool> updateCinema(String id, {required String name, required String address, required String city}) async {
    return await remoteDataSource.updateCinema(id, name: name, address: address, city: city);
  }

  @override
  Future<bool> deleteCinema(String id) async {
    return await remoteDataSource.deleteCinema(id);
  }

  @override
  Future<List<Room>> getRooms() async {
    return await remoteDataSource.getRooms();
  }

  @override
  Future<Room> createRoom({required String cinemaId, required String name, required int totalSeats, required String type}) async {
    return await remoteDataSource.createRoom(cinemaId: cinemaId, name: name, totalSeats: totalSeats, type: type);
  }

  @override
  Future<bool> deleteRoom(String id) async {
    return await remoteDataSource.deleteRoom(id);
  }

  @override
  Future<void> createSeat({required String roomId, required String row, required int number, required String type}) async {
    await remoteDataSource.createSeat(roomId: roomId, row: row, number: number, type: type);
  }
}
