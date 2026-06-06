import 'package:flutter/material.dart';
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
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cinemaProvider = Provider.of<CinemaProvider>(context, listen: false);
      final movieProvider = Provider.of<MovieProvider>(context, listen: false);
      final showtimeProvider = Provider.of<ShowtimeProvider>(context, listen: false);

      await Future.wait([
        cinemaProvider.fetchCinemas(),
        movieProvider.fetchMovies(),
        showtimeProvider.fetchShowtimes(),
      ]);

      if (cinemaProvider.cinemas.isNotEmpty) {
        setState(() {
          _selectedCinema = cinemaProvider.cinemas.first;
          final rooms = cinemaProvider.rooms.where((r) => r.cinemaId == _selectedCinema!.id).toList();
          if (rooms.isNotEmpty) {
            _selectedRoom = rooms.first;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cinemaProvider = Provider.of<CinemaProvider>(context);
    final movieProvider = Provider.of<MovieProvider>(context);
    final showtimeProvider = Provider.of<ShowtimeProvider>(context);

    final rooms = _selectedCinema == null
        ? <Room>[]
        : cinemaProvider.rooms.where((r) => r.cinemaId == _selectedCinema!.id).toList();

    // Filter showtimes by Room and Date
    final filteredShowtimes = showtimeProvider.showtimes.where((s) {
      if (_selectedRoom == null) return false;
      if (s.roomId != _selectedRoom!.id) return false;
      
      // Match day, month, year
      return s.startTime.year == _selectedDate.year &&
          s.startTime.month == _selectedDate.month &&
          s.startTime.day == _selectedDate.day;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

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
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Thiết lập giờ chiếu, phòng chiếu và giá vé cơ bản cho các phim',
                      style: TextStyle(color: Color(0xFFC5C6C7), fontSize: 14),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _selectedRoom == null ? null : () => _showAddShowtimeDialog(movieProvider.movies),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Thêm suất chiếu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF66FCF1),
                    foregroundColor: const Color(0xFF0B0C10),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    disabledBackgroundColor: Colors.grey.withOpacity(0.1),
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
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  // Cinema Selection
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Chi nhánh rạp', style: TextStyle(color: Color(0xFFC5C6C7), fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<Cinema>(
                          dropdownColor: const Color(0xFF16171E),
                          value: _selectedCinema,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: cinemaProvider.cinemas.map((c) {
                            return DropdownMenuItem(value: c, child: Text(c.name, style: const TextStyle(color: Colors.white, fontSize: 14)));
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCinema = val;
                              _selectedRoom = null;
                              final cRooms = cinemaProvider.rooms.where((r) => r.cinemaId == _selectedCinema!.id).toList();
                              if (cRooms.isNotEmpty) {
                                _selectedRoom = cRooms.first;
                              }
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
                        const Text('Phòng chiếu', style: TextStyle(color: Color(0xFFC5C6C7), fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<Room>(
                          dropdownColor: const Color(0xFF16171E),
                          value: _selectedRoom,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: rooms.map((r) {
                            return DropdownMenuItem(value: r, child: Text(r.name, style: const TextStyle(color: Colors.white, fontSize: 14)));
                          }).toList(),
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
                        const Text('Ngày chiếu', style: TextStyle(color: Color(0xFFC5C6C7), fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white.withOpacity(0.15)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                ),
                                const Icon(Icons.calendar_today, color: Color(0xFF66FCF1), size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Showtimes List (Timeline view)
            Expanded(
              child: showtimeProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF66FCF1)))
                  : filteredShowtimes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.hourglass_empty, size: 64, color: Colors.white.withOpacity(0.1)),
                              const SizedBox(height: 16),
                              const Text(
                                'Không có suất chiếu nào được lên lịch cho phòng này vào ngày đã chọn.',
                                style: TextStyle(color: Color(0xFFC5C6C7)),
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

                            final String timeStr =
                                '${showtime.startTime.hour.toString().padLeft(2, '0')}:${showtime.startTime.minute.toString().padLeft(2, '0')} - '
                                '${showtime.endTime.hour.toString().padLeft(2, '0')}:${showtime.endTime.minute.toString().padLeft(2, '0')}';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF16171E),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.05)),
                              ),
                              child: Row(
                                children: [
                                  // Time Block
                                  Container(
                                    width: 140,
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF66FCF1).withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFF66FCF1).withOpacity(0.2)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        timeStr,
                                        style: const TextStyle(
                                          color: Color(0xFF66FCF1),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
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
                                        errorBuilder: (_, __, ___) => Container(width: 50, height: 70, color: Colors.grey[900]),
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
                                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Text(
                                              'Thời lượng: ${movie.duration} phút',
                                              style: const TextStyle(color: Color(0xFFC5C6C7), fontSize: 13),
                                            ),
                                            const SizedBox(width: 16),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
                                              child: Text(movie.rating, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                            ),
                                            const SizedBox(width: 16),
                                            Text(
                                              'Giá vé: ${showtime.basePrice.toStringAsFixed(0)} VND',
                                              style: const TextStyle(color: Color(0xFF66FCF1), fontSize: 13, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Actions
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blueGrey, size: 20),
                                    onPressed: () => _showAddShowtimeDialog(movieProvider.movies, editShowtime: showtime),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          backgroundColor: const Color(0xFF16171E),
                                          title: const Text('Xác nhận xóa suất chiếu', style: TextStyle(color: Colors.white)),
                                          content: const Text('Bạn có chắc chắn muốn xóa suất chiếu này? Hành động này không thể hoàn tác.', style: TextStyle(color: Color(0xFFC5C6C7))),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy', style: TextStyle(color: Color(0xFFC5C6C7)))),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(ctx, true),
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                              child: const Text('Xóa', style: TextStyle(color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await showtimeProvider.deleteShowtime(showtime.id);
                                      }
                                    },
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

  void _showAddShowtimeDialog(List<Movie> movies, {Showtime? editShowtime}) {
    if (movies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cần tạo phim trong danh mục trước khi lập lịch chiếu.')),
      );
      return;
    }

    final isEdit = editShowtime != null;
    Movie selectedMovie = isEdit ? movies.firstWhere((m) => m.id == editShowtime.movieId) : movies.first;
    DateTime startTime = isEdit ? editShowtime.startTime : DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 12, 0);
    DateTime endTime = isEdit ? editShowtime.endTime : startTime.add(Duration(minutes: selectedMovie.duration + 15));
    final priceController = TextEditingController(text: isEdit ? editShowtime.basePrice.toStringAsFixed(0) : '85000');
    String status = isEdit ? editShowtime.status : 'Active';
    String? localError;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void updateEndTime() {
              setDialogState(() {
                endTime = startTime.add(Duration(minutes: selectedMovie.duration + 15));
              });
            }

            return AlertDialog(
              backgroundColor: const Color(0xFF16171E),
              title: Text(isEdit ? 'Chỉnh sửa suất chiếu' : 'Lập lịch suất chiếu mới', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (localError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(localError!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Movie Selection
                      const Text('Chọn phim', style: TextStyle(color: Color(0xFFC5C6C7), fontSize: 12)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<Movie>(
                        dropdownColor: const Color(0xFF16171E),
                        value: selectedMovie,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: movies.map((m) {
                          return DropdownMenuItem(value: m, child: Text(m.title, style: const TextStyle(color: Colors.white, fontSize: 14)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedMovie = val;
                            });
                            updateEndTime();
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Start Time Picker
                      const Text('Thời gian bắt đầu', style: TextStyle(color: Color(0xFFC5C6C7), fontSize: 12)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(startTime),
                                );
                                if (time != null) {
                                  setDialogState(() {
                                    startTime = DateTime(startTime.year, startTime.month, startTime.day, time.hour, time.minute);
                                  });
                                  updateEndTime();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Calculated End Time display (Premium Touch)
                      const Text('Thời gian kết thúc (Tự động tính toán +15p vệ sinh)', style: TextStyle(color: Color(0xFFC5C6C7), fontSize: 12)),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')} (Ngày ${endTime.day}/${endTime.month})',
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Base Price
                      const Text('Giá vé cơ bản (VND)', style: TextStyle(color: Color(0xFFC5C6C7), fontSize: 12)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: '85000',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Status Dropdown
                      const Text('Trạng thái', style: TextStyle(color: Color(0xFFC5C6C7), fontSize: 12)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        dropdownColor: const Color(0xFF16171E),
                        value: status,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: ['Active', 'Scheduled', 'Cancelled'].map((s) {
                          return DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 14)));
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Hủy', style: TextStyle(color: Color(0xFFC5C6C7))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF66FCF1), foregroundColor: const Color(0xFF0B0C10)),
                  onPressed: () async {
                    final double price = double.tryParse(priceController.text) ?? 85000;
                    final showtimeProvider = Provider.of<ShowtimeProvider>(context, listen: false);

                    bool success;
                    if (isEdit) {
                      success = await showtimeProvider.updateShowtime(
                        editShowtime.id,
                        movieId: selectedMovie.id,
                        roomId: _selectedRoom!.id,
                        startTime: startTime,
                        endTime: endTime,
                        basePrice: price,
                        status: status,
                      );
                    } else {
                      success = await showtimeProvider.createShowtime(
                        movieId: selectedMovie.id,
                        roomId: _selectedRoom!.id,
                        startTime: startTime,
                        endTime: endTime,
                        basePrice: price,
                        status: status,
                      );
                    }

                    if (success) {
                      Navigator.pop(ctx);
                      showtimeProvider.fetchShowtimes(); // Refresh list
                    } else {
                      setDialogState(() {
                        localError = showtimeProvider.errorMessage ?? 'Không thể lưu suất chiếu. Vui lòng thử lại.';
                      });
                    }
                  },
                  child: const Text('Lưu Suất Chiếu'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
