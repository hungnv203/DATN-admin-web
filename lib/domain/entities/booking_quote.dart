class BookingQuote {
  final double seatTotal;
  final double concessionTotal;
  final double subtotal;
  final double discountAmount;
  final int usedPoints;
  final double pointDiscountAmount;
  final double totalPrice;

  const BookingQuote({
    required this.seatTotal,
    required this.concessionTotal,
    required this.subtotal,
    required this.discountAmount,
    required this.usedPoints,
    required this.pointDiscountAmount,
    required this.totalPrice,
  });
}
