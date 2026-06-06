import '../../domain/entities/showtime_seat.dart';

class ShowtimeSeatModel extends ShowtimeSeat {
  const ShowtimeSeatModel({
    required super.seatId,
    required super.rowLabel,
    required super.seatNumber,
    required super.type,
    required super.status,
    super.heldByUserId,
  });

  factory ShowtimeSeatModel.fromJson(Map<String, dynamic> json) {
    return ShowtimeSeatModel(
      seatId: json['seatId'] ?? '',
      rowLabel: json['rowLabel'] ?? '',
      seatNumber: json['seatNumber'] ?? 0,
      type: json['type'] ?? 'Standard',
      status: json['status'] ?? 'Available',
      heldByUserId: json['heldByUserId'],
    );
  }
}
