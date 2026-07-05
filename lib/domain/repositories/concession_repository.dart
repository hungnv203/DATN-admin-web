import '../entities/concession.dart';

abstract class ConcessionRepository {
  Future<List<Concession>> getConcessions();
  Future<Concession> createConcession({
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
