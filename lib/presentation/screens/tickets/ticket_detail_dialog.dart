import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../domain/entities/ticket_detail.dart';

class TicketDetailDialog extends StatelessWidget {
  final TicketDetail ticket;

  const TicketDetailDialog({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 750),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.confirmation_number, color: AdminColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Vé #${ticket.id.length >= 8 ? ticket.id.substring(0, 8) : ticket.id}',
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
                      _buildSection('Thông tin phim & suất chiếu', [
                        _buildInfoRow('Phim', ticket.movieTitle),
                        _buildInfoRow('Rạp', ticket.cinemaName),
                        _buildInfoRow('Phòng', ticket.roomName),
                        _buildInfoRow('Suất chiếu', DateFormat('dd/MM/yyyy HH:mm').format(ticket.startTime)),
                      ]),
                      const SizedBox(height: 20),
                      _buildSection('Thông tin vé', [
                        _buildInfoRow('Mã ghế', ticket.seatLabel),
                        _buildInfoRow('Giá vé', _formatCurrency(ticket.price)),
                        _buildInfoRow('Trạng thái vé', _statusLabel(ticket.status)),
                        _buildInfoRow('Trạng thái thanh toán', _paymentStatusLabel(ticket.paymentStatus)),
                      ]),
                      const SizedBox(height: 20),
                      _buildSection('Thông tin khách hàng', [
                        _buildInfoRow('Tên khách hàng', ticket.customerName),
                        _buildInfoRow('Email', ticket.customerEmail),
                      ]),
                      const SizedBox(height: 20),
                      _buildSection('Mã QR Code', [
                        const SizedBox(height: 8),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: QrImageView(
                              data: ticket.qrCode,
                              version: QrVersions.auto,
                              size: 200,
                              backgroundColor: Colors.white,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: Colors.black,
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: SelectableText(
                            ticket.qrCode,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AdminColors.muted,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
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

  Widget _buildInfoRow(String label, String value) {
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
              style: const TextStyle(
                color: AdminColors.text,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'Booked':
        return 'Hợp lệ / Chưa soát';
      case 'CheckedIn':
        return 'Đã soát vé';
      case 'Cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  String _paymentStatusLabel(String status) {
    switch (status) {
      case 'Paid':
        return 'Đã thanh toán';
      case 'Pending':
        return 'Chờ thanh toán';
      case 'Cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }
}
