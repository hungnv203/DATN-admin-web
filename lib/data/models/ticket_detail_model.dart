import '../../domain/entities/ticket_detail.dart';

class TicketDetailModel extends TicketDetail {
  const TicketDetailModel({
    required super.id,
    required super.bookingId,
    required super.seatId,
    required super.price,
    required super.qrCode,
    required super.status,
    required super.movieTitle,
    required super.seatLabel,
    required super.paymentStatus,
    required super.createdAt,
    required super.cinemaName,
    required super.roomName,
    required super.startTime,
    required super.customerName,
    required super.customerEmail,
  });

  factory TicketDetailModel.fromJson(Map<String, dynamic> json) {
    return TicketDetailModel(
      id: json['id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      seatId: json['seatId'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      qrCode: json['qrCode'] ?? '',
      status: json['status'] ?? '',
      movieTitle: json['movieTitle'] ?? '',
      seatLabel: json['seatLabel'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt']).toLocal()
          : DateTime.now(),
      cinemaName: json['cinemaName'] ?? '',
      roomName: json['roomName'] ?? '',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime']).toLocal()
          : DateTime.now(),
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'seatId': seatId,
      'price': price,
      'qrCode': qrCode,
      'status': status,
      'movieTitle': movieTitle,
      'seatLabel': seatLabel,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'cinemaName': cinemaName,
      'roomName': roomName,
      'startTime': startTime.toUtc().toIso8601String(),
      'customerName': customerName,
      'customerEmail': customerEmail,
    };
  }
}
