import 'package:datn_web/domain/entities/showtime_seat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('showtime seat realtime merge preserves layout data', () {
    const seat = ShowtimeSeat(
      seatId: 'seat-1',
      rowLabel: 'A',
      seatNumber: 1,
      type: 'VIP',
      status: 'Available',
    );

    final held = seat.copyWith(status: 'Held', heldByCurrentUser: true);

    expect(held.seatId, seat.seatId);
    expect(held.rowLabel, seat.rowLabel);
    expect(held.status, 'Held');
    expect(held.heldByCurrentUser, isTrue);
  });
}
