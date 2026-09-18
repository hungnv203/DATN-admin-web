import 'package:flutter_test/flutter_test.dart';
import 'package:datn_web/domain/entities/movie.dart';
import 'package:datn_web/domain/repositories/movie_repository.dart';
import 'package:datn_web/data/models/movie_model.dart';
import 'package:datn_web/presentation/providers/movie_provider.dart';

class MockMovieRepository implements MovieRepository {
  List<Movie> movies = [];
  bool shouldThrow = false;
  String errorMessage = 'Simulated repository error';

  String? lastFetchedGenreId;
  List<String>? lastCreatedGenreIds;
  List<String>? lastUpdatedGenreIds;

  @override
  Future<List<Movie>> getMovies({String? genreId}) async {
    lastFetchedGenreId = genreId;
    if (shouldThrow) throw Exception(errorMessage);
    if (genreId == null || genreId.isEmpty) {
      return List.from(movies);
    }
    return movies.where((m) => m.genreIds.contains(genreId)).toList();
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
    List<String>? genreIds,
  }) async {
    lastCreatedGenreIds = genreIds;
    if (shouldThrow) throw Exception(errorMessage);
    final newMovie = Movie(
      id: 'movie-${movies.length + 1}',
      title: title,
      description: description,
      duration: duration,
      releaseDate: releaseDate,
      language: language,
      rating: rating,
      posterUrl: posterUrl,
      status: status,
      genres: const [],
      genreIds: genreIds ?? const [],
    );
    movies.add(newMovie);
    return newMovie;
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
    List<String>? genreIds,
  }) async {
    lastUpdatedGenreIds = genreIds;
    if (shouldThrow) throw Exception(errorMessage);
    final index = movies.indexWhere((m) => m.id == id);
    if (index == -1) return false;
    movies[index] = Movie(
      id: id,
      title: title,
      description: description,
      duration: duration,
      releaseDate: releaseDate,
      language: language,
      rating: rating,
      posterUrl: posterUrl,
      status: status,
      genres: movies[index].genres,
      genreIds: genreIds ?? const [],
    );
    return true;
  }

  @override
  Future<bool> deleteMovie(String id) async {
    if (shouldThrow) throw Exception(errorMessage);
    final initialCount = movies.length;
    movies.removeWhere((m) => m.id == id);
    return movies.length < initialCount;
  }

  @override
  Future<String> uploadPoster(List<int> bytes, String fileName) async {
    if (shouldThrow) throw Exception(errorMessage);
    return 'https://cinema.test/posters/$fileName';
  }
}

