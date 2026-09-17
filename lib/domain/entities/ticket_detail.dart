class TicketDetail {
  final String id;
  final String bookingId;
  final String seatId;
  final double price;
  final String qrCode;
  final String status;
  final String movieTitle;
  final String seatLabel;
  final String paymentStatus;
  final DateTime createdAt;
  final String cinemaName;
  final String roomName;
  final DateTime startTime;
  final String customerName;
  final String customerEmail;

  const TicketDetail({
    required this.id,
    required this.bookingId,
    required this.seatId,
    required this.price,
    required this.qrCode,
    required this.status,
    required this.movieTitle,
    required this.seatLabel,
    required this.paymentStatus,
    required this.createdAt,
    required this.cinemaName,
    required this.roomName,
    required this.startTime,
    required this.customerName,
    required this.customerEmail,
  });
}
