import 'package:flutter/material.dart';
import '../../domain/entities/cinema.dart';
import '../../domain/entities/room.dart';
import '../../domain/repositories/cinema_repository.dart';

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
      final newCinema = await repository.createCinema(name: name, address: address, city: city);
      _cinemas.add(newCinema);
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
        final index = _cinemas.indexWhere((c) => c.id == id);
        if (index != -1) {
          _cinemas[index] = Cinema(id: id, name: name, address: address, city: city, rooms: _cinemas[index].rooms);
        }
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
        _cinemas.removeWhere((c) => c.id == id);
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
      _rooms.add(newRoom);
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
        _rooms.removeWhere((r) => r.id == id);
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
      // seatMap has key as "RowLabel-Number" (e.g. "A-1") and value as type (e.g. "Standard", "VIP", "Couple")
      for (final entry in seatMap.entries) {
        final keyParts = entry.key.split('-');
        final row = keyParts[0];
        final number = int.parse(keyParts[1]);
        final type = entry.value;
        if (type != 'Empty') {
          await repository.createSeat(roomId: roomId, row: row, number: number, type: type);
        }
      }
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
