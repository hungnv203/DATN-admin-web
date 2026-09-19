import 'package:flutter_test/flutter_test.dart';
import 'package:datn_web/domain/entities/cinema.dart';
import 'package:datn_web/domain/entities/room.dart';
import 'package:datn_web/domain/entities/movie.dart';
import 'package:datn_web/domain/entities/showtime.dart';
import 'package:datn_web/domain/entities/showtime_seat.dart';
import 'package:datn_web/domain/repositories/showtime_repository.dart';
import 'package:datn_web/presentation/providers/showtime_provider.dart';

class MockShowtimeRepository implements ShowtimeRepository {
  final List<Showtime> items = [];
  bool shouldThrow = false;
  String errorMessage = 'Simulated repository error';

  @override
  Future<List<Showtime>> getShowtimes() async {
    if (shouldThrow) throw Exception(errorMessage);
    return List.from(items);
  }

  @override
  Future<Showtime> createShowtime({
    required String movieId,
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    required double basePrice,
    required String status,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
    final created = Showtime(
      id: 'st-${items.length + 1}',
      movieId: movieId,
      roomId: roomId,
      startTime: startTime,
      endTime: endTime,
      basePrice: basePrice,
      status: status,
    );
    items.add(created);
    return created;
  }

  @override
  Future<bool> updateShowtime(
    String id, {
    required String movieId,
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    required double basePrice,
    required String status,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
    final index = items.indexWhere((s) => s.id == id);
    if (index == -1) return false;
    items[index] = Showtime(
      id: id,
      movieId: movieId,
      roomId: roomId,
      startTime: startTime,
      endTime: endTime,
      basePrice: basePrice,
      status: status,
    );
    return true;
  }

  @override
  Future<bool> deleteShowtime(String id) async {
    if (shouldThrow) throw Exception(errorMessage);
    final prevCount = items.length;
    items.removeWhere((s) => s.id == id);
    return items.length < prevCount;
  }

  @override
  Future<List<ShowtimeSeat>> getSeatsForShowtime(String showtimeId) async {
    if (shouldThrow) throw Exception(errorMessage);
    return [];
  }
}

void main() {
  group('Entity Value Equality and HashCode', () {
    test('Cinema equality is based on id', () {
      const c1 = Cinema(id: 'c1', name: 'CGV Vincom', address: '123 Str', city: 'HN');
      const c2 = Cinema(id: 'c1', name: 'CGV Vincom Renamed', address: '456 Str', city: 'HCM');
      const c3 = Cinema(id: 'c2', name: 'CGV Vincom', address: '123 Str', city: 'HN');

      expect(c1, equals(c2));
      expect(c1.hashCode, equals(c2.hashCode));
      expect(c1 == c3, isFalse);
    });

    test('Room equality is based on id', () {
      const r1 = Room(id: 'r1', cinemaId: 'c1', name: 'Phòng 1', totalSeats: 100, type: '2D');
      const r2 = Room(id: 'r1', cinemaId: 'c2', name: 'Phòng VIP', totalSeats: 50, type: '3D');
      const r3 = Room(id: 'r2', cinemaId: 'c1', name: 'Phòng 1', totalSeats: 100, type: '2D');

      expect(r1, equals(r2));
      expect(r1.hashCode, equals(r2.hashCode));
      expect(r1 == r3, isFalse);
    });

    test('Movie equality is based on id', () {
      final now = DateTime.now();
      final m1 = Movie(
        id: 'm1',
        title: 'Avatar',
        description: 'Sci-fi',
        duration: 180,
        releaseDate: now,
        language: 'EN',
        rating: 'P',
        posterUrl: '',
        status: 'Active',
      );
      final m2 = Movie(
        id: 'm1',
        title: 'Avatar 2',
        description: 'Another',
        duration: 190,
        releaseDate: now,
        language: 'VI',
        rating: 'C13',
        posterUrl: '',
        status: 'Active',
      );
      final m3 = Movie(
        id: 'm2',
        title: 'Avatar',
        description: 'Sci-fi',
        duration: 180,
        releaseDate: now,
        language: 'EN',
        rating: 'P',
        posterUrl: '',
        status: 'Active',
      );

      expect(m1, equals(m2));
      expect(m1.hashCode, equals(m2.hashCode));
      expect(m1 == m3, isFalse);
    });
  });

  group('ShowtimeProvider Create and Update Operations', () {
    late MockShowtimeRepository repository;
    late ShowtimeProvider provider;

    setUp(() {
      repository = MockShowtimeRepository();
      provider = ShowtimeProvider(repository);
    });

    test('createShowtime creates showtime and refreshes list', () async {
      final start = DateTime(2026, 9, 20, 14, 0);
      final end = DateTime(2026, 9, 20, 16, 30);

      final success = await provider.createShowtime(
        movieId: 'm-1',
        roomId: 'r-1',
        startTime: start,
        endTime: end,
        basePrice: 90000,
        status: 'Active',
      );

      expect(success, isTrue);
      expect(provider.showtimes.length, 1);
      expect(provider.showtimes.first.movieId, 'm-1');
      expect(provider.showtimes.first.roomId, 'r-1');
      expect(provider.showtimes.first.basePrice, 90000);
      expect(provider.showtimes.first.status, 'Active');
    });

    test('updateShowtime modifies fields including roomId, times, and price', () async {
      final start = DateTime(2026, 9, 20, 14, 0);
      final end = DateTime(2026, 9, 20, 16, 30);
      await provider.createShowtime(
        movieId: 'm-1',
        roomId: 'r-1',
        startTime: start,
        endTime: end,
        basePrice: 85000,
        status: 'Active',
      );

      final showtimeId = provider.showtimes.first.id;
      final newStart = DateTime(2026, 9, 21, 18, 0);
      final newEnd = DateTime(2026, 9, 21, 20, 45);

      final updateSuccess = await provider.updateShowtime(
        showtimeId,
        movieId: 'm-2',
        roomId: 'r-2',
        startTime: newStart,
        endTime: newEnd,
        basePrice: 100000,
        status: 'Scheduled',
      );

      expect(updateSuccess, isTrue);
      expect(provider.showtimes.first.movieId, 'm-2');
      expect(provider.showtimes.first.roomId, 'r-2');
      expect(provider.showtimes.first.basePrice, 100000);
      expect(provider.showtimes.first.status, 'Scheduled');
      expect(provider.showtimes.first.startTime, newStart);
    });

    test('handles repository errors gracefully during showtime creation', () async {
      repository.shouldThrow = true;
      repository.errorMessage = 'Conflict: Khung giờ đã có suất chiếu khác';

      final success = await provider.createShowtime(
        movieId: 'm-1',
        roomId: 'r-1',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 2)),
        basePrice: 85000,
        status: 'Active',
      );

      expect(success, isFalse);
      expect(provider.errorMessage, contains('Conflict'));
    });
  });

