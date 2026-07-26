import '../../domain/entities/promotion.dart';

class PromotionModel extends Promotion {
  const PromotionModel({
    required super.id,
    required super.code,
    required super.discountType,
    required super.discountValue,
    required super.startDate,
    required super.endDate,
    required super.minOrder,
    required super.status,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      discountType: json['discountType']?.toString() ?? '',
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0,
      startDate: DateTime.parse(json['startDate'].toString()).toLocal(),
      endDate: DateTime.parse(json['endDate'].toString()).toLocal(),
      minOrder: (json['minOrder'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discountType': discountType,
      'discountValue': discountValue,
      'startDate': startDate.toUtc().toIso8601String(),
      'endDate': endDate.toUtc().toIso8601String(),
      'minOrder': minOrder,
      'status': status,
    };
  }

  factory PromotionModel.fromEntity(Promotion promotion) {
    return PromotionModel(
      id: promotion.id,
      code: promotion.code,
      discountType: promotion.discountType,
      discountValue: promotion.discountValue,
      startDate: promotion.startDate,
      endDate: promotion.endDate,
      minOrder: promotion.minOrder,
      status: promotion.status,
    );
  }
}
