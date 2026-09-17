import 'package:flutter/material.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../data/models/dashboard_model.dart';

class CinemaPerformanceWidget extends StatelessWidget {
  final List<CinemaPerformance> data;

  const CinemaPerformanceWidget({super.key, required this.data});

  Color _getProgressColor(double rate) {
    if (rate >= 70) return const Color(0xFF10B981);
    if (rate >= 40) return const Color(0xFFFFC857);
    return const Color(0xFFFB7185);
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
            'Hiệu suất các rạp',
            style: TextStyle(
              color: AdminColors.text,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (data.isEmpty)
            const SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  'Không có dữ liệu',
                  style: TextStyle(color: AdminColors.muted, fontSize: 14),
                ),
              ),
            )
          else
            ...data.map((cinema) {
              final rate = cinema.occupancyRate.clamp(0.0, 100.0);
              final color = _getProgressColor(rate);

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            cinema.cinemaName,
                            style: const TextStyle(
                              color: AdminColors.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${rate.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: color,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: rate / 100,
                        backgroundColor: AdminColors.outline,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
