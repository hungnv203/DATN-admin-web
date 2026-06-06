import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/cinema.dart';
import '../../domain/entities/room.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/showtime.dart';
import '../../domain/entities/showtime_seat.dart';
import '../providers/cinema_provider.dart';
import '../providers/movie_provider.dart';
import '../providers/showtime_provider.dart';
import '../providers/booking_provider.dart';

class PosSimulatorScreen extends StatefulWidget {
  const PosSimulatorScreen({super.key});

  @override
  State<PosSimulatorScreen> createState() => _PosSimulatorScreenState();
}

class _PosSimulatorScreenState extends State<PosSimulatorScreen> {
  Cinema? _selectedCinema;
  Room? _selectedRoom;
  Showtime? _selectedShowtime;

  final List<ShowtimeSeat> _selectedSeats = [];
  final _customerPhoneController = TextEditingController();
  final _customerEmailController = TextEditingController();

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

      _initDropdowns(cinemaProvider, showtimeProvider);
    });
  }

  void _initDropdowns(CinemaProvider cinemaProvider, ShowtimeProvider showtimeProvider) {
    if (cinemaProvider.cinemas.isNotEmpty) {
      setState(() {
        _selectedCinema = cinemaProvider.cinemas.first;
        final cRooms = cinemaProvider.rooms.where((r) => r.cinemaId == _selectedCinema!.id).toList();
        if (cRooms.isNotEmpty) {
          _selectedRoom = cRooms.first;
          _loadShowtimes(showtimeProvider);
        }
      });
    }
  }

  void _loadShowtimes(ShowtimeProvider showtimeProvider) {
    if (_selectedRoom == null) return;
    final roomShowtimes = showtimeProvider.showtimes.where((s) => s.roomId == _selectedRoom!.id && s.startTime.isAfter(DateTime.now().subtract(const Duration(hours: 6)))).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    setState(() {
      _selectedShowtime = roomShowtimes.isNotEmpty ? roomShowtimes.first : null;
      _selectedSeats.clear();
    });

    if (_selectedShowtime != null) {
      Provider.of<BookingProvider>(context, listen: false).fetchSeatsForShowtime(_selectedShowtime!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cinemaProvider = Provider.of<CinemaProvider>(context);
    final movieProvider = Provider.of<MovieProvider>(context);
    final showtimeProvider = Provider.of<ShowtimeProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);

    final cRooms = _selectedCinema == null
        ? <Room>[]
        : cinemaProvider.rooms.where((r) => r.cinemaId == _selectedCinema!.id).toList();

    final roomShowtimes = _selectedRoom == null
        ? <Showtime>[]
        : showtimeProvider.showtimes.where((s) => s.roomId == _selectedRoom!.id && s.startTime.isAfter(DateTime.now().subtract(const Duration(hours: 6)))).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final Movie? currentMovie = _selectedShowtime == null
        ? null
        : movieProvider.movies.firstWhere((m) => m.id == _selectedShowtime!.movieId, orElse: () => Movie(
            id: '',
            title: 'Phim không xác định',
            description: '',
            duration: 0,
            releaseDate: DateTime.now(),
            language: '',
            rating: '',
            posterUrl: '',
            status: '',
          ));

    return Scaffold(
      backgroundColor: const Color(0xFF0F1015),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Side - Grid selection and filter
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bán Vé Tại Quầy (POS Simulator)', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // Dropdowns
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Cinema>(
                          dropdownColor: const Color(0xFF16171E),
                          value: _selectedCinema,
                          decoration: InputDecoration(
                            labelText: 'Rạp chiếu',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: cinemaProvider.cinemas.map((c) => DropdownMenuItem(value: c, child: Text(c.name, style: const TextStyle(fontSize: 13)))).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCinema = val;
                              _selectedRoom = null;
                              _selectedShowtime = null;
                              final rooms = cinemaProvider.rooms.where((r) => r.cinemaId == _selectedCinema!.id).toList();
                              if (rooms.isNotEmpty) {
                                _selectedRoom = rooms.first;
                                _loadShowtimes(showtimeProvider);
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<Room>(
                          dropdownColor: const Color(0xFF16171E),
                          value: _selectedRoom,
                          decoration: InputDecoration(
                            labelText: 'Phòng chiếu',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: cRooms.map((r) => DropdownMenuItem(value: r, child: Text(r.name, style: const TextStyle(fontSize: 13)))).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedRoom = val;
                              _selectedShowtime = null;
                              _loadShowtimes(showtimeProvider);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<Showtime>(
                          dropdownColor: const Color(0xFF16171E),
                          value: _selectedShowtime,
                          decoration: InputDecoration(
                            labelText: 'Suất chiếu',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: roomShowtimes.map((s) {
                            final String startStr = '${s.startTime.hour.toString().padLeft(2, '0')}:${s.startTime.minute.toString().padLeft(2, '0')}';
                            final Movie m = movieProvider.movies.firstWhere((mv) => mv.id == s.movieId, orElse: () => Movie(
                              id: '',
                              title: 'Không rõ',
                              description: '',
                              duration: 0,
                              releaseDate: DateTime.now(),
                              language: '',
                              rating: '',
                              posterUrl: '',
                              status: '',
                            ));
                            return DropdownMenuItem(value: s, child: Text('$startStr - ${m.title}', style: const TextStyle(fontSize: 13)));
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedShowtime = val;
                              _selectedSeats.clear();
                            });
                            if (_selectedShowtime != null) {
                              bookingProvider.fetchSeatsForShowtime(_selectedShowtime!.id);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Seat layout
                  Expanded(
                    child: _selectedShowtime == null
                        ? const Center(child: Text('Vui lòng chọn đầy đủ Rạp, Phòng và Suất chiếu', style: TextStyle(color: Color(0xFFC5C6C7))))
                        : bookingProvider.isLoading
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFF66FCF1)))
                            : _buildSeatGrid(bookingProvider.seats, currentMovie),
                  ),
                ],
              ),
            ),
          ),

          // Right Side - Billing cart
          Container(
            width: 380,
            decoration: BoxDecoration(
              color: const Color(0xFF16171E),
              border: Border(left: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: _selectedShowtime == null || currentMovie == null
                ? const Center(child: Text('Chưa có thông tin thanh toán', style: TextStyle(color: Color(0xFFC5C6C7))))
                : _buildBillingPanel(currentMovie, bookingProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatGrid(List<ShowtimeSeat> seats, Movie? movie) {
    if (seats.isEmpty) {
      return const Center(child: Text('Phòng chiếu chưa được thiết lập ghế.', style: TextStyle(color: Color(0xFFC5C6C7))));
    }

    // Group seats by row
    final Map<String, List<ShowtimeSeat>> rowsMap = {};
    for (var seat in seats) {
      rowsMap.putIfAbsent(seat.rowLabel, () => []).add(seat);
    }

    final sortedRowKeys = rowsMap.keys.toList()..sort();

    return Column(
      children: [
        // Movie quick info header
        if (movie != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Icon(Icons.play_circle_fill, color: const Color(0xFF66FCF1), size: 16),
                const SizedBox(width: 10),
                Expanded(child: Text('${movie.title} (${movie.duration} phút)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                const SizedBox(width: 10),
                Text('Giá gốc: ${_selectedShowtime!.basePrice.toStringAsFixed(0)} đ', style: const TextStyle(color: Color(0xFF66FCF1), fontSize: 13)),
              ],
            ),
          ),
        const SizedBox(height: 20),

        // Screen Banner
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF66FCF1).withOpacity(0.05),
            borderRadius: BorderRadius.circular(4),
            border: const Border(top: BorderSide(color: Color(0xFF66FCF1), width: 2)),
          ),
          child: const Text('MÀN HÌNH CHIẾU PHIM', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF66FCF1), fontSize: 10, letterSpacing: 6, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 20),

        // Seat Grid scroll wrapper
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  for (var rowKey in sortedRowKeys) ...[
                    Row(
                      children: [
                        // Row Letter Label
                        Container(
                          width: 25,
                          alignment: Alignment.center,
                          child: Text(rowKey, style: const TextStyle(color: Color(0xFF66FCF1), fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const SizedBox(width: 10),

                        // Row Seats
                        for (var seat in rowsMap[rowKey]!..sort((a, b) => a.seatNumber.compareTo(b.seatNumber))) ...[
                          _buildSeatItem(seat),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                  ]
                ],
              ),
            ),
          ),
        ),

        // Legend
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildLegendBox(Colors.blueGrey.shade700, 'Standard'),
            _buildLegendBox(const Color(0xFFD4AF37), 'VIP (+20k)'),
            _buildLegendBox(const Color(0xFFEC407A), 'Couple (+40k)'),
            _buildLegendBox(Colors.redAccent, 'Đã mua'),
            _buildLegendBox(Colors.orangeAccent, 'Đang giữ'),
            _buildLegendBox(const Color(0xFF66FCF1), 'Đang chọn'),
          ],
        ),
      ],
    );
  }

  Widget _buildSeatItem(ShowtimeSeat seat) {
    final bool isReserved = seat.status == 'Reserved';
    final bool isHeld = seat.status == 'Held';
    final bool isCurrentlySelected = _selectedSeats.any((s) => s.seatId == seat.seatId);

    Color color;
    if (isReserved) {
      color = Colors.redAccent;
    } else if (isHeld) {
      color = Colors.orangeAccent;
    } else if (isCurrentlySelected) {
      color = const Color(0xFF66FCF1);
    } else {
      switch (seat.type) {
        case 'VIP':
          color = const Color(0xFFD4AF37);
          break;
        case 'Couple':
          color = const Color(0xFFEC407A);
          break;
        case 'Standard':
        default:
          color = Colors.blueGrey.shade700;
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Tooltip(
        message: 'Ghế ${seat.rowLabel}-${seat.seatNumber} (${seat.type}) - ${seat.status}',
        child: InkWell(
          onTap: isReserved || isHeld
              ? null
              : () {
                  setState(() {
                    if (isCurrentlySelected) {
                      _selectedSeats.removeWhere((s) => s.seatId == seat.seatId);
                    } else {
                      _selectedSeats.add(seat);
                    }
                  });
                },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: isCurrentlySelected ? Border.all(color: Colors.white, width: 1.5) : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '${seat.seatNumber}',
              style: TextStyle(
                color: isCurrentlySelected ? const Color(0xFF0B0C10) : Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendBox(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Color(0xFFC5C6C7), fontSize: 11)),
      ],
    );
  }

  Widget _buildBillingPanel(Movie movie, BookingProvider bookingProvider) {
    double total = 0;
    for (var seat in _selectedSeats) {
      double price = _selectedShowtime!.basePrice;
      if (seat.type == 'VIP') price += 20000;
      if (seat.type == 'Couple') price += 40000;
      total += price;
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Thông Tin Hóa Đơn', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Selected Movie details
          Text(movie.title, style: const TextStyle(color: Color(0xFF66FCF1), fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            'Lịch chiếu: ${'${_selectedShowtime!.startTime.hour.toString().padLeft(2, '0')}:${_selectedShowtime!.startTime.minute.toString().padLeft(2, '0')}'} ngày ${_selectedShowtime!.startTime.day}/${_selectedShowtime!.startTime.month}',
            style: const TextStyle(color: Color(0xFFC5C6C7), fontSize: 12),
          ),
          Text('Phòng: ${_selectedRoom?.name ?? ''} | Rạp: ${_selectedCinema?.name ?? ''}', style: const TextStyle(color: Color(0xFFC5C6C7), fontSize: 12)),
          const Divider(color: Colors.white12, height: 30),

          // Selected Seats breakdown
          const Text('Ghế đã chọn:', style: TextStyle(color: Color(0xFFC5C6C7), fontSize: 12)),
          const SizedBox(height: 8),
          Expanded(
            child: _selectedSeats.isEmpty
                ? const Center(child: Text('Vui lòng chọn ghế trên sơ đồ', style: TextStyle(color: Colors.white30, fontSize: 13)))
                : ListView.builder(
                    itemCount: _selectedSeats.length,
                    itemBuilder: (ctx, index) {
                      final seat = _selectedSeats[index];
                      double price = _selectedShowtime!.basePrice;
                      if (seat.type == 'VIP') price += 20000;
                      if (seat.type == 'Couple') price += 40000;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Hàng ${seat.rowLabel} - Ghế ${seat.seatNumber} (${seat.type})', style: const TextStyle(color: Colors.white, fontSize: 13)),
                            Text('${price.toStringAsFixed(0)} đ', style: const TextStyle(color: Color(0xFF66FCF1), fontSize: 13)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const Divider(color: Colors.white12, height: 30),

          // Customer details form (POS sales can be anonymous, but collecting phone is good)
          const Text('Khách hàng (Không bắt buộc)', style: TextStyle(color: Color(0xFFC5C6C7), fontSize: 12)),
          const SizedBox(height: 10),
          TextField(
            controller: _customerPhoneController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Số điện thoại',
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _customerEmailController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Email nhận vé',
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
          const SizedBox(height: 20),

          // Total & Checkout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng tiền:', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              Text('${total.toStringAsFixed(0)} VND', style: const TextStyle(color: Color(0xFF66FCF1), fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _selectedSeats.isEmpty || bookingProvider.isLoading
                ? null
                : () => _checkoutPOS(bookingProvider, movie),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF66FCF1),
              foregroundColor: const Color(0xFF0B0C10),
              padding: const EdgeInsets.symmetric(vertical: 18),
              disabledBackgroundColor: Colors.grey.withOpacity(0.1),
            ),
            child: bookingProvider.isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0B0C10)))
                : const Text('Thanh Toán Tại Quầy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _checkoutPOS(BookingProvider bookingProvider, Movie movie) async {
    final seatIds = _selectedSeats.map((s) => s.seatId).toList();
    
    // Perform checkout immediately as Paid (POS Counter sale)
    final booking = await bookingProvider.checkoutBooking(
      showtimeId: _selectedShowtime!.id,
      seatIds: seatIds,
      status: 'Paid',
    );

    if (booking != null) {
      // Show printing popup
      if (mounted) {
        _showInvoicePopup(movie, booking, _selectedSeats, _selectedShowtime!);
      }
      setState(() {
        _selectedSeats.clear();
        _customerPhoneController.clear();
        _customerEmailController.clear();
      });
      // Refresh seat layout
      bookingProvider.fetchSeatsForShowtime(_selectedShowtime!.id);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(bookingProvider.errorMessage ?? 'Thanh toán thất bại.')),
        );
      }
    }
  }

  void _showInvoicePopup(Movie movie, var booking, List<ShowtimeSeat> seats, Showtime showtime) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF16171E),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF66FCF1)),
              SizedBox(width: 10),
              Text('Hóa Đơn Bán Vé Thành Công', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('HÓA ĐƠN THANH TOÁN TẠI QUẦY', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('Phim: ${movie.title}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                Text('Thời lượng: ${movie.duration} phút', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                Text('Rạp: ${_selectedCinema?.name ?? ''}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text('Phòng chiếu: ${_selectedRoom?.name ?? ''}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text(
                  'Giờ chiếu: ${'${showtime.startTime.hour.toString().padLeft(2, '0')}:${showtime.startTime.minute.toString().padLeft(2, '0')}'} ngày ${showtime.startTime.day}/${showtime.startTime.month}/${showtime.startTime.year}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Divider(color: Colors.white12, height: 24),
                
                // Seats list
                const Text('Ghế đã mua:', style: TextStyle(color: Colors.white60, fontSize: 11)),
                const SizedBox(height: 6),
                for (var seat in seats)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Hàng ${seat.rowLabel} - Ghế ${seat.seatNumber} (${seat.type})', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        Text('${(showtime.basePrice + (seat.type == 'VIP' ? 20000 : seat.type == 'Couple' ? 40000 : 0)).toStringAsFixed(0)} đ', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                const Divider(color: Colors.white12, height: 24),
                
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng thanh toán:', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    Text('${(booking.totalPrice as double).toStringAsFixed(0)} đ', style: const TextStyle(color: Color(0xFF66FCF1), fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('* Đơn hàng đã được thanh toán tiền mặt tại quầy.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang mô phỏng in hóa đơn giấy...')));
              },
              icon: const Icon(Icons.print, size: 16),
              label: const Text('In hóa đơn vé'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF66FCF1), foregroundColor: const Color(0xFF0B0C10)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng', style: TextStyle(color: Color(0xFFC5C6C7))),
            ),
          ],
        );
      },
    );
  }
}
