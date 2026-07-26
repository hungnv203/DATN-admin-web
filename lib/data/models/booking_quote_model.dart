import '../../domain/entities/booking_quote.dart';

class BookingQuoteModel extends BookingQuote {
  const BookingQuoteModel({
    required super.seatTotal,
    required super.concessionTotal,
    required super.subtotal,
    required super.discountAmount,
    required super.usedPoints,
    required super.pointDiscountAmount,
    required super.totalPrice,
  });

  factory BookingQuoteModel.fromJson(Map<String, dynamic> json) {
    return BookingQuoteModel(
      seatTotal: (json['seatTotal'] as num?)?.toDouble() ?? 0,
      concessionTotal: (json['concessionTotal'] as num?)?.toDouble() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
      usedPoints: (json['usedPoints'] as num?)?.toInt() ?? 0,
      pointDiscountAmount:
          (json['pointDiscountAmount'] as num?)?.toDouble() ?? 0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
    );
  }
}
