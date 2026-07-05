import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/concession_model.dart';

abstract class ConcessionRemoteDataSource {
  Future<List<ConcessionModel>> getConcessions();
  Future<ConcessionModel> createConcession({
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required bool isActive,
  });
  Future<bool> updateConcession(
    String id, {
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required bool isActive,
  });
  Future<bool> deleteConcession(String id);
}

class ConcessionRemoteDataSourceImpl implements ConcessionRemoteDataSource {
  final DioClient client;

  ConcessionRemoteDataSourceImpl(this.client);

  @override
  Future<List<ConcessionModel>> getConcessions() async {
    final response = await client.get(ApiConstants.concessions);
    final List<dynamic> data = response.data;
    return data.map((json) => ConcessionModel.fromJson(json)).toList();
  }

  @override
  Future<ConcessionModel> createConcession({
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required bool isActive,
  }) async {
    final response = await client.post(
      ApiConstants.concessions,
      data: {
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'isActive': isActive,
      },
    );
    return ConcessionModel.fromJson(response.data);
  }

  @override
  Future<bool> updateConcession(
    String id, {
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required bool isActive,
  }) async {
    final response = await client.put(
      '${ApiConstants.concessions}/$id',
      data: {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'isActive': isActive,
      },
    );
    return response.statusCode == 204 || response.statusCode == 200;
  }

  @override
  Future<bool> deleteConcession(String id) async {
    final response = await client.delete('${ApiConstants.concessions}/$id');
    return response.statusCode == 204 || response.statusCode == 200;
  }
}
