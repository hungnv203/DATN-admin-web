import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../domain/entities/ticket_detail.dart';
import '../../providers/ticket_management_provider.dart';
import 'ticket_detail_dialog.dart';

class TicketManagementScreen extends StatefulWidget {
  const TicketManagementScreen({super.key});

  @override
  State<TicketManagementScreen> createState() => _TicketManagementScreenState();
}

class _TicketManagementScreenState extends State<TicketManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TicketManagementProvider>().fetchTickets();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TicketManagementProvider>();

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(provider),
            const SizedBox(height: 20),
            _buildSearchAndFilters(provider),
            const SizedBox(height: 20),
            Expanded(child: _buildDataTable(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TicketManagementProvider provider) {
    return Row(
      children: [
        const Icon(Icons.confirmation_number_outlined, color: AdminColors.primary, size: 28),
        const SizedBox(width: 12),
        const Text(
          'Quản lý Vé xem phim',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AdminColors.text,
          ),
        ),
        const Spacer(),
        Text(
          'Tổng: ${provider.totalCount} vé',
          style: const TextStyle(color: AdminColors.muted, fontSize: 14),
        ),
        const SizedBox(width: 16),
        IconButton(
          tooltip: 'Tải lại',
          onPressed: provider.isLoading ? null : provider.fetchTickets,
          icon: const Icon(Icons.refresh_rounded, color: AdminColors.muted),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(TicketManagementProvider provider) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: TextField(
            controller: _searchController,
            onChanged: provider.setSearchQuery,
            style: const TextStyle(color: AdminColors.text),
            decoration: InputDecoration(
              hintText: 'Tìm mã vé, mã QR, mã đơn, tên phim...',
              hintStyle: const TextStyle(color: AdminColors.muted),
              prefixIcon: const Icon(Icons.search, color: AdminColors.muted),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AdminColors.outline),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildDropdown(
          value: provider.statusFilter,
          items: ['All', 'Booked', 'CheckedIn', 'Cancelled'],
          label: 'Trạng thái',
          onChanged: (v) => provider.setStatusFilter(v ?? 'All'),
        ),
      ],
    );
  }

  static final _currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  static final _timeFormatter = DateFormat('dd/MM HH:mm');

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: 170,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AdminColors.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminColors.outline),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: AdminColors.surfaceHigh,
            style: const TextStyle(color: AdminColors.text),
            hint: Text(label, style: const TextStyle(color: AdminColors.muted)),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item == 'All' ? 'Tất cả' : _statusLabel(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'Booked':
        return 'Đã đặt';
      case 'CheckedIn':
        return 'Đã check-in';
      case 'Cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Widget _buildDataTable(TicketManagementProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AdminColors.primary),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AdminColors.danger, size: 48),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage!,
              style: const TextStyle(color: AdminColors.danger),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: provider.fetchTickets,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final pagedTickets = provider.pagedTickets;

    if (provider.tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.confirmation_number_outlined, color: AdminColors.muted.withValues(alpha: 0.5), size: 64),
            const SizedBox(height: 16),
            const Text(
              'Không có vé nào',
              style: TextStyle(color: AdminColors.muted, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: constraints.maxWidth),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(AdminColors.surfaceHigh),
                          columns: const [
                            DataColumn(label: Text('Mã vé')),
                            DataColumn(label: Text('Mã đơn')),
                            DataColumn(label: Text('Phim')),
                            DataColumn(label: Text('Suất chiếu')),
                            DataColumn(label: Text('Ghế')),
                            DataColumn(label: Text('Giá vé')),
                            DataColumn(label: Text('Trạng thái vé')),
                            DataColumn(label: Text('Trạng thái TT')),
                            DataColumn(label: Text('Thao tác')),
                          ],
                          rows: pagedTickets.map((ticket) => _buildDataRow(ticket)).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1, color: AdminColors.outline),
            _buildPaginationBar(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationBar(TicketManagementProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hiển thị ${provider.pagedTickets.length} / ${provider.totalCount} vé',
            style: const TextStyle(color: AdminColors.muted, fontSize: 13),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                color: provider.currentPage > 1 ? AdminColors.primary : AdminColors.muted,
                onPressed: provider.currentPage > 1 ? provider.previousPage : null,
                tooltip: 'Trang trước',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Trang ${provider.currentPage} / ${provider.totalPages}',
                  style: const TextStyle(
                    color: AdminColors.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                color: provider.currentPage < provider.totalPages
                    ? AdminColors.primary
                    : AdminColors.muted,
                onPressed: provider.currentPage < provider.totalPages ? provider.nextPage : null,
                tooltip: 'Trang sau',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _shortId(String id) => id.length >= 8 ? id.substring(0, 8) : id;

  DataRow _buildDataRow(TicketDetail ticket) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            _shortId(ticket.id),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(Text(_shortId(ticket.bookingId))),
        DataCell(Text(ticket.movieTitle, maxLines: 1, overflow: TextOverflow.ellipsis)),
        DataCell(Text(_timeFormatter.format(ticket.startTime))),
        DataCell(Text(ticket.seatLabel)),
        DataCell(Text(_formatCurrency(ticket.price))),
        DataCell(_buildTicketStatusBadge(ticket.status)),
        DataCell(_buildPaymentStatusBadge(ticket.paymentStatus)),
        DataCell(
          TextButton(
            onPressed: () => _showTicketDetail(ticket),
            child: const Text('Chi tiết'),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'Booked':
        color = Colors.greenAccent;
        label = 'Hợp lệ / Chưa soát';
        break;
      case 'CheckedIn':
        color = AdminColors.muted;
        label = 'Đã soát vé';
        break;
      case 'Cancelled':
        color = AdminColors.danger;
        label = 'Đã hủy';
        break;
      default:
        color = AdminColors.muted;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildPaymentStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'Paid':
        color = Colors.greenAccent;
        label = 'Đã thanh toán';
        break;
      case 'Pending':
        color = Colors.orangeAccent;
        label = 'Chờ thanh toán';
        break;
      case 'Cancelled':
        color = AdminColors.danger;
        label = 'Đã hủy';
        break;
      default:
        color = AdminColors.muted;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return _currencyFormatter.format(amount);
  }

  void _showTicketDetail(TicketDetail ticket) {
    showDialog(
      context: context,
      builder: (_) => TicketDetailDialog(ticket: ticket),
    );
  }
}
