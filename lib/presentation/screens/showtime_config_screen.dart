import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/cinema.dart';
import '../../domain/entities/room.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/showtime.dart';
import '../providers/cinema_provider.dart';
import '../providers/movie_provider.dart';
import '../providers/showtime_provider.dart';

class ShowtimeConfigScreen extends StatefulWidget {
  const ShowtimeConfigScreen({super.key});

  @override
  State<ShowtimeConfigScreen> createState() => _ShowtimeConfigScreenState();
}

class _ShowtimeConfigScreenState extends State<ShowtimeConfigScreen> {
  Cinema? _selectedCinema;
  Room? _selectedRoom;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cinemaProvider = Provider.of<CinemaProvider>(
        context,
        listen: false,
      );
      final movieProvider = Provider.of<MovieProvider>(context, listen: false);
      final showtimeProvider = Provider.of<ShowtimeProvider>(
        context,
        listen: false,
      );

      await Future.wait([
        cinemaProvider.fetchCinemas(),
        cinemaProvider.fetchRooms(),
        movieProvider.fetchMovies(),
        showtimeProvider.fetchShowtimes(),
      ]);
      // Default: No initial filter set! Shows all showtimes.
    });
  }

  @override
  Widget build(BuildContext context) {
    final cinemaProvider = Provider.of<CinemaProvider>(context);
    final movieProvider = Provider.of<MovieProvider>(context);
    final showtimeProvider = Provider.of<ShowtimeProvider>(context);

    final rooms = _selectedCinema == null
        ? cinemaProvider.rooms
        : cinemaProvider.rooms
              .where((r) => r.cinemaId == _selectedCinema!.id)
              .toList();

    // Filter showtimes by Cinema, Room, and Date (all optional!)
    final filteredShowtimes = showtimeProvider.showtimes.where((s) {
      if (_selectedCinema != null) {
        final room = cinemaProvider.rooms.firstWhere(
          (r) => r.id == s.roomId,
          orElse: () => const Room(
            id: '',
            cinemaId: '',
            name: '',
            totalSeats: 0,
            type: '',
          ),
        );
        if (room.cinemaId != _selectedCinema!.id) return false;
      }

      if (_selectedRoom != null) {
        if (s.roomId != _selectedRoom!.id) return false;
      }

      if (_selectedDate != null) {
        return s.startTime.year == _selectedDate!.year &&
            s.startTime.month == _selectedDate!.month &&
            s.startTime.day == _selectedDate!.day;
      }

      return true;
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));

    final bool hasActiveFilter =
        _selectedCinema != null ||
        _selectedRoom != null ||
        _selectedDate != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1015),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quản Lý Lịch Chiếu Phim',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Thiết lập giờ chiếu, phòng chiếu và giá vé cơ bản cho các phim',
                      style: TextStyle(color: Color(0xFFC5C6C7), fontSize: 14),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddShowtimeDialog(
                    movies: movieProvider.movies,
                    cinemas: cinemaProvider.cinemas,
                    allRooms: cinemaProvider.rooms,
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Thêm suất chiếu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF66FCF1),
                    foregroundColor: const Color(0xFF0B0C10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    disabledBackgroundColor: Colors.grey.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Filter Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF16171E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                children: [
                  // Cinema Selection
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chi nhánh rạp',
                          style: TextStyle(
                            color: Color(0xFFC5C6C7),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<Cinema?>(
                          dropdownColor: const Color(0xFF16171E),
                          value: cinemaProvider.cinemas.any(
                                (c) => c.id == _selectedCinema?.id,
                              )
                              ? cinemaProvider.cinemas.firstWhere(
                                  (c) => c.id == _selectedCinema?.id,
                                )
                              : null,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<Cinema?>(
                              value: null,
                              child: Text(
                                'Tất cả chi nhánh',
                                style: TextStyle(
                                  color: Color(0xFF66FCF1),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            ...cinemaProvider.cinemas.map((c) {
                              return DropdownMenuItem<Cinema?>(
                                value: c,
                                child: Text(
                                  c.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _selectedCinema = val;
                              _selectedRoom = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Room Selection
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Phòng chiếu',
                          style: TextStyle(
                            color: Color(0xFFC5C6C7),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<Room?>(
                          dropdownColor: const Color(0xFF16171E),
                          value: rooms.any((r) => r.id == _selectedRoom?.id)
                              ? rooms.firstWhere(
                                  (r) => r.id == _selectedRoom?.id,
                                )
                              : null,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<Room?>(
                              value: null,
                              child: Text(
                                'Tất cả phòng chiếu',
                                style: TextStyle(
                                  color: Color(0xFF66FCF1),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            ...rooms.map((r) {
                              return DropdownMenuItem<Room?>(
                                value: r,
                                child: Text(
                                  '${r.name} (${r.type})',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _selectedRoom = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Date Picker Trigger
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ngày chiếu',
                          style: TextStyle(
                            color: Color(0xFFC5C6C7),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate ?? DateTime.now(),
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 365),
                              ),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                              builder: (ctx, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Color(0xFF66FCF1),
                                      surface: Color(0xFF16171E),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedDate != null
                                      ? DateFormat('dd/MM/yyyy')
                                          .format(_selectedDate!)
                                      : 'Tất cả các ngày',
                                  style: TextStyle(
                                    color: _selectedDate != null
                                        ? Colors.white
                                        : const Color(0xFF66FCF1),
                                    fontSize: 14,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_selectedDate != null)
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedDate = null;
                                          });
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.only(right: 8),
                                          child: Icon(
                                            Icons.close,
                                            color: Color(0xFFC5C6C7),
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    const Icon(
                                      Icons.calendar_today,
                                      color: Color(0xFF66FCF1),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Clear Filter Button if active
                  if (hasActiveFilter) ...[
                    const SizedBox(width: 16),
                    Padding(
                      padding: const EdgeInsets.only(top: 22),
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedCinema = null;
                            _selectedRoom = null;
                            _selectedDate = null;
                          });
                        },
                        icon: const Icon(
                          Icons.filter_alt_off,
                          size: 16,
                          color: Colors.amberAccent,
                        ),
                        label: const Text(
                          'Xóa lọc',
                          style: TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Showtimes List (Timeline view)
            Expanded(
              child: showtimeProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF66FCF1),
                      ),
                    )
                  : filteredShowtimes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.hourglass_empty,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            hasActiveFilter
                                ? 'Không có suất chiếu nào phù hợp với bộ lọc đã chọn.'
                                : 'Hiện tại chưa có suất chiếu nào được lên lịch.',
                            style: const TextStyle(color: Color(0xFFC5C6C7)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredShowtimes.length,
                      itemBuilder: (ctx, index) {
                        final showtime = filteredShowtimes[index];
                        final movie = movieProvider.movies.firstWhere(
                          (m) => m.id == showtime.movieId,
                          orElse: () => Movie(
                            id: '',
                            title: 'Phim không xác định',
                            description: '',
                            duration: 0,
                            releaseDate: DateTime.now(),
                            language: '',
                            rating: '',
                            posterUrl: '',
                            status: '',
                          ),
                        );

                        final room = cinemaProvider.rooms.firstWhere(
                          (r) => r.id == showtime.roomId,
                          orElse: () => const Room(
                            id: '',
                            cinemaId: '',
                            name: 'Phòng không xác định',
                            totalSeats: 0,
                            type: '',
                          ),
                        );

                        final cinema = cinemaProvider.cinemas.firstWhere(
                          (c) => c.id == room.cinemaId,
                          orElse: () => const Cinema(
                            id: '',
                            name: 'Rạp không xác định',
                            address: '',
                            city: '',
                          ),
                        );

                        final String timeStr =
                            '${showtime.startTime.hour.toString().padLeft(2, '0')}:${showtime.startTime.minute.toString().padLeft(2, '0')} - '
                            '${showtime.endTime.hour.toString().padLeft(2, '0')}:${showtime.endTime.minute.toString().padLeft(2, '0')}';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16171E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Time Block with Date
                              Container(
                                width: 150,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF66FCF1,
                                  ).withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF66FCF1,
                                    ).withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('dd/MM/yyyy')
                                          .format(showtime.startTime),
                                      style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.7),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      timeStr,
                                      style: const TextStyle(
                                        color: Color(0xFF66FCF1),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 30),

                              // Movie Poster thumbnail if exists
                              if (movie.posterUrl.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    movie.posterUrl,
                                    width: 50,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      width: 50,
                                      height: 70,
                                      color: Colors.grey[900],
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 20),

                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movie.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.storefront_outlined,
                                          size: 14,
                                          color: Color(0xFF66FCF1),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${cinema.name} • ${room.name} (${room.type})',
                                          style: const TextStyle(
                                            color: Color(0xFF66FCF1),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          'Thời lượng: ${movie.duration} phút',
                                          style: const TextStyle(
                                            color: Color(0xFFC5C6C7),
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.08,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            movie.rating,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          'Giá vé: ${showtime.basePrice.toStringAsFixed(0)} VND',
                                          style: const TextStyle(
                                            color: Color(0xFF66FCF1),
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Actions
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blueGrey,
                                  size: 20,
                                ),
                                onPressed: () => _showAddShowtimeDialog(
                                  movies: movieProvider.movies,
                                  cinemas: cinemaProvider.cinemas,
                                  allRooms: cinemaProvider.rooms,
                                  editShowtime: showtime,
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                onPressed: () => _showDeleteShowtimeConfirm(
                                  showtimeProvider,
                                  showtime,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddShowtimeDialog({
    required List<Movie> movies,
    required List<Cinema> cinemas,
    required List<Room> allRooms,
    Showtime? editShowtime,
  }) {
    if (movies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cần tạo phim trong danh mục trước khi lập lịch chiếu.',
          ),
        ),
      );
      return;
    }
    if (cinemas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cần tạo chi nhánh rạp trước khi lập lịch chiếu.',
          ),
        ),
      );
      return;
    }
    if (allRooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cần tạo phòng chiếu trước khi lập lịch chiếu.',
          ),
        ),
      );
      return;
    }

    final isEdit = editShowtime != null;

    // 1. Initial movie
    Movie selectedMovie = isEdit
        ? movies.firstWhere(
            (m) => m.id == editShowtime.movieId,
            orElse: () => movies.first,
          )
        : movies.first;

    // 2. Initial Cinema and Room
    Cinema? selectedCinema;
    Room? selectedRoom;

    if (isEdit) {
      selectedRoom = allRooms.firstWhere(
        (r) => r.id == editShowtime.roomId,
        orElse: () => allRooms.first,
      );
      selectedCinema = cinemas.firstWhere(
        (c) => c.id == selectedRoom!.cinemaId,
        orElse: () => cinemas.first,
      );
    } else {
      selectedCinema = _selectedCinema ?? cinemas.first;
      final cinemaRooms = allRooms
          .where((r) => r.cinemaId == selectedCinema!.id)
          .toList();
      selectedRoom = (_selectedRoom != null &&
              cinemaRooms.any((r) => r.id == _selectedRoom!.id))
          ? _selectedRoom
          : (cinemaRooms.isNotEmpty ? cinemaRooms.first : null);
    }

    // 3. Initial Dates & Times
    final initialDate = _selectedDate ?? DateTime.now();
    DateTime startDate = isEdit
        ? DateTime(
            editShowtime.startTime.year,
            editShowtime.startTime.month,
            editShowtime.startTime.day,
          )
        : DateTime(
            initialDate.year,
            initialDate.month,
            initialDate.day,
          );

    TimeOfDay startTimeOfDay = isEdit
        ? TimeOfDay.fromDateTime(editShowtime.startTime)
        : const TimeOfDay(hour: 12, minute: 0);

    DateTime startTime = isEdit
        ? editShowtime.startTime
        : DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
            startTimeOfDay.hour,
            startTimeOfDay.minute,
          );

    DateTime endTime = isEdit
        ? editShowtime.endTime
        : startTime.add(Duration(minutes: selectedMovie.duration + 15));

    final priceController = TextEditingController(
      text: isEdit ? editShowtime.basePrice.toStringAsFixed(0) : '85000',
    );
    String status = isEdit ? editShowtime.status : 'Active';
    String? localError;
    bool isSaving = false;
    bool autoCalculateEndTime = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final availableRooms = selectedCinema == null
                ? <Room>[]
                : allRooms
                    .where((r) => r.cinemaId == selectedCinema!.id)
                    .toList();

            void updateCalculatedEndTime() {
              if (autoCalculateEndTime) {
                endTime = startTime.add(
                  Duration(minutes: selectedMovie.duration + 15),
                );
              }
            }

            return AlertDialog(
              backgroundColor: const Color(0xFF16171E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              title: Row(
                children: [
                  Icon(
                    isEdit ? Icons.edit_calendar : Icons.add_circle_outline,
                    color: const Color(0xFF66FCF1),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isEdit ? 'Chỉnh sửa suất chiếu' : 'Lập lịch suất chiếu mới',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (localError != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.redAccent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.redAccent,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  localError!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 1. Phim chiếu
                      const Text(
                        'Phim chiếu',
                        style: TextStyle(
                          color: Color(0xFFC5C6C7),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<Movie>(
                        dropdownColor: const Color(0xFF16171E),
                        value: selectedMovie,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                        items: movies.map((m) {
                          return DropdownMenuItem(
                            value: m,
                            child: Text(
                              '${m.title} (${m.duration} phút • ${m.rating})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedMovie = val;
                              updateCalculatedEndTime();
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // 2. Chi nhánh rạp & Phòng chiếu (Row)
                      Row(
                        children: [
                          // Chi nhánh rạp
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Chi nhánh rạp',
                                  style: TextStyle(
                                    color: Color(0xFFC5C6C7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<Cinema>(
                                  dropdownColor: const Color(0xFF16171E),
                                  value: selectedCinema,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                      ),
                                    ),
                                  ),
                                  items: cinemas.map((c) {
                                    return DropdownMenuItem(
                                      value: c,
                                      child: Text(
                                        c.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setDialogState(() {
                                        selectedCinema = val;
                                        final newRooms = allRooms
                                            .where((r) => r.cinemaId == val.id)
                                            .toList();
                                        selectedRoom = newRooms.isNotEmpty
                                            ? newRooms.first
                                            : null;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Phòng chiếu
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Phòng chiếu',
                                  style: TextStyle(
                                    color: Color(0xFFC5C6C7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<Room>(
                                  dropdownColor: const Color(0xFF16171E),
                                  value: availableRooms.any(
                                    (r) => r.id == selectedRoom?.id,
                                  )
                                      ? availableRooms.firstWhere(
                                          (r) => r.id == selectedRoom?.id,
                                        )
                                      : null,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                      ),
                                    ),
                                    hintText: availableRooms.isEmpty
                                        ? 'Chưa có phòng'
                                        : 'Chọn phòng',
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                  items: availableRooms.map((r) {
                                    return DropdownMenuItem(
                                      value: r,
                                      child: Text(
                                        '${r.name} (${r.type} - ${r.totalSeats} ghế)',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setDialogState(() {
                                      selectedRoom = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 3. Ngày chiếu & Giờ bắt đầu (Row)
                      Row(
                        children: [
                          // Ngày chiếu
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ngày chiếu',
                                  style: TextStyle(
                                    color: Color(0xFFC5C6C7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () async {
                                    final pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: startTime,
                                      firstDate: DateTime.now().subtract(
                                        const Duration(days: 365),
                                      ),
                                      lastDate: DateTime.now().add(
                                        const Duration(days: 365),
                                      ),
                                      builder: (pickerCtx, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: const ColorScheme.dark(
                                              primary: Color(0xFF66FCF1),
                                              surface: Color(0xFF16171E),
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (pickedDate != null) {
                                      setDialogState(() {
                                        startDate = pickedDate;
                                        startTime = DateTime(
                                          pickedDate.year,
                                          pickedDate.month,
                                          pickedDate.day,
                                          startTime.hour,
                                          startTime.minute,
                                        );
                                        updateCalculatedEndTime();
                                      });
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat('dd/MM/yyyy')
                                              .format(startTime),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.calendar_month,
                                          color: Color(0xFF66FCF1),
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Giờ bắt đầu
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Giờ bắt đầu',
                                  style: TextStyle(
                                    color: Color(0xFFC5C6C7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () async {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(
                                        startTime,
                                      ),
                                      builder: (pickerCtx, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: const ColorScheme.dark(
                                              primary: Color(0xFF66FCF1),
                                              surface: Color(0xFF16171E),
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (time != null) {
                                      setDialogState(() {
                                        startTimeOfDay = time;
                                        startTime = DateTime(
                                          startTime.year,
                                          startTime.month,
                                          startTime.day,
                                          time.hour,
                                          time.minute,
                                        );
                                        updateCalculatedEndTime();
                                      });
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat('HH:mm').format(startTime),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.access_time,
                                          color: Color(0xFF66FCF1),
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 4. Thời gian kết thúc
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Thời gian kết thúc',
                            style: TextStyle(
                              color: Color(0xFFC5C6C7),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                autoCalculateEndTime
                                    ? '(Tự động +15p vệ sinh)'
                                    : '(Tùy chỉnh thủ công)',
                                style: TextStyle(
                                  color: autoCalculateEndTime
                                      ? const Color(0xFF66FCF1)
                                      : Colors.amberAccent,
                                  fontSize: 11,
                                ),
                              ),
                              if (!autoCalculateEndTime)
                                TextButton(
                                  onPressed: () {
                                    setDialogState(() {
                                      autoCalculateEndTime = true;
                                      updateCalculatedEndTime();
                                    });
                                  },
                                  child: const Text(
                                    'Đặt lại tự động',
                                    style: TextStyle(
                                      color: Color(0xFF66FCF1),
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${DateFormat('HH:mm').format(endTime)} (Ngày ${DateFormat('dd/MM/yyyy').format(endTime)})',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(endTime),
                                  builder: (pickerCtx, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.dark(
                                          primary: Color(0xFF66FCF1),
                                          surface: Color(0xFF16171E),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (time != null) {
                                  setDialogState(() {
                                    autoCalculateEndTime = false;
                                    endTime = DateTime(
                                      endTime.year,
                                      endTime.month,
                                      endTime.day,
                                      time.hour,
                                      time.minute,
                                    );
                                  });
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.edit,
                                    size: 14,
                                    color: Color(0xFF66FCF1),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Chỉnh sửa',
                                    style: TextStyle(
                                      color: const Color(0xFF66FCF1)
                                          .withValues(alpha: 0.9),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 5. Giá vé & Trạng thái (Row)
                      Row(
                        children: [
                          // Giá vé
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Giá vé cơ bản (VND)',
                                  style: TextStyle(
                                    color: Color(0xFFC5C6C7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: priceController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '85000',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Trạng thái
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Trạng thái',
                                  style: TextStyle(
                                    color: Color(0xFFC5C6C7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  dropdownColor: const Color(0xFF16171E),
                                  value: status,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                      ),
                                    ),
                                  ),
                                  items: ['Active', 'Scheduled', 'Cancelled']
                                      .map((s) {
                                    return DropdownMenuItem(
                                      value: s,
                                      child: Text(
                                        s,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setDialogState(() {
                                        status = val;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(ctx),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Color(0xFFC5C6C7)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF66FCF1),
                    foregroundColor: const Color(0xFF0B0C10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (selectedRoom == null) {
                            setDialogState(() {
                              localError =
                                  'Vui lòng chọn phòng chiếu cho rạp đã chọn.';
                            });
                            return;
                          }

                          final double? price =
                              double.tryParse(priceController.text.trim());
                          if (price == null || price <= 0) {
                            setDialogState(() {
                              localError =
                                  'Vui lòng nhập giá vé hợp lệ (> 0 VND).';
                            });
                            return;
                          }

                          if (!endTime.isAfter(startTime)) {
                            setDialogState(() {
                              localError =
                                  'Thời gian kết thúc phải diễn ra sau thời gian bắt đầu.';
                            });
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                            localError = null;
                          });

                          try {
                            final showtimeProvider =
                                Provider.of<ShowtimeProvider>(
                              context,
                              listen: false,
                            );

                            bool success;
                            if (isEdit) {
                              success = await showtimeProvider.updateShowtime(
                                editShowtime.id,
                                movieId: selectedMovie.id,
                                roomId: selectedRoom!.id,
                                startTime: startTime,
                                endTime: endTime,
                                basePrice: price,
                                status: status,
                              );
                            } else {
                              success = await showtimeProvider.createShowtime(
                                movieId: selectedMovie.id,
                                roomId: selectedRoom!.id,
                                startTime: startTime,
                                endTime: endTime,
                                basePrice: price,
                                status: status,
                              );
                            }

                            if (success) {
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                              }
                              if (mounted) {
                                if (_selectedCinema != null ||
                                    _selectedRoom != null ||
                                    _selectedDate != null) {
                                  setState(() {
                                    _selectedCinema = selectedCinema;
                                    _selectedRoom = selectedRoom;
                                    _selectedDate = DateTime(
                                      startTime.year,
                                      startTime.month,
                                      startTime.day,
                                    );
                                  });
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isEdit
                                          ? 'Cập nhật suất chiếu thành công!'
                                          : 'Lập lịch suất chiếu mới thành công!',
                                    ),
                                    backgroundColor: const Color(0xFF16171E),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } else {
                              setDialogState(() {
                                localError = showtimeProvider.errorMessage ??
                                    'Không thể lưu suất chiếu. Vui lòng thử lại.';
                              });
                            }
                          } finally {
                            if (mounted) {
                              setDialogState(() => isSaving = false);
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEdit ? 'Cập Nhật' : 'Lưu Suất Chiếu',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteShowtimeConfirm(
    ShowtimeProvider provider,
    Showtime showtime,
  ) {
    bool isDeleting = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF16171E),
              title: const Text(
                'Xác nhận xóa suất chiếu',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Bạn có chắc chắn muốn xóa suất chiếu này? Hành động này không thể hoàn tác.',
                style: TextStyle(color: Color(0xFFC5C6C7)),
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.pop(ctx),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setState(() => isDeleting = true);
                          try {
                            await provider.deleteShowtime(showtime.id);
                            if (context.mounted) Navigator.pop(ctx);
                          } finally {
                            if (context.mounted) {
                              setState(() => isDeleting = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Xóa',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
