import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/genre_model.dart';

abstract class GenreRemoteDataSource {
  Future<List<GenreModel>> getGenres();
  Future<GenreModel> getGenreById(String id);
  Future<GenreModel> createGenre(String name);
  Future<bool> updateGenre(String id, String name);
  Future<bool> deleteGenre(String id);
}

class GenreRemoteDataSourceImpl implements GenreRemoteDataSource {
  final DioClient client;

  GenreRemoteDataSourceImpl(this.client);

  @override
  Future<List<GenreModel>> getGenres() async {
    final response = await client.get(ApiConstants.genres);
    final List<dynamic> data = response.data;
    return data.map((json) => GenreModel.fromJson(json)).toList();
  }

  @override
  Future<GenreModel> getGenreById(String id) async {
    final response = await client.get('${ApiConstants.genres}/$id');
    return GenreModel.fromJson(response.data);
  }

  @override
  Future<GenreModel> createGenre(String name) async {
    final response = await client.post(
      ApiConstants.genres,
      data: {'name': name},
    );
    return GenreModel.fromJson(response.data);
  }

  @override
  Future<bool> updateGenre(String id, String name) async {
    final response = await client.put(
      '${ApiConstants.genres}/$id',
      data: {'id': id, 'name': name},
    );
    return response.statusCode == 204 || response.statusCode == 200;
  }

  @override
  Future<bool> deleteGenre(String id) async {
    final response = await client.delete('${ApiConstants.genres}/$id');
    return response.statusCode == 204 || response.statusCode == 200;
  }
}
