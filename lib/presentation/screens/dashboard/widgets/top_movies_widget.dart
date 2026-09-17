import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../data/models/dashboard_model.dart';

class TopMoviesWidget extends StatelessWidget {
  final List<TopMovie> data;

  const TopMoviesWidget({super.key, required this.data});

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AdminColors.muted;
    }
  }

  String _getRankBadge(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
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
            'Top phim ăn khách',
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
            ...data.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final movie = entry.value;
              final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: rank <= 3
                      ? _getRankColor(rank).withValues(alpha: 0.08)
                      : AdminColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: rank <= 3
                      ? Border.all(color: _getRankColor(rank).withValues(alpha: 0.3))
                      : null,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      child: Text(
                        _getRankBadge(rank),
                        style: TextStyle(
                          fontSize: rank <= 3 ? 20 : 14,
                          color: _getRankColor(rank),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                              color: AdminColors.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${movie.ticketsSold} vé',
                            style: const TextStyle(
                              color: AdminColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatter.format(movie.revenue),
                      style: const TextStyle(
                        color: AdminColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
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
