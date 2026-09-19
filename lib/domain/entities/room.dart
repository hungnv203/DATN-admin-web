class Room {
  final String id;
  final String cinemaId;
  final String name;
  final int totalSeats;
  final String type;

  const Room({
    required this.id,
    required this.cinemaId,
    required this.name,
    required this.totalSeats,
    required this.type,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Room && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
