import 'package:flutter/material.dart';
import '../../domain/entities/cinema.dart';
import '../../domain/entities/room.dart';
import '../../domain/repositories/cinema_repository.dart';
import '../../domain/entities/seat_layout_item.dart';

class CinemaProvider extends ChangeNotifier {
  final CinemaRepository repository;

  List<Cinema> _cinemas = [];
  List<Room> _rooms = [];
  bool _isLoading = false;
  String? _errorMessage;

  CinemaProvider(this.repository);

  List<Cinema> get cinemas => _cinemas;
  List<Room> get rooms => _rooms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCinemas() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _cinemas = await repository.getCinemas();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> createCinema(String name, String address, String city) async {
    _isLoading = true;
    notifyListeners();
    try {
      await repository.createCinema(name: name, address: address, city: city);
      _cinemas = await repository.getCinemas();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCinema(String id, String name, String address, String city) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await repository.updateCinema(id, name: name, address: address, city: city);
      if (success) {
        _cinemas = await repository.getCinemas();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCinema(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await repository.deleteCinema(id);
      if (success) {
        _cinemas = await repository.getCinemas();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchRooms() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _rooms = await repository.getRooms();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<Room?> createRoom(String cinemaId, String name, int totalSeats, String type) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newRoom = await repository.createRoom(
        cinemaId: cinemaId,
        name: name,
        totalSeats: totalSeats,
        type: type,
      );
      _rooms = await repository.getRooms();
      _isLoading = false;
      notifyListeners();
      return newRoom;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteRoom(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await repository.deleteRoom(id);
      if (success) {
        _rooms = await repository.getRooms();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> generateSeatLayout(String roomId, Map<String, String> seatMap) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final seats = seatMap.entries
          .where((entry) => entry.value != 'Empty')
          .map((entry) {
            final position = entry.key.split('-');
            return SeatLayoutItem(
              rowLabel: position[0],
              seatNumber: int.parse(position[1]),
              type: entry.value,
            );
          })
          .toList();
      await repository.createSeatLayout(roomId: roomId, seats: seats);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
