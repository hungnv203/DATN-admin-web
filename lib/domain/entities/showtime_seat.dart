class ShowtimeSeat {
  final String seatId;
  final String rowLabel;
  final int seatNumber;
  final String type; // Standard, VIP, Couple
  final String status; // Available, Reserved, Held
  final String? heldByUserId;

  const ShowtimeSeat({
    required this.seatId,
    required this.rowLabel,
    required this.seatNumber,
    required this.type,
    required this.status,
    this.heldByUserId,
  });
}
