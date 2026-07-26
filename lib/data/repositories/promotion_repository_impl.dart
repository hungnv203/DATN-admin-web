import '../../domain/entities/promotion.dart';
import '../../domain/repositories/promotion_repository.dart';
import '../datasources/promotion_remote_data_source.dart';
import '../models/promotion_model.dart';

class PromotionRepositoryImpl implements PromotionRepository {
  final PromotionRemoteDataSource remoteDataSource;

  PromotionRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Promotion>> getPromotions() {
    return remoteDataSource.getPromotions();
  }

  @override
  Future<Promotion> createPromotion(Promotion promotion) {
    return remoteDataSource.createPromotion(
      PromotionModel.fromEntity(promotion),
    );
  }

  @override
  Future<void> updatePromotion(Promotion promotion) {
    return remoteDataSource.updatePromotion(
      PromotionModel.fromEntity(promotion),
    );
  }

  @override
  Future<void> deletePromotion(String id) {
    return remoteDataSource.deletePromotion(id);
  }
}
