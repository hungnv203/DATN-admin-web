import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/promotion_model.dart';

abstract class PromotionRemoteDataSource {
  Future<List<PromotionModel>> getPromotions();
  Future<PromotionModel> createPromotion(PromotionModel promotion);
  Future<void> updatePromotion(PromotionModel promotion);
  Future<void> deletePromotion(String id);
}

class PromotionRemoteDataSourceImpl implements PromotionRemoteDataSource {
  final DioClient client;

  PromotionRemoteDataSourceImpl(this.client);

  @override
  Future<List<PromotionModel>> getPromotions() async {
    final response = await client.get(ApiConstants.promotions);
    final data = response.data as List<dynamic>;
    return data
        .map(
          (item) =>
              PromotionModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<PromotionModel> createPromotion(PromotionModel promotion) async {
    final payload = promotion.toJson()..remove('id');
    final response = await client.post(ApiConstants.promotions, data: payload);
    return PromotionModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  @override
  Future<void> updatePromotion(PromotionModel promotion) async {
    await client.put(
      '${ApiConstants.promotions}/${promotion.id}',
      data: promotion.toJson(),
    );
  }

  @override
  Future<void> deletePromotion(String id) async {
    await client.delete('${ApiConstants.promotions}/$id');
  }
}
