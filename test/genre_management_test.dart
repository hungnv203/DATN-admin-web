import 'package:flutter_test/flutter_test.dart';
import 'package:datn_web/domain/entities/genre.dart';
import 'package:datn_web/domain/repositories/genre_repository.dart';
import 'package:datn_web/data/models/genre_model.dart';
import 'package:datn_web/presentation/providers/genre_provider.dart';

class MockGenreRepository implements GenreRepository {
  List<Genre> items = [];
  bool shouldThrow = false;
  String errorMessage = 'Simulated error';

  @override
  Future<List<Genre>> getGenres() async {
    if (shouldThrow) throw Exception(errorMessage);
    return List.from(items);
  }

  @override
  Future<Genre> getGenreById(String id) async {
    if (shouldThrow) throw Exception(errorMessage);
    return items.firstWhere((g) => g.id == id);
  }

  @override
  Future<Genre> createGenre(String name) async {
    if (shouldThrow) throw Exception(errorMessage);
    final created = Genre(id: 'gen-${items.length + 1}', name: name);
    items.add(created);
    return created;
  }

  @override
  Future<bool> updateGenre(String id, String name) async {
    if (shouldThrow) throw Exception(errorMessage);
    final index = items.indexWhere((g) => g.id == id);
    if (index == -1) return false;
    items[index] = Genre(id: id, name: name);
    return true;
  }

  @override
  Future<bool> deleteGenre(String id) async {
    if (shouldThrow) throw Exception(errorMessage);
    final count = items.length;
    items.removeWhere((g) => g.id == id);
    return items.length < count;
  }
}

void main() {
  group('GenreModel Serialization', () {
    test('fromJson parses id and name correctly', () {
      final json = {
        'id': 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'name': 'Hành Động',
      };

      final model = GenreModel.fromJson(json);

      expect(model.id, 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d');
      expect(model.name, 'Hành Động');
    });

    test('fromJson handles null values safely without crashing', () {
      final json = <String, dynamic>{};

      final model = GenreModel.fromJson(json);

      expect(model.id, '');
      expect(model.name, '');
    });

    test('toJson produces expected map', () {
      const model = GenreModel(id: 'test-123', name: 'Hoạt Hình');

      final json = model.toJson();

      expect(json, {
        'id': 'test-123',
        'name': 'Hoạt Hình',
      });
    });
  });

  group('GenreProvider State Management', () {
    late MockGenreRepository repository;
    late GenreProvider provider;

    setUp(() {
      repository = MockGenreRepository();
      provider = GenreProvider(repository);
    });

    test('initial state has empty genres and not loading', () {
      expect(provider.genres, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.searchQuery, isEmpty);
    });

    test('fetchGenres populates genres list on success', () async {
      repository.items = [
        const Genre(id: '1', name: 'Kinh Dị'),
        const Genre(id: '2', name: 'Hài Kịch'),
      ];

      await provider.fetchGenres();

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.genres.length, 2);
      expect(provider.genres[0].name, 'Kinh Dị');
      expect(provider.genres[1].name, 'Hài Kịch');
    });

    test('fetchGenres sets errorMessage on failure', () async {
      repository.shouldThrow = true;
      repository.errorMessage = 'Network connection failed';

      await provider.fetchGenres();

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, contains('Network connection failed'));
      expect(provider.genres, isEmpty);
    });

    test('createGenre adds new genre and refreshes list', () async {
      final success = await provider.createGenre('Viễn Tưởng');

      expect(success, isTrue);
      expect(provider.genres.length, 1);
      expect(provider.genres.first.name, 'Viễn Tưởng');
    });

    test('createGenre returns false and records error on failure', () async {
      repository.shouldThrow = true;
      repository.errorMessage = 'Name duplicate';

      final success = await provider.createGenre('Trùng Lặp');

      expect(success, isFalse);
      expect(provider.errorMessage, contains('Name duplicate'));
      expect(provider.genres, isEmpty);
    });

    test('updateGenre updates genre name and refreshes list', () async {
      repository.items = [
        const Genre(id: 'gen-1', name: 'Tâm Lý'),
      ];
      await provider.fetchGenres();

      final success = await provider.updateGenre('gen-1', 'Tâm Lý Xã Hội');

      expect(success, isTrue);
      expect(provider.genres.first.name, 'Tâm Lý Xã Hội');
    });

    test('deleteGenre removes genre from list', () async {
      repository.items = [
        const Genre(id: 'gen-1', name: 'Phiêu Lưu'),
        const Genre(id: 'gen-2', name: 'Tài Liệu'),
      ];
      await provider.fetchGenres();
      expect(provider.genres.length, 2);

      final success = await provider.deleteGenre('gen-1');

      expect(success, isTrue);
      expect(provider.genres.length, 1);
      expect(provider.genres.first.id, 'gen-2');
    });

    test('filteredGenres filters by search keyword (case-insensitive)', () async {
      repository.items = [
        const Genre(id: 'id-1', name: 'Hành Động'),
        const Genre(id: 'id-2', name: 'Hài Kịch'),
        const Genre(id: 'id-3', name: 'Kinh Dị'),
      ];
      await provider.fetchGenres();

      provider.setSearchQuery('hành');
      expect(provider.filteredGenres.length, 1);
      expect(provider.filteredGenres.first.name, 'Hành Động');

      provider.setSearchQuery('kịch');
      expect(provider.filteredGenres.length, 1);
      expect(provider.filteredGenres.first.name, 'Hài Kịch');

      provider.setSearchQuery('không-tồn-tại');
      expect(provider.filteredGenres, isEmpty);

      provider.clearSearchQuery();
      expect(provider.filteredGenres.length, 3);
    });
  });
}
