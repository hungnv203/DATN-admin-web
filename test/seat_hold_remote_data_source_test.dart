import 'package:datn_web/core/error/exceptions.dart';
import 'package:datn_web/core/error/seat_hold_exceptions.dart';
import 'package:datn_web/core/network/dio_client.dart';
import 'package:datn_web/data/datasources/booking_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'parses the authoritative hold session returned by the server',
    () async {
      final source = BookingRemoteDataSourceImpl(
        _StubDioClient(
          postResponse: Response(
            requestOptions: RequestOptions(path: '/api/seat-holds'),
            statusCode: 201,
            data: {
              'holdGroupId': 'group-1',
              'showtimeId': 'showtime-1',
              'seatIds': ['seat-1'],
              'status': 'Active',
              'expiredAt': '2026-09-19T02:05:00Z',
              'serverTimeUtc': '2026-09-19T02:00:00Z',
            },
          ),
        ),
      );

      final session = await source.holdSeats(
        showtimeId: 'showtime-1',
        seatIds: const ['seat-1'],
      );

      expect(session.holdGroupId, 'group-1');
      expect(session.expiresAtUtc, DateTime.utc(2026, 9, 19, 2, 5));
      expect(session.serverTimeUtc, DateTime.utc(2026, 9, 19, 2));
    },
  );

  test('maps exact 409 code to a typed hold exception', () async {
    final source = BookingRemoteDataSourceImpl(
      _StubDioClient(
        postError: ServerException(
          'Showtime is no longer available.',
          409,
          'SHOWTIME_NOT_BOOKABLE',
        ),
      ),
    );

    await expectLater(
      source.holdSeats(showtimeId: 'showtime-1', seatIds: const ['seat-1']),
      throwsA(isA<SeatHoldShowtimeNotBookable>()),
    );
  });

  test('maps a body-less 429 response to rate limited', () async {
    final source = BookingRemoteDataSourceImpl(
      _StubDioClient(postError: ServerException('Too many requests', 429)),
    );

    await expectLater(
      source.holdSeats(showtimeId: 'showtime-1', seatIds: const ['seat-1']),
      throwsA(isA<SeatHoldRateLimited>()),
    );
  });

  test('maps DELETE after booking to the typed exception', () async {
    final source = BookingRemoteDataSourceImpl(
      _StubDioClient(
        deleteError: ServerException(
          'This seat hold is already linked to a booking.',
          409,
          'HOLD_ALREADY_BOOKED',
        ),
      ),
    );

    await expectLater(
      source.releaseHold('group-1'),
      throwsA(isA<SeatHoldAlreadyBooked>()),
    );
  });
}

class _StubDioClient extends DioClient {
  final Response<dynamic>? postResponse;
  final ServerException? postError;
  final ServerException? deleteError;

  _StubDioClient({this.postResponse, this.postError, this.deleteError});

  @override
  Future<Response<dynamic>> post(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (postError != null) throw postError!;
    return postResponse!;
  }

  @override
  Future<Response<dynamic>> delete(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (deleteError != null) throw deleteError!;
    return Response(requestOptions: RequestOptions(path: uri), statusCode: 204);
  }
}
