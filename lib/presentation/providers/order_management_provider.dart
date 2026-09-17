import 'package:flutter/material.dart';

import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';

class OrderManagementProvider extends ChangeNotifier {
  final BookingRepository bookingRepository;

  OrderManagementProvider({required this.bookingRepository});

  List<Booking> _allBookings = [];
  List<Booking> _filteredBookings = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _statusFilter = 'All';
  String _channelFilter = 'All';
  String _timeFilter = 'All';
  Booking? _selectedBooking;

  List<Booking> get bookings => _filteredBookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Booking? get selectedBooking => _selectedBooking;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String get channelFilter => _channelFilter;
  String get timeFilter => _timeFilter;

  int get totalCount => _filteredBookings.length;
  int get paidCount =>
      _filteredBookings.where((b) => b.status == 'Paid').length;
  int get pendingCount =>
      _filteredBookings.where((b) => b.status == 'Pending').length;
  double get totalRevenue => _filteredBookings
      .where((b) => b.status == 'Paid')
      .fold(0.0, (sum, b) => sum + b.totalPrice);

  int _currentPage = 1;
  static const int pageSize = 10;

  int get currentPage => _currentPage;
  int get totalPages =>
      (_filteredBookings.isEmpty) ? 1 : ((_filteredBookings.length + pageSize - 1) ~/ pageSize);

  List<Booking> get pagedBookings {
    final startIndex = (_currentPage - 1) * pageSize;
    if (startIndex >= _filteredBookings.length) return [];
    final endIndex = (startIndex + pageSize > _filteredBookings.length)
        ? _filteredBookings.length
        : startIndex + pageSize;
    return _filteredBookings.sublist(startIndex, endIndex);
  }

  void setPage(int page) {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      notifyListeners();
    }
  }

  void nextPage() {
    if (_currentPage < totalPages) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      notifyListeners();
    }
  }

  Future<void> fetchBookings() async {
    if (_allBookings.isEmpty) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }
    try {
      _allBookings = await bookingRepository.getBookings();
      _applyFilters();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  void setChannelFilter(String channel) {
    _channelFilter = channel;
    _applyFilters();
    notifyListeners();
  }

  void setTimeFilter(String time) {
    _timeFilter = time;
    _applyFilters();
    notifyListeners();
  }

  void selectBooking(Booking? booking) {
    _selectedBooking = booking;
    notifyListeners();
  }

  void _applyFilters() {
    var result = List<Booking>.from(_allBookings);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((b) {
        return b.id.toLowerCase().contains(query) ||
            b.customerName.toLowerCase().contains(query) ||
            b.movieTitle.toLowerCase().contains(query) ||
            b.customerEmail.toLowerCase().contains(query) ||
            b.customerPhone.toLowerCase().contains(query);
      }).toList();
    }

    if (_statusFilter != 'All') {
      result = result.where((b) => b.status == _statusFilter).toList();
    }

    if (_channelFilter != 'All') {
      if (_channelFilter == 'Online' || _channelFilter == 'CustomerOnline') {
        result = result
            .where((b) =>
                b.channel == 'CustomerOnline' || b.channel == 'Online')
            .toList();
      } else if (_channelFilter == 'PointOfSale' || _channelFilter == 'POS') {
        result = result
            .where((b) =>
                b.channel == 'PointOfSale' || b.channel == 'POS')
            .toList();
      } else {
        result = result.where((b) => b.channel == _channelFilter).toList();
      }
    }

    if (_timeFilter != 'All') {
      final now = DateTime.now();
      DateTime startDate;
      if (_timeFilter == 'Today') {
        startDate = DateTime(now.year, now.month, now.day);
      } else if (_timeFilter == '7Days') {
        startDate = now.subtract(const Duration(days: 7));
      } else {
        startDate = DateTime(2000);
      }
      result = result.where((b) => b.createdAt.isAfter(startDate)).toList();
    }

    _filteredBookings = result;
    _currentPage = 1;
  }
}
