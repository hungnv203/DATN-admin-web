import '../../domain/entities/cinema.dart';
import '../../domain/entities/room.dart';
import '../../domain/repositories/cinema_repository.dart';
import '../datasources/cinema_remote_data_source.dart';
import '../../domain/entities/seat_layout_item.dart';

class CinemaRepositoryImpl implements CinemaRepository {
  final CinemaRemoteDataSource remoteDataSource;

  CinemaRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Cinema>> getCinemas() async {
    final cinemas = await remoteDataSource.getCinemas();
    return List<Cinema>.from(cinemas);
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
    final rooms = await remoteDataSource.getRooms();
    return List<Room>.from(rooms);
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
  Future<void> createSeatLayout({
    required String roomId,
    required List<SeatLayoutItem> seats,
  }) {
    return remoteDataSource.createSeatLayout(
      roomId: roomId,
      seats: seats,
    );
  }
}
