import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/booking_model.dart';

abstract class BookingRemoteDataSource {
  Future<List<BookingModel>> getBookings();
  Future<BookingModel> createBooking({
    required String showtimeId,
    required List<String> seatIds,
    required String status,
    String? userId,
  });
  Future<bool> holdSeats({
    required String showtimeId,
    required List<String> seatIds,
  });
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final DioClient client;

  BookingRemoteDataSourceImpl(this.client);

  @override
  Future<List<BookingModel>> getBookings() async {
    final response = await client.get(ApiConstants.bookings);
    final List<dynamic> data = response.data;
    return data.map((json) => BookingModel.fromJson(json)).toList();
  }

  @override
  Future<BookingModel> createBooking({
    required String showtimeId,
    required List<String> seatIds,
    required String status,
    String? userId,
  }) async {
    final response = await client.post(
      '${ApiConstants.bookings}/pos',
      data: {
        'showtimeId': showtimeId,
        'seatIds': seatIds,
        'status': status,
        if (userId != null && userId.isNotEmpty) 'userId': userId,
      },
    );
    return BookingModel.fromJson(response.data);
  }

  @override
  Future<bool> holdSeats({
    required String showtimeId,
    required List<String> seatIds,
  }) async {
    final response = await client.post(
      '${ApiConstants.bookings}/hold-seats',
      data: {
        'showtimeId': showtimeId,
        'seatIds': seatIds,
      },
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
