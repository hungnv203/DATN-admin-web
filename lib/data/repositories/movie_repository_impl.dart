import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_remote_data_source.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;

  MovieRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Movie>> getMovies() async {
    final movies = await remoteDataSource.getMovies();
    return List<Movie>.from(movies);
  }

  @override
  Future<Movie> createMovie({
    required String title,
    required String description,
    required int duration,
    required DateTime releaseDate,
    required String language,
    required String rating,
    required String posterUrl,
    required String status,
  }) async {
    return await remoteDataSource.createMovie(
      title: title,
      description: description,
      duration: duration,
      releaseDate: releaseDate,
      language: language,
      rating: rating,
      posterUrl: posterUrl,
      status: status,
    );
  }

  @override
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
  }) async {
    return await remoteDataSource.updateMovie(
      id,
      title: title,
      description: description,
      duration: duration,
      releaseDate: releaseDate,
      language: language,
      rating: rating,
      posterUrl: posterUrl,
      status: status,
    );
  }

  @override
  Future<bool> deleteMovie(String id) async {
    return await remoteDataSource.deleteMovie(id);
  }

  @override
  Future<String> uploadPoster(List<int> bytes, String fileName) {
    return remoteDataSource.uploadPoster(bytes, fileName);
  }
}
