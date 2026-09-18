import '../entities/genre.dart';

abstract class GenreRepository {
  Future<List<Genre>> getGenres();
  Future<Genre> getGenreById(String id);
  Future<Genre> createGenre(String name);
  Future<bool> updateGenre(String id, String name);
  Future<bool> deleteGenre(String id);
}
