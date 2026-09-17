class BookingConcessionItem {
  final String id;
  final String concessionName;
  final String concessionImageUrl;
  final int quantity;
  final double price;

  const BookingConcessionItem({
    required this.id,
    required this.concessionName,
    required this.concessionImageUrl,
    required this.quantity,
    required this.price,
  });
}

class Booking {
  final String id;
  final String userId;
  final String showtimeId;
  final String status;
  final double totalPrice;
  final DateTime? expiredAt;
  final List<String> seatIds;
  final String channel;
  final double subtotal;
  final double discountAmount;
  final String? promotionCode;
  final DateTime createdAt;
  final String movieTitle;
  final String cinemaName;
  final String roomName;
  final DateTime showtimeStartTime;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String paymentMethod;
  final List<String> seatLabels;
  final List<BookingConcessionItem> concessions;

  const Booking({
    required this.id,
    required this.userId,
    required this.showtimeId,
    required this.status,
    required this.totalPrice,
    this.expiredAt,
    required this.seatIds,
    this.channel = '',
    this.subtotal = 0,
    this.discountAmount = 0,
    this.promotionCode,
    required this.createdAt,
    this.movieTitle = '',
    this.cinemaName = '',
    this.roomName = '',
    required this.showtimeStartTime,
    this.customerName = '',
    this.customerEmail = '',
    this.customerPhone = '',
    this.paymentMethod = '',
    this.seatLabels = const [],
    this.concessions = const [],
  });
}
