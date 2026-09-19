class Movie {
  final String id;
  final String title;
  final String description;
  final int duration;
  final DateTime releaseDate;
  final String language;
  final String rating;
  final String posterUrl;
  final String status;
  final List<String> genres;
  final List<String> genreIds;

  const Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.releaseDate,
    required this.language,
    required this.rating,
    required this.posterUrl,
    required this.status,
    this.genres = const [],
    this.genreIds = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Movie && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
