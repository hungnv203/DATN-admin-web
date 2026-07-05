import '../../domain/entities/concession.dart';
import '../../domain/repositories/concession_repository.dart';
import '../datasources/concession_remote_data_source.dart';

class ConcessionRepositoryImpl implements ConcessionRepository {
  final ConcessionRemoteDataSource remoteDataSource;

  ConcessionRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Concession>> getConcessions() async {
    return await remoteDataSource.getConcessions();
  }

  @override
  Future<Concession> createConcession({
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required bool isActive,
  }) async {
    return await remoteDataSource.createConcession(
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      isActive: isActive,
    );
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
    return await remoteDataSource.updateConcession(
      id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      isActive: isActive,
    );
  }

  @override
  Future<bool> deleteConcession(String id) async {
    return await remoteDataSource.deleteConcession(id);
  }
}
