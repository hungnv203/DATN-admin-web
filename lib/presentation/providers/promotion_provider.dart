import 'package:flutter/foundation.dart';
import '../../domain/entities/promotion.dart';
import '../../domain/repositories/promotion_repository.dart';

class PromotionProvider extends ChangeNotifier {
  final PromotionRepository repository;

  PromotionProvider(this.repository);

  List<Promotion> _promotions = const [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Promotion> get promotions => List.unmodifiable(_promotions);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPromotions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _promotions = await repository.getPromotions();
    } catch (error) {
      _errorMessage = _message(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> savePromotion(Promotion promotion) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (promotion.id.isEmpty) {
        await repository.createPromotion(promotion);
      } else {
        await repository.updatePromotion(promotion);
      }
      _promotions = await repository.getPromotions();
      return true;
    } catch (error) {
      _errorMessage = _message(error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePromotion(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await repository.deletePromotion(id);
      _promotions = await repository.getPromotions();
      return true;
    } catch (error) {
      _errorMessage = _message(error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _message(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
