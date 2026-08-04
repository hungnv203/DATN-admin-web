class ShowtimeSeat {
  final String seatId;
  final String rowLabel;
  final int seatNumber;
  final String type; // Standard, VIP, Couple
  final String status; // Available, Held, Booked (Reserved is a legacy alias)
  final String? heldByUserId;
  final bool heldByCurrentUser;
  final DateTime? expiresAtUtc;

  const ShowtimeSeat({
    required this.seatId,
    required this.rowLabel,
    required this.seatNumber,
    required this.type,
    required this.status,
    this.heldByUserId,
    this.heldByCurrentUser = false,
    this.expiresAtUtc,
  });

  ShowtimeSeat copyWith({
    String? status,
    bool? heldByCurrentUser,
    DateTime? expiresAtUtc,
  }) => ShowtimeSeat(
    seatId: seatId,
    rowLabel: rowLabel,
    seatNumber: seatNumber,
    type: type,
    status: status ?? this.status,
    heldByUserId: heldByUserId,
    heldByCurrentUser: heldByCurrentUser ?? this.heldByCurrentUser,
    expiresAtUtc: expiresAtUtc,
  );
}
