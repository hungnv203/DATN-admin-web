import '../../domain/entities/seat.dart';

class SeatModel extends Seat {
  const SeatModel({
    required super.id,
    required super.roomId,
    required super.row,
    required super.number,
    required super.type,
    super.isAvailable,
  });

  factory SeatModel.fromJson(Map<String, dynamic> json) {
    return SeatModel(
      id: json['id'] ?? '',
      roomId: json['roomId'] ?? '',
      row: json['rowLabel'] ?? json['row'] ?? '',
      number: json['seatNumber'] ?? json['number'] ?? 0,
      type: json['type'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'rowLabel': row,
      'seatNumber': number,
      'type': type,
    };
  }
}
