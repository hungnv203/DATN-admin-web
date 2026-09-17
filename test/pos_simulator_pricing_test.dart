import 'dart:io';

import 'package:datn_web/domain/entities/showtime.dart';
import 'package:datn_web/domain/entities/showtime_seat.dart';
import 'package:datn_web/presentation/screens/pos_simulator_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('POS simulator pricing calculation', () {
    final testShowtime = Showtime(
      id: 'showtime-1',
      movieId: 'movie-1',
      roomId: 'room-1',
      startTime: DateTime(2026, 9, 18, 19, 0),
      endTime: DateTime(2026, 9, 18, 21, 0),
      basePrice: 85000,
      status: 'Scheduled',
    );

    test('calculates correct price for Standard seat', () {
      const seat = ShowtimeSeat(
        seatId: 's1',
        rowLabel: 'A',
        seatNumber: 1,
        type: 'Standard',
        status: 'Available',
      );

      final price = PosSimulatorScreen.calculateSeatPrice(seat, testShowtime);
      expect(price, 85000);
      expect(PosSimulatorScreen.formatCurrency(price), contains('85.000'));
    });

    test('calculates correct price for VIP seat (+20k markup)', () {
      const seat = ShowtimeSeat(
        seatId: 's2',
        rowLabel: 'B',
        seatNumber: 2,
        type: 'VIP',
        status: 'Available',
      );

      final price = PosSimulatorScreen.calculateSeatPrice(seat, testShowtime);
      expect(price, 105000);
      expect(PosSimulatorScreen.formatCurrency(price), contains('105.000'));
    });

    test('calculates correct price for Couple seat (+40k markup)', () {
      const seat = ShowtimeSeat(
        seatId: 's3',
        rowLabel: 'C',
        seatNumber: 3,
        type: 'Couple',
        status: 'Available',
      );

      final price = PosSimulatorScreen.calculateSeatPrice(seat, testShowtime);
      expect(price, 125000);
      expect(PosSimulatorScreen.formatCurrency(price), contains('125.000'));
    });

    test('handles case-insensitivity in seat type', () {
      const seatVip = ShowtimeSeat(
        seatId: 's4',
        rowLabel: 'D',
        seatNumber: 4,
        type: 'vip',
        status: 'Available',
      );

      expect(
        PosSimulatorScreen.calculateSeatPrice(seatVip, testShowtime),
        105000,
      );
    });

    test('pos_simulator_screen source does not contain placeholder strings', () {
      final source = File(
        'lib/presentation/screens/pos_simulator_screen.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('Backend pricing')));
      expect(source, isNot(contains('Included in server total')));
    });
  });
}