void main() {
  group('MovieModel Genre Serialization', () {
    test('fromJson parses genres and genreIds successfully', () {
      final json = {
        'id': 'm1',
        'title': 'Dune: Part Two',
        'description': 'Paul Atreides unites with Chani.',
        'duration': 166,
        'releaseDate': '2024-03-01T00:00:00.000Z',
        'language': 'English',
        'rating': 'T16',
        'posterUrl': 'https://test.com/dune.jpg',
        'status': 'NowShowing',
        'genres': ['Hành Động', 'Khoa Học Viễn Tưởng'],
        'genreIds': ['gen-1', 'gen-2'],
      };

      final movie = MovieModel.fromJson(json);

      expect(movie.id, 'm1');
      expect(movie.title, 'Dune: Part Two');
      expect(movie.genres, equals(['Hành Động', 'Khoa Học Viễn Tưởng']));
      expect(movie.genreIds, equals(['gen-1', 'gen-2']));
    });

    test('fromJson handles null or missing genres safely', () {
      final json = {
        'id': 'm2',
        'title': 'Mai',
        'description': 'Phim Trấn Thành',
        'duration': 131,
        'releaseDate': '2024-02-10T00:00:00.000Z',
        'language': 'Tiếng Việt',
        'rating': 'T18',
        'posterUrl': '',
        'status': 'Finished',
      };

      final movie = MovieModel.fromJson(json);

      expect(movie.genres, isEmpty);
      expect(movie.genreIds, isEmpty);
    });

    test('toJson includes genres and genreIds', () {
      final model = MovieModel(
        id: 'm3',
        title: 'Lật Mặt 7',
        description: 'Một điều ước',
        duration: 138,
        releaseDate: DateTime(2024, 4, 26),
        language: 'Tiếng Việt',
        rating: 'K',
        posterUrl: 'https://test.com/latmat7.jpg',
        status: 'NowShowing',
        genres: const ['Gia đình', 'Tâm lý'],
        genreIds: const ['gen-family', 'gen-drama'],
      );

      final json = model.toJson();

      expect(json['id'], 'm3');
      expect(json['genres'], equals(['Gia đình', 'Tâm lý']));
      expect(json['genreIds'], equals(['gen-family', 'gen-drama']));
    });
  });

  group('MovieProvider Genre Integration', () {
    late MockMovieRepository repo;
    late MovieProvider provider;

    setUp(() {
      repo = MockMovieRepository();
      repo.movies = [
        Movie(
          id: 'm-action',
          title: 'Action Movie',
          description: 'Boom',
          duration: 120,
          releaseDate: DateTime(2024, 1, 1),
          language: 'Tiếng Việt',
          rating: 'T16',
          posterUrl: '',
          status: 'NowShowing',
          genres: const ['Hành Động'],
          genreIds: const ['gen-action'],
        ),
        Movie(
          id: 'm-comedy',
          title: 'Comedy Movie',
          description: 'Haha',
          duration: 90,
          releaseDate: DateTime(2024, 1, 1),
          language: 'Tiếng Việt',
          rating: 'P',
          posterUrl: '',
          status: 'NowShowing',
          genres: const ['Hài Hước'],
          genreIds: const ['gen-comedy'],
        ),
      ];
      provider = MovieProvider(repo);
    });

    test('fetchMovies with genreId filters movies and records selectedGenreId', () async {
      await provider.fetchMovies(genreId: 'gen-action');

      expect(provider.selectedGenreId, 'gen-action');
      expect(provider.movies.length, 1);
      expect(provider.movies.first.title, 'Action Movie');
      expect(repo.lastFetchedGenreId, 'gen-action');
    });

    test('fetchMovies with null genreId returns all movies', () async {
      await provider.fetchMovies();

      expect(provider.selectedGenreId, isNull);
      expect(provider.movies.length, 2);
      expect(repo.lastFetchedGenreId, isNull);
    });

    test('createMovie passes genreIds and refreshes with current filter', () async {
      final success = await provider.createMovie(
        title: 'New Sci-Fi Movie',
        description: 'Space travel',
        duration: 150,
        releaseDate: DateTime.now(),
        language: 'Tiếng Việt',
        rating: 'T13',
        posterUrl: '',
        status: 'Upcoming',
        genreIds: ['gen-scifi', 'gen-action'],
      );

      expect(success, isTrue);
      expect(repo.lastCreatedGenreIds, equals(['gen-scifi', 'gen-action']));
      expect(repo.movies.length, 3);
      expect(repo.movies.last.genreIds, equals(['gen-scifi', 'gen-action']));
    });

    test('updateMovie passes genreIds to repository', () async {
      final success = await provider.updateMovie(
        'm-action',
        title: 'Action Movie Updated',
        description: 'Boom Boom',
        duration: 125,
        releaseDate: DateTime.now(),
        language: 'Tiếng Việt',
        rating: 'T18',
        posterUrl: '',
        status: 'NowShowing',
        genreIds: ['gen-action', 'gen-thriller'],
      );

      expect(success, isTrue);
      expect(repo.lastUpdatedGenreIds, equals(['gen-action', 'gen-thriller']));
      final updated = repo.movies.firstWhere((m) => m.id == 'm-action');
      expect(updated.title, 'Action Movie Updated');
      expect(updated.genreIds, equals(['gen-action', 'gen-thriller']));
    });

    test('createMovie handles repository exception gracefully', () async {
      repo.shouldThrow = true;

      final success = await provider.createMovie(
        title: 'Failing Movie',
        description: 'Will fail',
        duration: 100,
        releaseDate: DateTime.now(),
        language: 'Tiếng Việt',
        rating: 'P',
        posterUrl: '',
        status: 'NowShowing',
        genreIds: ['gen-action'],
      );

      expect(success, isFalse);
      expect(provider.errorMessage, isNotNull);
      expect(provider.isLoading, isFalse);
    });
  });
}
