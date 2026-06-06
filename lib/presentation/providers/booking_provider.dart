import 'package:flutter/material.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/showtime_seat.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/showtime_repository.dart';

class BookingProvider extends ChangeNotifier {
  final BookingRepository bookingRepository;
  final ShowtimeRepository showtimeRepository;

  List<ShowtimeSeat> _seats = [];
  bool _isLoading = false;
  String? _errorMessage;

  BookingProvider({
    required this.bookingRepository,
    required this.showtimeRepository,
  });

  List<ShowtimeSeat> get seats => _seats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSeatsForShowtime(String showtimeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _seats = await showtimeRepository.getSeatsForShowtime(showtimeId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> holdSeats(String showtimeId, List<String> seatIds) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await bookingRepository.holdSeats(
        showtimeId: showtimeId,
        seatIds: seatIds,
      );
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

  Future<Booking?> checkoutBooking({
    required String showtimeId,
    required List<String> seatIds,
    required String status,
    String? userId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final booking = await bookingRepository.createBooking(
        showtimeId: showtimeId,
        seatIds: seatIds,
        status: status,
        userId: userId,
      );
      _isLoading = false;
      notifyListeners();
      return booking;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _parseError(e);
      notifyListeners();
      return null;
    }
  }

  String _parseError(dynamic e) {
    final str = e.toString();
    if (str.contains('message:')) {
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
