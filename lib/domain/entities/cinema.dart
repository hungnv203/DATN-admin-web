import 'room.dart';

class Cinema {
  final String id;
  final String name;
  final String address;
  final String city;
  final List<Room>? rooms;

  const Cinema({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.rooms,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cinema && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
