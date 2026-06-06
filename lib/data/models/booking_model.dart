import '../../domain/entities/booking.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.userId,
    required super.showtimeId,
    required super.status,
    required super.totalPrice,
    super.expiredAt,
    required super.seatIds,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      showtimeId: json['showtimeId'] ?? '',
      status: json['status'] ?? '',
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      expiredAt: json['expiredAt'] != null ? DateTime.parse(json['expiredAt']).toLocal() : null,
      seatIds: json['seatIds'] != null ? List<String>.from(json['seatIds']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'userId': userId,
      'showtimeId': showtimeId,
      'status': status,
      'totalPrice': totalPrice,
      if (expiredAt != null) 'expiredAt': expiredAt!.toUtc().toIso8601String(),
      'seatIds': seatIds,
    };
  }
}
