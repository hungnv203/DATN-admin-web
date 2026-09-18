import '../../domain/entities/genre.dart';
import '../../domain/repositories/genre_repository.dart';
import '../datasources/genre_remote_data_source.dart';

class GenreRepositoryImpl implements GenreRepository {
  final GenreRemoteDataSource remoteDataSource;

  GenreRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Genre>> getGenres() async {
    return await remoteDataSource.getGenres();
  }

  @override
  Future<Genre> getGenreById(String id) async {
    return await remoteDataSource.getGenreById(id);
  }

  @override
  Future<Genre> createGenre(String name) async {
    return await remoteDataSource.createGenre(name);
  }

  @override
  Future<bool> updateGenre(String id, String name) async {
    return await remoteDataSource.updateGenre(id, name);
  }

  @override
  Future<bool> deleteGenre(String id) async {
    return await remoteDataSource.deleteGenre(id);
  }
}
