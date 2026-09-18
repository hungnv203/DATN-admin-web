import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/genre.dart';
import '../../domain/repositories/genre_repository.dart';

class GenreProvider extends ChangeNotifier {
  final GenreRepository repository;

  GenreProvider(this.repository);

  List<Genre> _genres = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<Genre> get genres => _genres;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  List<Genre> get filteredGenres {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _genres;
    return _genres.where((g) {
      return g.name.toLowerCase().contains(query) ||
          g.id.toLowerCase().contains(query);
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> fetchGenres() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _genres = await repository.getGenres();
    } catch (e) {
      _errorMessage = _parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createGenre(String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await repository.createGenre(name.trim());
      _genres = await repository.getGenres();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateGenre(String id, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await repository.updateGenre(id, name.trim());
      if (success) {
        _genres = await repository.getGenres();
      }
      return success;
    } catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteGenre(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await repository.deleteGenre(id);
      if (success) {
        _genres = await repository.getGenres();
      }
      return success;
    } catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _parseError(dynamic e) {
    if (e is DioException) {
      final response = e.response;
      if (response?.data is Map && response!.data['message'] != null) {
        return response.data['message'].toString();
      }
      if (response?.statusCode == 400) {
        return 'Yêu cầu không hợp lệ hoặc tên thể loại đã tồn tại.';
      }
      if (response?.statusCode == 403) {
        return 'Bạn không có quyền thực hiện thao tác này.';
      }
      if (response?.statusCode == 409) {
        return 'Không thể xóa thể loại vì đang có phim liên kết.';
      }
    }
    return e.toString().replaceAll('Exception: ', '');
  }
}
