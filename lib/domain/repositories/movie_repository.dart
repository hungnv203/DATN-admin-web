import '../entities/movie.dart';

abstract class MovieRepository {
  Future<List<Movie>> getMovies();
  Future<Movie> createMovie({
    required String title,
    required String description,
    required int duration,
    required DateTime releaseDate,
    required String language,
    required String rating,
    required String posterUrl,
    required String status,
  });
  Future<bool> updateMovie(
    String id, {
    required String title,
    required String description,
    required int duration,
    required DateTime releaseDate,
    required String language,
    required String rating,
    required String posterUrl,
    required String status,
  });
  Future<bool> deleteMovie(String id);
  Future<String> uploadPoster(List<int> bytes, String fileName);
}
