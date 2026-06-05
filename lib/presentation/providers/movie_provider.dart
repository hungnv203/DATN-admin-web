import 'package:flutter/material.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';

class MovieProvider extends ChangeNotifier {
  final MovieRepository repository;

  List<Movie> _movies = [];
  bool _isLoading = false;
  String? _errorMessage;

  MovieProvider(this.repository);

  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMovies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _movies = await repository.getMovies();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> createMovie({
    required String title,
    required String description,
    required int duration,
    required DateTime releaseDate,
    required String language,
    required String rating,
    required String posterUrl,
    required String status,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newMovie = await repository.createMovie(
        title: title,
        description: description,
        duration: duration,
        releaseDate: releaseDate,
        language: language,
        rating: rating,
        posterUrl: posterUrl,
        status: status,
      );
      _movies.add(newMovie);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMovie(
    String id, {
    required String title,
    required String description,
    required int duration,
    required DateTime releaseDate,
    required String language,
    required String rating,
    required String posterUrl,
    required String status,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await repository.updateMovie(
        id,
        title: title,
        description: description,
        duration: duration,
        releaseDate: releaseDate,
        language: language,
        rating: rating,
        posterUrl: posterUrl,
        status: status,
      );
      if (success) {
        final index = _movies.indexWhere((m) => m.id == id);
        if (index != -1) {
          _movies[index] = Movie(
            id: id,
            title: title,
            description: description,
            duration: duration,
            releaseDate: releaseDate,
            language: language,
            rating: rating,
            posterUrl: posterUrl,
            status: status,
          );
        }
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMovie(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await repository.deleteMovie(id);
      if (success) {
        _movies.removeWhere((m) => m.id == id);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<String> uploadPoster(List<int> bytes, String fileName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final url = await repository.uploadPoster(bytes, fileName);
      _isLoading = false;
      notifyListeners();
      return url;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return '';
    }
  }
}
