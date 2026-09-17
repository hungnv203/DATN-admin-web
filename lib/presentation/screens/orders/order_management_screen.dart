import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../domain/entities/booking.dart';
import '../../providers/order_management_provider.dart';
import 'order_detail_dialog.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderManagementProvider>().fetchBookings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderManagementProvider>();

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(provider),
            const SizedBox(height: 20),
            _buildStatsCards(provider),
            const SizedBox(height: 20),
            _buildSearchAndFilters(provider),
            const SizedBox(height: 20),
            Expanded(child: _buildDataTable(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(OrderManagementProvider provider) {
    return Row(
      children: [
        const Icon(Icons.receipt_long_outlined, color: AdminColors.primary, size: 28),
        const SizedBox(width: 12),
        const Text(
          'Quản lý Đơn hàng',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AdminColors.text,
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Tải lại',
          onPressed: provider.isLoading ? null : provider.fetchBookings,
          icon: const Icon(Icons.refresh_rounded, color: AdminColors.muted),
        ),
      ],
    );
  }

  Widget _buildStatsCards(OrderManagementProvider provider) {
    return Row(
      children: [
        _buildStatCard('Tổng đơn', provider.totalCount.toString(), Icons.receipt_outlined, AdminColors.primary),
        const SizedBox(width: 16),
        _buildStatCard('Đã thanh toán', provider.paidCount.toString(), Icons.check_circle_outline, Colors.greenAccent),
        const SizedBox(width: 16),
        _buildStatCard('Chờ thanh toán', provider.pendingCount.toString(), Icons.pending_outlined, Colors.orangeAccent),
        const SizedBox(width: 16),
        _buildStatCard('Doanh thu', _formatCurrency(provider.totalRevenue), Icons.monetization_on_outlined, AdminColors.secondary),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AdminColors.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(OrderManagementProvider provider) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _searchController,
            onChanged: provider.setSearchQuery,
            style: const TextStyle(color: AdminColors.text),
            decoration: InputDecoration(
              hintText: 'Tìm mã đơn, email, SĐT...',
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
          items: ['All', 'Paid', 'Pending', 'Cancelled', 'Expired'],
          label: 'Trạng thái',
          onChanged: (v) => provider.setStatusFilter(v ?? 'All'),
        ),
        const SizedBox(width: 16),
        _buildDropdown(
          value: provider.channelFilter,
          items: ['All', 'Online', 'PointOfSale'],
          label: 'Kênh',
          onChanged: (v) => provider.setChannelFilter(v ?? 'All'),
        ),
        const SizedBox(width: 16),
        _buildDropdown(
          value: provider.timeFilter,
          items: ['All', 'Today', '7Days'],
          label: 'Thời gian',
          onChanged: (v) => provider.setTimeFilter(v ?? 'All'),
        ),
      ],
    );
  }

  static final _currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  static final _showtimeFormatter = DateFormat('dd/MM HH:mm');
  static final _createTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: 165,
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
              String displayLabel = item;
              if (item == 'All') {
                displayLabel = 'Tất cả';
              } else if (item == 'Online' || item == 'CustomerOnline') {
                displayLabel = 'Online';
              } else if (item == 'PointOfSale' || item == 'POS') {
                displayLabel = 'Tại quầy (POS)';
              } else if (item == 'Paid') {
                displayLabel = 'Đã thanh toán';
              } else if (item == 'Pending') {
                displayLabel = 'Chờ thanh toán';
              } else if (item == 'Cancelled') {
                displayLabel = 'Đã hủy';
              } else if (item == 'Expired') {
                displayLabel = 'Hết hạn';
              } else if (item == 'Today') {
                displayLabel = 'Hôm nay';
              } else if (item == '7Days') {
                displayLabel = '7 ngày qua';
              }
              return DropdownMenuItem(
                value: item,
                child: Text(
                  displayLabel,
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

  Widget _buildDataTable(OrderManagementProvider provider) {
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
              onPressed: provider.fetchBookings,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final pagedBookings = provider.pagedBookings;

    if (provider.bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, color: AdminColors.muted.withValues(alpha: 0.5), size: 64),
            const SizedBox(height: 16),
            const Text(
              'Không có đơn hàng nào',
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
                            DataColumn(label: Text('Mã đơn')),
                            DataColumn(label: Text('Khách hàng')),
                            DataColumn(label: Text('Phim')),
                            DataColumn(label: Text('Suất chiếu')),
                            DataColumn(label: Text('Ghế')),
                            DataColumn(label: Text('Kênh')),
                            DataColumn(label: Text('Tổng tiền')),
                            DataColumn(label: Text('Trạng thái')),
                            DataColumn(label: Text('Phương thức TT')),
                            DataColumn(label: Text('Thời gian tạo')),
                            DataColumn(label: Text('Thao tác')),
                          ],
                          rows: pagedBookings.map((booking) => _buildDataRow(booking)).toList(),
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

  Widget _buildPaginationBar(OrderManagementProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hiển thị ${provider.pagedBookings.length} / ${provider.totalCount} đơn hàng',
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

  DataRow _buildDataRow(Booking booking) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            _shortId(booking.id),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(booking.customerName, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              booking.customerEmail,
              style: const TextStyle(fontSize: 11, color: AdminColors.muted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        )),
        DataCell(Text(booking.movieTitle, maxLines: 1, overflow: TextOverflow.ellipsis)),
        DataCell(Text(_showtimeFormatter.format(booking.showtimeStartTime))),
        DataCell(Text(booking.seatLabels.join(', '))),
        DataCell(_buildChannelBadge(booking.channel)),
        DataCell(Text(_formatCurrency(booking.totalPrice))),
        DataCell(_buildStatusBadge(booking.status)),
        DataCell(Text(booking.paymentMethod)),
        DataCell(Text(_createTimeFormatter.format(booking.createdAt))),
        DataCell(
          TextButton(
            onPressed: () => _showOrderDetail(booking),
            child: const Text('Chi tiết'),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
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
      case 'Expired':
        color = AdminColors.muted;
        label = 'Hết hạn';
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

  Widget _buildChannelBadge(String channel) {
    final isOnline = channel == 'CustomerOnline' || channel == 'Online';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isOnline ? AdminColors.primary : AdminColors.secondary).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isOnline ? 'Online' : 'POS',
        style: TextStyle(
          color: isOnline ? AdminColors.primary : AdminColors.secondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return _currencyFormatter.format(amount);
  }

  void _showOrderDetail(Booking booking) {
    showDialog(
      context: context,
      builder: (_) => OrderDetailDialog(booking: booking),
    );
  }
}
