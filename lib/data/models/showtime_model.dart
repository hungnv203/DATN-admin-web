import '../../domain/entities/showtime.dart';

class ShowtimeModel extends Showtime {
  const ShowtimeModel({
    required super.id,
    required super.movieId,
    required super.roomId,
    required super.startTime,
    required super.endTime,
    required super.basePrice,
    required super.status,
  });

  factory ShowtimeModel.fromJson(Map<String, dynamic> json) {
    return ShowtimeModel(
      id: json['id'] ?? '',
      movieId: json['movieId'] ?? '',
      roomId: json['roomId'] ?? '',
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']).toLocal() : DateTime.now(),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']).toLocal() : DateTime.now(),
      basePrice: (json['basePrice'] ?? 0.0).toDouble(),
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'movieId': movieId,
      'roomId': roomId,
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
      'basePrice': basePrice,
      'status': status,
    };
  }
}
