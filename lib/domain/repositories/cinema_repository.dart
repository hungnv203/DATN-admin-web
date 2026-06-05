import '../entities/cinema.dart';
import '../entities/room.dart';
import '../entities/seat.dart';

abstract class CinemaRepository {
  Future<List<Cinema>> getCinemas();
  Future<Cinema> createCinema({required String name, required String address, required String city});
  Future<bool> updateCinema(String id, {required String name, required String address, required String city});
  Future<bool> deleteCinema(String id);
  
  Future<List<Room>> getRooms();
  Future<Room> createRoom({required String cinemaId, required String name, required int totalSeats, required String type});
  Future<bool> deleteRoom(String id);

  Future<void> createSeat({required String roomId, required String row, required int number, required String type});
}
