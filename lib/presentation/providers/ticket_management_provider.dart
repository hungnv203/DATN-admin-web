import 'package:flutter/material.dart';

import '../../domain/entities/ticket_detail.dart';
import '../../domain/repositories/ticket_repository.dart';

class TicketManagementProvider extends ChangeNotifier {
  final TicketRepository ticketRepository;

  TicketManagementProvider({required this.ticketRepository});

  List<TicketDetail> _allTickets = [];
  List<TicketDetail> _filteredTickets = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _statusFilter = 'All';
  TicketDetail? _selectedTicket;

  List<TicketDetail> get tickets => _filteredTickets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TicketDetail? get selectedTicket => _selectedTicket;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  int get totalCount => _filteredTickets.length;

  int _currentPage = 1;
  static const int pageSize = 10;

  int get currentPage => _currentPage;
  int get totalPages =>
      (_filteredTickets.isEmpty) ? 1 : ((_filteredTickets.length + pageSize - 1) ~/ pageSize);

  List<TicketDetail> get pagedTickets {
    final startIndex = (_currentPage - 1) * pageSize;
    if (startIndex >= _filteredTickets.length) return [];
    final endIndex = (startIndex + pageSize > _filteredTickets.length)
        ? _filteredTickets.length
        : startIndex + pageSize;
    return _filteredTickets.sublist(startIndex, endIndex);
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

  Future<void> fetchTickets() async {
    if (_allTickets.isEmpty) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }
    try {
      _allTickets = await ticketRepository.getTickets();
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

  void selectTicket(TicketDetail? ticket) {
    _selectedTicket = ticket;
    notifyListeners();
  }

  void _applyFilters() {
    var result = List<TicketDetail>.from(_allTickets);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((t) {
        return t.id.toLowerCase().contains(query) ||
            t.qrCode.toLowerCase().contains(query) ||
            t.bookingId.toLowerCase().contains(query) ||
            t.movieTitle.toLowerCase().contains(query);
      }).toList();
    }

    if (_statusFilter != 'All') {
      result = result.where((t) => t.status == _statusFilter).toList();
    }

    _filteredTickets = result;
    _currentPage = 1;
  }
}
