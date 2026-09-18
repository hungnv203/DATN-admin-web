import '../../domain/entities/movie.dart';

class MovieModel extends Movie {
  const MovieModel({
    required super.id,
    required super.title,
    required super.description,
    required super.duration,
    required super.releaseDate,
    required super.language,
    required super.rating,
    required super.posterUrl,
    required super.status,
    super.genres = const [],
    super.genreIds = const [],
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      duration: json['duration'] is int
          ? json['duration'] as int
          : int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      releaseDate: json['releaseDate'] != null
          ? DateTime.tryParse(json['releaseDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      language: json['language']?.toString() ?? '',
      rating: json['rating']?.toString() ?? '',
      posterUrl: json['posterUrl']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      genreIds: (json['genreIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration': duration,
      'releaseDate': releaseDate.toIso8601String(),
      'language': language,
      'rating': rating,
      'posterUrl': posterUrl,
      'status': status,
      'genres': genres,
      'genreIds': genreIds,
    };
  }
}
