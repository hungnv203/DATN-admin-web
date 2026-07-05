import 'package:flutter/material.dart';
import '../../domain/entities/concession.dart';
import '../../domain/repositories/concession_repository.dart';

class ConcessionProvider extends ChangeNotifier {
  final ConcessionRepository repository;

  ConcessionProvider(this.repository);

  List<Concession> _concessions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Concession> get concessions => _concessions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchConcessions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _concessions = await repository.getConcessions();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createConcession({
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required bool isActive,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final concession = await repository.createConcession(
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        isActive: isActive,
      );
      _concessions.add(concession);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateConcession(
    String id, {
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required bool isActive,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await repository.updateConcession(
        id,
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        isActive: isActive,
      );
      if (success) {
        final index = _concessions.indexWhere((item) => item.id == id);
        if (index != -1) {
          _concessions[index] = Concession(
            id: id,
            name: name,
            description: description,
            price: price,
            imageUrl: imageUrl,
            isActive: isActive,
          );
        }
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteConcession(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await repository.deleteConcession(id);
      if (success) {
        _concessions.removeWhere((item) => item.id == id);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
