import 'package:flutter/material.dart';
import '../../domain/entities/showtime.dart';
import '../../domain/repositories/showtime_repository.dart';

class ShowtimeProvider extends ChangeNotifier {
  final ShowtimeRepository repository;

  List<Showtime> _showtimes = [];
  bool _isLoading = false;
  String? _errorMessage;

  ShowtimeProvider(this.repository);

  List<Showtime> get showtimes => _showtimes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchShowtimes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _showtimes = await repository.getShowtimes();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> createShowtime({
    required String movieId,
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    required double basePrice,
    required String status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newShowtime = await repository.createShowtime(
        movieId: movieId,
        roomId: roomId,
        startTime: startTime,
        endTime: endTime,
        basePrice: basePrice,
        status: status,
      );
      _showtimes.add(newShowtime);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateShowtime(
    String id, {
    required String movieId,
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    required double basePrice,
    required String status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await repository.updateShowtime(
        id,
        movieId: movieId,
        roomId: roomId,
        startTime: startTime,
        endTime: endTime,
        basePrice: basePrice,
        status: status,
      );
      if (success) {
        final index = _showtimes.indexWhere((s) => s.id == id);
        if (index != -1) {
          _showtimes[index] = Showtime(
            id: id,
            movieId: movieId,
            roomId: roomId,
            startTime: startTime,
            endTime: endTime,
            basePrice: basePrice,
            status: status,
          );
        }
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteShowtime(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await repository.deleteShowtime(id);
      if (success) {
        _showtimes.removeWhere((s) => s.id == id);
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

  String _parseError(dynamic e) {
    final str = e.toString();
    if (str.contains('message:')) {
      // Extract custom message from backend response if possible
      try {
        final regExp = RegExp(r'"message":\s*"([^"]+)"');
        final match = regExp.firstMatch(str);
        if (match != null) {
          return match.group(1)!;
        }
      } catch (_) {}
    }
    return str.replaceAll('Exception: ', '');
  }
}
