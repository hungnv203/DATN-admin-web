import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../data/models/dashboard_model.dart';

class BookingStatusChartWidget extends StatelessWidget {
  final List<BookingStatusDistribution> data;

  const BookingStatusChartWidget({super.key, required this.data});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'confirmed':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFFB7185);
      case 'pending':
      case 'pendingpayment':
        return const Color(0xFFFFC857);
      default:
        return AdminColors.muted;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Thành công';
      case 'cancelled':
        return 'Hủy';
      case 'pending':
        return 'Chờ thanh toán';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AdminColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trạng thái đơn hàng',
            style: TextStyle(
              color: AdminColors.text,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (data.isEmpty)
            const SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  'Không có dữ liệu',
                  style: TextStyle(color: AdminColors.muted, fontSize: 14),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 180,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 50,
                        sections: data.map((item) {
                          final color = _getStatusColor(item.status);
                          return PieChartSectionData(
                            value: item.count.toDouble(),
                            color: color,
                            radius: 40,
                            title: '${item.percentage.toStringAsFixed(0)}%',
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.map((item) {
                    final color = _getStatusColor(item.status);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_getStatusLabel(item.status)} (${item.count})',
                            style: const TextStyle(
                              color: AdminColors.text,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
