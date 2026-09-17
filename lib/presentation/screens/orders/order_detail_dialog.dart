import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../domain/entities/booking.dart';

class OrderDetailDialog extends StatelessWidget {
  final Booking booking;

  const OrderDetailDialog({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long, color: AdminColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Đơn hàng #${booking.id.length >= 8 ? booking.id.substring(0, 8) : booking.id}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AdminColors.text,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AdminColors.muted),
                  ),
                ],
              ),
              const Divider(color: AdminColors.outline),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection('Thông tin khách hàng', [
                        _buildInfoRow('Tên khách hàng', booking.customerName),
                        _buildInfoRow('Email', booking.customerEmail),
                        _buildInfoRow('Số điện thoại', booking.customerPhone),
                      ]),
                      const SizedBox(height: 20),
                      _buildSection('Thông tin phim & suất chiếu', [
                        _buildInfoRow('Phim', booking.movieTitle),
                        _buildInfoRow('Rạp', booking.cinemaName),
                        _buildInfoRow('Phòng', booking.roomName),
                        _buildInfoRow('Suất chiếu', DateFormat('dd/MM/yyyy HH:mm').format(booking.showtimeStartTime)),
                      ]),
                      const SizedBox(height: 20),
                      _buildSection('Danh sách vé', [
                        ...booking.seatLabels.map((seat) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.chair, size: 16, color: AdminColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Ghế $seat',
                                style: const TextStyle(color: AdminColors.text),
                              ),
                            ],
                          ),
                        )),
                      ]),
                      if (booking.concessions.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildSection('Bắp nước', [
                          ...booking.concessions.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.fastfood, size: 16, color: AdminColors.secondary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${c.concessionName} x${c.quantity}',
                                    style: const TextStyle(color: AdminColors.text),
                                  ),
                                ),
                                Text(
                                  _formatCurrency(c.price * c.quantity),
                                  style: const TextStyle(
                                    color: AdminColors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ]),
                      ],
                      const SizedBox(height: 20),
                      _buildSection('Chi tiết thanh toán', [
                        _buildInfoRow('Tạm tính', _formatCurrency(booking.subtotal)),
                        if (booking.discountAmount > 0)
                          _buildInfoRow('Giảm giá', '-${_formatCurrency(booking.discountAmount)}'),
                        if (booking.promotionCode != null)
                          _buildInfoRow('Mã giảm giá', booking.promotionCode!),
                        const Divider(color: AdminColors.outline),
                        _buildInfoRow('Tổng cộng', _formatCurrency(booking.totalPrice), isBold: true),
                        _buildInfoRow('Phương thức thanh toán', booking.paymentMethod),
                        _buildInfoRow('Trạng thái', booking.status),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AdminColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: const TextStyle(
                color: AdminColors.muted,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AdminColors.text,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                fontSize: isBold ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }
}
