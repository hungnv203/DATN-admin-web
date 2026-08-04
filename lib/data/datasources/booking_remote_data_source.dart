import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/booking_model.dart';
import '../models/booking_quote_model.dart';
import '../models/pos_payment_result_model.dart';

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
  Future<String> holdSeats({
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
  Future<String> holdSeats({
    required String showtimeId,
    required List<String> seatIds,
  }) async {
    final response = await client.post(
      '/api/seat-holds',
      data: {'showtimeId': showtimeId, 'seatIds': seatIds},
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    final holdGroupId = data['holdGroupId']?.toString();
    if (holdGroupId == null || holdGroupId.isEmpty) {
      throw Exception('Seat hold identifier was not returned by the server.');
    }
    return holdGroupId;
  }

  @override
  Future<void> releaseHold(String holdGroupId) async {
    await client.delete('/api/seat-holds/$holdGroupId');
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