  group('Showtime Filter Logic', () {
    const rooms = [
      Room(id: 'r1', cinemaId: 'c1', name: 'Phòng 1', totalSeats: 100, type: '2D'),
      Room(id: 'r2', cinemaId: 'c1', name: 'Phòng 2', totalSeats: 100, type: '3D'),
      Room(id: 'r3', cinemaId: 'c2', name: 'Phòng VIP', totalSeats: 50, type: 'VIP'),
    ];

    final showtimes = [
      Showtime(
        id: 's1',
        movieId: 'm1',
        roomId: 'r1',
        startTime: DateTime(2026, 9, 20, 10, 0),
        endTime: DateTime(2026, 9, 20, 12, 0),
        basePrice: 80000,
        status: 'Active',
      ),
      Showtime(
        id: 's2',
        movieId: 'm2',
        roomId: 'r2',
        startTime: DateTime(2026, 9, 20, 14, 0),
        endTime: DateTime(2026, 9, 20, 16, 0),
        basePrice: 85000,
        status: 'Active',
      ),
      Showtime(
        id: 's3',
        movieId: 'm1',
        roomId: 'r3',
        startTime: DateTime(2026, 9, 21, 10, 0),
        endTime: DateTime(2026, 9, 21, 12, 0),
        basePrice: 120000,
        status: 'Active',
      ),
    ];

    List<Showtime> filterShowtimes({
      Cinema? selectedCinema,
      Room? selectedRoom,
      DateTime? selectedDate,
    }) {
      return showtimes.where((s) {
        if (selectedCinema != null) {
          final room = rooms.firstWhere(
            (r) => r.id == s.roomId,
            orElse: () => const Room(
              id: '',
              cinemaId: '',
              name: '',
              totalSeats: 0,
              type: '',
            ),
          );
          if (room.cinemaId != selectedCinema.id) return false;
        }

        if (selectedRoom != null) {
          if (s.roomId != selectedRoom.id) return false;
        }

        if (selectedDate != null) {
          return s.startTime.year == selectedDate.year &&
              s.startTime.month == selectedDate.month &&
              s.startTime.day == selectedDate.day;
        }

        return true;
      }).toList();
    }

    test('default initially with no filters returns all showtimes', () {
      final results = filterShowtimes(
        selectedCinema: null,
        selectedRoom: null,
        selectedDate: null,
      );
      expect(results.length, 3);
    });

    test('filtering by cinema returns only showtimes in rooms of that cinema', () {
      const cinema1 = Cinema(id: 'c1', name: 'Rạp 1', address: '', city: '');
      final results = filterShowtimes(selectedCinema: cinema1);
      expect(results.length, 2);
      expect(results.map((s) => s.id), containsAll(['s1', 's2']));
    });

    test('filtering by room returns only showtimes in that room', () {
      const room2 = Room(id: 'r2', cinemaId: 'c1', name: 'Phòng 2', totalSeats: 100, type: '3D');
      final results = filterShowtimes(selectedRoom: room2);
      expect(results.length, 1);
      expect(results.first.id, 's2');
    });

    test('filtering by date returns only showtimes on that date', () {
      final targetDate = DateTime(2026, 9, 21);
      final results = filterShowtimes(selectedDate: targetDate);
      expect(results.length, 1);
      expect(results.first.id, 's3');
    });

    test('combined filter works accurately', () {
      const cinema1 = Cinema(id: 'c1', name: 'Rạp 1', address: '', city: '');
      final targetDate = DateTime(2026, 9, 20);
      const room1 = Room(id: 'r1', cinemaId: 'c1', name: 'Phòng 1', totalSeats: 100, type: '2D');

      final results = filterShowtimes(
        selectedCinema: cinema1,
        selectedRoom: room1,
        selectedDate: targetDate,
      );
      expect(results.length, 1);
      expect(results.first.id, 's1');
    });
  });
}

