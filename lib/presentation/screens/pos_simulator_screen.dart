import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  static final _currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  static String formatCurrency(double amount) {
    return _currencyFormatter.format(amount);
  }

  static double calculateSeatPrice(ShowtimeSeat seat, Showtime? showtime) {
    final basePrice = showtime?.basePrice ?? 0.0;
    final seatType = seat.type.trim().toUpperCase();
    if (seatType == 'VIP') {
      return basePrice + 20000;
    } else if (seatType == 'COUPLE') {
      return basePrice + 40000;
    }
    return basePrice;
  }

  @override
  State<PosSimulatorScreen> createState() => _PosSimulatorScreenState();
}

class _PosSimulatorScreenState extends State<PosSimulatorScreen> {
  Cinema? _selectedCinema;
  Room? _selectedRoom;
  Showtime? _selectedShowtime;

  final _customerPhoneController = TextEditingController();
  final _customerEmailController = TextEditingController();

  double _calculateSeatPrice(ShowtimeSeat seat, [Showtime? showtime]) {
    return PosSimulatorScreen.calculateSeatPrice(
      seat,
      showtime ?? _selectedShowtime,
    );
  }

  String _formatCurrency(double amount) {
    return PosSimulatorScreen.formatCurrency(amount);
  }

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
        movieProvider.fetchMovies(),
        showtimeProvider.fetchShowtimes(),
      ]);

      _initDropdowns(cinemaProvider, showtimeProvider);
    });
  }

  void _initDropdowns(
    CinemaProvider cinemaProvider,
    ShowtimeProvider showtimeProvider,
  ) {
    if (cinemaProvider.cinemas.isNotEmpty) {
      setState(() {
        _selectedCinema = cinemaProvider.cinemas.first;
        final cRooms = cinemaProvider.rooms
            .where((r) => r.cinemaId == _selectedCinema!.id)
            .toList();
        if (cRooms.isNotEmpty) {
          _selectedRoom = cRooms.first;
          _loadShowtimes(showtimeProvider);
        }
      });
    }
  }

  void _loadShowtimes(ShowtimeProvider showtimeProvider) {
    if (_selectedRoom == null) return;
    final roomShowtimes =
        showtimeProvider.showtimes
            .where(
              (s) =>
                  s.roomId == _selectedRoom!.id &&
                  s.startTime.isAfter(
                    DateTime.now().subtract(const Duration(hours: 6)),
                  ),
            )
            .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));

    setState(() {
      _selectedShowtime = roomShowtimes.isNotEmpty ? roomShowtimes.first : null;
    });

    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );
    bookingProvider.clearSelectedSeats();

    if (_selectedShowtime != null) {
      bookingProvider.quoteBooking(_selectedShowtime!.id, const []);
      bookingProvider.fetchSeatsForShowtime(_selectedShowtime!.id);
    }
  }

  @override
  void dispose() {
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cinemaProvider = Provider.of<CinemaProvider>(context);
    final movieProvider = Provider.of<MovieProvider>(context);
    final showtimeProvider = Provider.of<ShowtimeProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);

    final cRooms = _selectedCinema == null
        ? <Room>[]
        : cinemaProvider.rooms
              .where((r) => r.cinemaId == _selectedCinema!.id)
              .toList();

    final roomShowtimes =
        _selectedRoom == null
              ? <Showtime>[]
              : showtimeProvider.showtimes
                    .where(
                      (s) =>
                          s.roomId == _selectedRoom!.id &&
                          s.startTime.isAfter(
                            DateTime.now().subtract(const Duration(hours: 6)),
                          ),
                    )
                    .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final Movie? currentMovie = _selectedShowtime == null
        ? null
        : movieProvider.movies.firstWhere(
            (m) => m.id == _selectedShowtime!.movieId,
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
                  const Text(
                    'Bán Vé Tại Quầy (POS Simulator)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Dropdowns
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField<Cinema>(
                          label: 'Rạp chiếu',
                          value: _selectedCinema,
                          items: cinemaProvider.cinemas,
                          itemLabel: (cinema) => cinema.name,
                          onChanged: (cinema) {
                            if (cinema == null) return;

                            final rooms = cinemaProvider.rooms
                                .where((room) => room.cinemaId == cinema.id)
                                .toList();

                            setState(() {
                              _selectedCinema = cinema;
                              _selectedRoom = rooms.isNotEmpty
                                  ? rooms.first
                                  : null;
                              _selectedShowtime = null;
                            });

                            bookingProvider.clearSelectedSeats();

                            if (_selectedRoom != null) {
                              _loadShowtimes(showtimeProvider);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownField<Room>(
                          label: 'Phòng chiếu',
                          value: _selectedRoom,
                          items: cRooms,
                          itemLabel: (room) => room.name,
                          onChanged: (room) {
                            setState(() {
                              _selectedRoom = room;
                              _selectedShowtime = null;
                            });

                            bookingProvider.clearSelectedSeats();

                            if (room != null) {
                              _loadShowtimes(showtimeProvider);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownField<Showtime>(
                          label: 'Suất chiếu',
                          value: _selectedShowtime,
                          items: roomShowtimes,
                          itemLabel: (showtime) {
                            final startStr =
                                '${showtime.startTime.hour.toString().padLeft(2, '0')}:'
                                '${showtime.startTime.minute.toString().padLeft(2, '0')}';

                            final movie = movieProvider.movies.firstWhere(
                              (movie) => movie.id == showtime.movieId,
                              orElse: () => Movie(
                                id: '',
                                title: 'Không rõ',
                                description: '',
                                duration: 0,
                                releaseDate: DateTime.now(),
                                language: '',
                                rating: '',
                                posterUrl: '',
                                status: '',
                              ),
                            );

                            return '$startStr - ${movie.title}';
                          },
                          onChanged: (showtime) {
                            setState(() {
                              _selectedShowtime = showtime;
                            });

                            bookingProvider.clearSelectedSeats();

                            if (showtime != null) {
                              bookingProvider.quoteBooking(
                                showtime.id,
                                const [],
                              );
                              bookingProvider.fetchSeatsForShowtime(
                                showtime.id,
                              );
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
                        ? const Center(
                            child: Text(
                              'Vui lòng chọn đầy đủ Rạp, Phòng và Suất chiếu',
                              style: TextStyle(color: Color(0xFFC5C6C7)),
                            ),
                          )
                        : bookingProvider.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF66FCF1),
                            ),
                          )
                        : _buildSeatGrid(
                            bookingProvider.seats,
                            currentMovie,
                            bookingProvider,
                          ),
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
              border: Border(
                left: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
            ),
            child: _selectedShowtime == null || currentMovie == null
                ? const Center(
                    child: Text(
                      'Chưa có thông tin thanh toán',
                      style: TextStyle(color: Color(0xFFC5C6C7)),
                    ),
                  )
                : _buildBillingPanel(currentMovie, bookingProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T item) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    Widget buildItem(T item) {
      return Tooltip(
        message: itemLabel(item),
        waitDuration: const Duration(milliseconds: 500),
        child: Text(
          itemLabel(item),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: const TextStyle(fontSize: 13),
        ),
      );
    }

    return DropdownButtonFormField<T>(
      isExpanded: true,
      value: value,
      dropdownColor: const Color(0xFF16171E),
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: buildItem(item),
            ),
          )
          .toList(),
      selectedItemBuilder: (context) {
        return items
            .map(
              (item) => Align(
                alignment: Alignment.centerLeft,
                child: buildItem(item),
              ),
            )
            .toList();
      },
      onChanged: items.isEmpty ? null : onChanged,
    );
  }

  Widget _buildSeatGrid(
    List<ShowtimeSeat> seats,
    Movie? movie,
    BookingProvider bookingProvider,
  ) {
    if (seats.isEmpty) {
      return const Center(
        child: Text(
          'Phòng chiếu chưa được thiết lập ghế.',
          style: TextStyle(color: Color(0xFFC5C6C7)),
        ),
      );
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
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.play_circle_fill,
                  color: const Color(0xFF66FCF1),
                  size: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${movie.title} (${movie.duration} phút)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Giá gốc: ${_formatCurrency(_selectedShowtime!.basePrice)}',
                  style: const TextStyle(
                    color: Color(0xFF66FCF1),
                    fontSize: 13,
                  ),
                ),
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
            border: const Border(
              top: BorderSide(color: Color(0xFF66FCF1), width: 2),
            ),
          ),
          child: const Text(
            'MÀN HÌNH CHIẾU PHIM',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF66FCF1),
              fontSize: 10,
              letterSpacing: 6,
              fontWeight: FontWeight.bold,
            ),
          ),
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
                          child: Text(
                            rowKey,
                            style: const TextStyle(
                              color: Color(0xFF66FCF1),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Row Seats
                        for (var seat
                            in rowsMap[rowKey]!..sort(
                              (a, b) => a.seatNumber.compareTo(b.seatNumber),
                            )) ...[_buildSeatItem(seat, bookingProvider)],
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
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

  Widget _buildSeatItem(ShowtimeSeat seat, BookingProvider bookingProvider) {
    final bool isReserved =
        seat.status == 'Reserved' || seat.status == 'Booked';
    final bool isHeld = seat.status == 'Held';
    final bool isCurrentlySelected = bookingProvider.isSeatSelected(
      seat.seatId,
    );

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
        message:
            'Ghế ${seat.rowLabel}-${seat.seatNumber} (${seat.type}) - ${seat.status}',
        child: InkWell(
          onTap: isReserved || isHeld
              ? null
              : () {
                  bookingProvider.toggleSeat(seat);
                  bookingProvider.quoteBooking(
                    _selectedShowtime!.id,
                    bookingProvider.selectedSeats
                        .map((item) => item.seatId)
                        .toList(),
                  );
                },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: isCurrentlySelected
                  ? Border.all(color: Colors.white, width: 1.5)
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '${seat.seatNumber}',
              style: TextStyle(
                color: isCurrentlySelected
                    ? const Color(0xFF0B0C10)
                    : Colors.white,
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
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Color(0xFFC5C6C7), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildBillingPanel(Movie movie, BookingProvider bookingProvider) {
    final quote = bookingProvider.currentQuote;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Thông Tin Hóa Đơn',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Selected Movie details
          Text(
            movie.title,
            style: const TextStyle(
              color: Color(0xFF66FCF1),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Lịch chiếu: ${'${_selectedShowtime!.startTime.hour.toString().padLeft(2, '0')}:${_selectedShowtime!.startTime.minute.toString().padLeft(2, '0')}'} ngày ${_selectedShowtime!.startTime.day}/${_selectedShowtime!.startTime.month}',
            style: const TextStyle(color: Color(0xFFC5C6C7), fontSize: 12),
          ),
          Text(
            'Phòng: ${_selectedRoom?.name ?? ''} | Rạp: ${_selectedCinema?.name ?? ''}',
            style: const TextStyle(color: Color(0xFFC5C6C7), fontSize: 12),
          ),
          const Divider(color: Colors.white12, height: 30),

          // Selected Seats breakdown
          const Text(
            'Ghế đã chọn:',
            style: TextStyle(color: Color(0xFFC5C6C7), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: bookingProvider.selectedSeats.isEmpty
                ? const Center(
                    child: Text(
                      'Vui lòng chọn ghế trên sơ đồ',
                      style: TextStyle(color: Colors.white30, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    itemCount: bookingProvider.selectedSeats.length,
                    itemBuilder: (ctx, index) {
                      final seat = bookingProvider.selectedSeats[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Hàng ${seat.rowLabel} - Ghế ${seat.seatNumber} (${seat.type})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              _formatCurrency(_calculateSeatPrice(seat)),
                              style: const TextStyle(
                                color: Color(0xFF66FCF1),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const Divider(color: Colors.white12, height: 30),

          // Customer details form (POS sales can be anonymous, but collecting phone is good)
          const Text(
            'Khách hàng (Không bắt buộc)',
            style: TextStyle(color: Color(0xFFC5C6C7), fontSize: 12),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _customerPhoneController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Số điện thoại',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _customerEmailController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Email nhận vé',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Total & Checkout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng tiền:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                bookingProvider.selectedSeats.isEmpty
                    ? _formatCurrency(0)
                    : quote == null
                        ? 'Đang lấy giá...'
                        : _formatCurrency(quote.totalPrice),
                style: const TextStyle(
                  color: Color(0xFF66FCF1),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed:
                bookingProvider.selectedSeats.isEmpty ||
                    quote == null ||
                    bookingProvider.isLoading ||
                    bookingProvider.phase == PosBookingPhase.paid ||
                    bookingProvider.phase == PosBookingPhase.reviewRequired
                ? null
                : () => _handlePrimaryPosAction(bookingProvider, movie),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF66FCF1),
              foregroundColor: const Color(0xFF0B0C10),
              padding: const EdgeInsets.symmetric(vertical: 18),
              disabledBackgroundColor: Colors.grey.withOpacity(0.1),
            ),
            child: bookingProvider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF0B0C10),
                    ),
                  )
                : Text(
                    _primaryPosActionLabel(bookingProvider.phase),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
          if (bookingProvider.phase == PosBookingPhase.held ||
              bookingProvider.phase == PosBookingPhase.pendingPayment) ...[
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: bookingProvider.isLoading
                  ? null
                  : () => _cancelPosFlow(bookingProvider),
              child: const Text('Hủy và trả ghế'),
            ),
          ],
        ],
      ),
    );
  }

  String _primaryPosActionLabel(PosBookingPhase phase) {
    return switch (phase) {
      PosBookingPhase.held => 'Tiếp tục tạo đơn chờ thanh toán',
      PosBookingPhase.pendingPayment => 'Xác nhận đã nhận tiền mặt',
      _ => 'Xác nhận và giữ ghế',
    };
  }

  Future<void> _cancelPosFlow(BookingProvider bookingProvider) async {
    final cancelled = await bookingProvider.cancelCurrentFlow();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          cancelled
              ? 'Đã hủy giao dịch và trả ghế.'
              : bookingProvider.errorMessage ?? 'Không thể hủy giao dịch.',
        ),
      ),
    );
  }

  void _handlePrimaryPosAction(
    BookingProvider bookingProvider,
    Movie movie,
  ) async {
    final selectedSeats = List<ShowtimeSeat>.from(
      bookingProvider.selectedSeats,
    );
    final seatIds = selectedSeats.map((seat) => seat.seatId).toList();
    if (bookingProvider.phase == PosBookingPhase.selectingLocal ||
        bookingProvider.phase == PosBookingPhase.conflict ||
        bookingProvider.phase == PosBookingPhase.retryableError) {
      await bookingProvider.holdSeats(_selectedShowtime!.id, seatIds);
      return;
    }

    if (bookingProvider.phase == PosBookingPhase.held) {
      await bookingProvider.createPendingBooking(
        showtimeId: _selectedShowtime!.id,
        seatIds: seatIds,
      );
      return;
    }

    if (bookingProvider.phase != PosBookingPhase.pendingPayment) return;
    final booking = await bookingProvider.confirmPendingCashPayment();

    if (booking != null) {
      // Show printing popup
      if (mounted) {
        _showInvoicePopup(movie, booking, selectedSeats, _selectedShowtime!);
      }
      setState(() {
        _customerPhoneController.clear();
        _customerEmailController.clear();
      });
      bookingProvider.resetAfterPaidSale();
      bookingProvider.quoteBooking(_selectedShowtime!.id, const []);
      // Refresh seat layout
      bookingProvider.fetchSeatsForShowtime(_selectedShowtime!.id);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              bookingProvider.phase == PosBookingPhase.reviewRequired
                  ? 'Trạng thái thanh toán cần được bộ phận hỗ trợ kiểm tra.'
                  : bookingProvider.errorMessage ??
                        'Thanh toán chưa được xác nhận. Bạn có thể thử lại.',
            ),
          ),
        );
      }
    }
  }

  void _showInvoicePopup(
    Movie movie,
    var booking,
    List<ShowtimeSeat> seats,
    Showtime showtime,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF16171E),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF66FCF1)),
              SizedBox(width: 10),
              Text(
                'Hóa Đơn Bán Vé Thành Công',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'HÓA ĐƠN THANH TOÁN TẠI QUẦY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Phim: ${movie.title}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Thời lượng: ${movie.duration} phút',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rạp: ${_selectedCinema?.name ?? ''}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  'Phòng chiếu: ${_selectedRoom?.name ?? ''}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  'Giờ chiếu: ${'${showtime.startTime.hour.toString().padLeft(2, '0')}:${showtime.startTime.minute.toString().padLeft(2, '0')}'} ngày ${showtime.startTime.day}/${showtime.startTime.month}/${showtime.startTime.year}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Divider(color: Colors.white12, height: 24),

                // Seats list
                const Text(
                  'Ghế đã mua:',
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
                const SizedBox(height: 6),
                for (var seat in seats)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hàng ${seat.rowLabel} - Ghế ${seat.seatNumber} (${seat.type})',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatCurrency(_calculateSeatPrice(seat, showtime)),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(color: Colors.white12, height: 24),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng thanh toán:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatCurrency(booking.totalPrice),
                      style: const TextStyle(
                        color: Color(0xFF66FCF1),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  '* Đơn hàng đã được thanh toán tiền mặt tại quầy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đang mô phỏng in hóa đơn giấy...'),
                  ),
                );
              },
              icon: const Icon(Icons.print, size: 16),
              label: const Text('In hóa đơn vé'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF66FCF1),
                foregroundColor: const Color(0xFF0B0C10),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Đóng',
                style: TextStyle(color: Color(0xFFC5C6C7)),
              ),
            ),
          ],
        );
      },
    );
  }
}
