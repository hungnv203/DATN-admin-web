import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/seat_hold_exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/booking_model.dart';
import '../models/booking_quote_model.dart';
import '../models/pos_payment_result_model.dart';
import '../models/seat_hold_session_model.dart';

abstract class BookingRemoteDataSource {
  Future<List<BookingModel>> getBookings();
  Future<BookingModel> createBooking({
    required String showtimeId,
    required List<String> seatIds,
    required String seatHoldGroupId,
  });
  Future<BookingQuoteModel> quoteBooking({
    required String showtimeId,
    required List<String> seatIds,
  });
  Future<SeatHoldSessionModel> holdSeats({
    required String showtimeId,
    required List<String> seatIds,
  });
  Future<void> releaseHold(String holdGroupId);
  Future<PosPaymentResultModel> confirmPosCash({
    required String bookingId,
    required String idempotencyKey,
  });
  Future<PosPaymentResultModel> cancelPos({
    required String bookingId,
    required String idempotencyKey,
    required String reasonCode,
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
    required String seatHoldGroupId,
  }) async {
    final response = await client.post(
      '${ApiConstants.bookings}/pos',
      data: {
        'showtimeId': showtimeId,
        'seatIds': seatIds,
        'seatHoldGroupId': seatHoldGroupId,
      },
    );
    return BookingModel.fromJson(response.data);
  }

  @override
  Future<BookingQuoteModel> quoteBooking({
    required String showtimeId,
    required List<String> seatIds,
  }) async {
    final response = await client.post(
      '${ApiConstants.bookings}/quote',
      data: {
        'showtimeId': showtimeId,
        'seatIds': seatIds,
        'concessions': <Map<String, dynamic>>[],
        'usedPoints': 0,
      },
    );
    return BookingQuoteModel.fromJson(response.data);
  }

  @override
  Future<SeatHoldSessionModel> holdSeats({
    required String showtimeId,
    required List<String> seatIds,
  }) async {
    try {
      final response = await client.post(
        '/api/seat-holds',
        data: {'showtimeId': showtimeId, 'seatIds': seatIds},
      );
      return SeatHoldSessionModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on ServerException catch (error) {
      _throwHoldFailure(error);
    }
  }

  @override
  Future<void> releaseHold(String holdGroupId) async {
    try {
      await client.delete('/api/seat-holds/$holdGroupId');
    } on ServerException catch (error) {
      _throwHoldFailure(error);
    }
  }

  Never _throwHoldFailure(ServerException error) {
    final statusCode = error.statusCode;
    final message = error.message;
    final errorCode = error.errorCode;

    if (statusCode == 409) {
      if (errorCode == 'SHOWTIME_NOT_BOOKABLE') {
        throw SeatHoldShowtimeNotBookable(message);
      }
      if (errorCode == 'HOLD_SEAT_LIMIT_EXCEEDED') {
        throw SeatHoldLimitExceeded(message);
      }
      if (errorCode == 'HOLD_ALREADY_BOOKED') {
        throw SeatHoldAlreadyBooked(message);
      }
      if (errorCode == 'BOOKING_ALREADY_PENDING') {
        throw SeatHoldBookingAlreadyPending(message);
      }
      throw SeatHoldConflict(message, errorCode: errorCode);
    }
    if (statusCode == 404) {
      throw SeatHoldUnavailable(message);
    }
    if (statusCode == 429) {
      throw SeatHoldRateLimited(message);
    }
    if (statusCode == 401 || statusCode == 403) {
      throw const SeatHoldAuthenticationRequired();
    }
    throw SeatHoldTransportFailure(message);
  }

  @override
  Future<PosPaymentResultModel> confirmPosCash({
    required String bookingId,
    required String idempotencyKey,
  }) async {
    final response = await client.post(
      '${ApiConstants.bookings}/$bookingId/pos-payment-confirmations',
      data: const {'method': 'Cash'},
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return PosPaymentResultModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  @override
  Future<PosPaymentResultModel> cancelPos({
    required String bookingId,
    required String idempotencyKey,
    required String reasonCode,
  }) async {
    final response = await client.post(
      '${ApiConstants.bookings}/$bookingId/pos-cancellations',
      data: {'reasonCode': reasonCode},
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return PosPaymentResultModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}
