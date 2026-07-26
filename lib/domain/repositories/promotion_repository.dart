import '../entities/promotion.dart';

abstract class PromotionRepository {
  Future<List<Promotion>> getPromotions();
  Future<Promotion> createPromotion(Promotion promotion);
  Future<void> updatePromotion(Promotion promotion);
  Future<void> deletePromotion(String id);
}
