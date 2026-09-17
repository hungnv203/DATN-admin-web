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
    super.channel,
    super.subtotal,
    super.discountAmount,
    super.promotionCode,
    required super.createdAt,
    super.movieTitle,
    super.cinemaName,
    super.roomName,
    required super.showtimeStartTime,
    super.customerName,
    super.customerEmail,
    super.customerPhone,
    super.paymentMethod,
    super.seatLabels,
    super.concessions,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      showtimeId: json['showtimeId'] ?? '',
      status: json['status'] ?? '',
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      expiredAt: json['expiredAt'] != null
          ? DateTime.parse(json['expiredAt']).toLocal()
          : null,
      seatIds: json['seatIds'] != null
          ? List<String>.from(json['seatIds'])
          : [],
      channel: json['channel'] ?? '',
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0.0).toDouble(),
      promotionCode: json['promotionCode'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt']).toLocal()
          : DateTime.now(),
      movieTitle: json['movieTitle'] ?? '',
      cinemaName: json['cinemaName'] ?? '',
      roomName: json['roomName'] ?? '',
      showtimeStartTime: json['showtimeStartTime'] != null
          ? DateTime.parse(json['showtimeStartTime']).toLocal()
          : DateTime.now(),
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      seatLabels: json['seatLabels'] != null
          ? List<String>.from(json['seatLabels'])
          : [],
      concessions: json['concessions'] != null
          ? (json['concessions'] as List)
              .map((c) => BookingConcessionItem(
                    id: c['id'] ?? '',
                    concessionName: c['concessionName'] ?? '',
                    concessionImageUrl: c['concessionImageUrl'] ?? '',
                    quantity: c['quantity'] ?? 0,
                    price: (c['price'] ?? 0.0).toDouble(),
                  ))
              .toList()
          : [],
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
      'channel': channel,
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'promotionCode': promotionCode,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'movieTitle': movieTitle,
      'cinemaName': cinemaName,
      'roomName': roomName,
      'showtimeStartTime': showtimeStartTime.toUtc().toIso8601String(),
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'paymentMethod': paymentMethod,
      'seatLabels': seatLabels,
    };
  }
}
