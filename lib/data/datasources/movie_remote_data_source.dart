import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/movie_model.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getMovies({String? genreId});
  Future<MovieModel> createMovie({
    required String title,
    required String description,
    required int duration,
    required DateTime releaseDate,
    required String language,
    required String rating,
    required String posterUrl,
    required String status,
    List<String>? genreIds,
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
    List<String>? genreIds,
  });
  Future<bool> deleteMovie(String id);
  Future<String> uploadPoster(List<int> bytes, String fileName);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final DioClient client;

  MovieRemoteDataSourceImpl(this.client);

  @override
  Future<List<MovieModel>> getMovies({String? genreId}) async {
    final uri = (genreId != null && genreId.isNotEmpty)
        ? '${ApiConstants.movies}?genreId=$genreId'
        : ApiConstants.movies;
    final response = await client.get(uri);
    final List<dynamic> data = response.data;
    return data.map((json) => MovieModel.fromJson(json)).toList();
  }

  @override
  Future<MovieModel> createMovie({
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
    final response = await client.post(
      ApiConstants.movies,
      data: {
        'title': title,
        'description': description,
        'duration': duration,
        'releaseDate': releaseDate.toIso8601String(),
        'language': language,
        'rating': rating,
        'posterUrl': posterUrl,
        'status': status,
        if (genreIds != null) 'genreIds': genreIds,
      },
    );
    return MovieModel.fromJson(response.data);
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
    final response = await client.put(
      '${ApiConstants.movies}/$id',
      data: {
        'id': id,
        'title': title,
        'description': description,
        'duration': duration,
        'releaseDate': releaseDate.toIso8601String(),
        'language': language,
        'rating': rating,
        'posterUrl': posterUrl,
        'status': status,
        if (genreIds != null) 'genreIds': genreIds,
      },
    );
    return response.statusCode == 204 || response.statusCode == 200;
  }

  @override
  Future<bool> deleteMovie(String id) async {
    final response = await client.delete('${ApiConstants.movies}/$id');
    return response.statusCode == 204 || response.statusCode == 200;
  }

  @override
  Future<String> uploadPoster(List<int> bytes, String fileName) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });

    final response = await client.post(
      ApiConstants.upload,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return response.data['url'] ?? '';
  }
}
