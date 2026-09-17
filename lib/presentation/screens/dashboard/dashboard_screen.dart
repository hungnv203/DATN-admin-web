import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/admin_theme.dart';
import '../../providers/dashboard_provider.dart';
import 'widgets/date_filter_dropdown.dart';
import 'widgets/kpi_card.dart';
import 'widgets/revenue_chart_widget.dart';
import 'widgets/booking_status_chart_widget.dart';
import 'widgets/top_movies_widget.dart';
import 'widgets/user_growth_chart_widget.dart';
import 'widgets/cinema_performance_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DashboardProvider>(context, listen: false);
      provider.loadDashboard(provider.selectedDays);
    });

    // Tự động làm mới dữ liệu định kỳ mỗi 30 giây
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        final provider = Provider.of<DashboardProvider>(context, listen: false);
        if (!provider.isLoading) {
          provider.loadDashboard(provider.selectedDays, isSilent: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  String _formatCurrency(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(2)} tỷ';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)} triệu';
    }
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatter.format(value);
  }

  String _formatNumber(int value) {
    final formatter = NumberFormat('#,##0', 'vi_VN');
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.summaryData == null) {
            return const Center(
              child: CircularProgressIndicator(color: AdminColors.primary),
            );
          }

          if (provider.errorMessage != null && provider.summaryData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AdminColors.danger, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: AdminColors.muted, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadDashboard(provider.selectedDays),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primary,
                      foregroundColor: AdminColors.background,
                    ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final data = provider.summaryData;
          if (data == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: () => provider.loadDashboard(provider.selectedDays),
            color: AdminColors.primary,
            backgroundColor: AdminColors.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thống kê tổng quan',
                            style: TextStyle(
                              color: AdminColors.text,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (provider.lastUpdated != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Cập nhật lúc: ${DateFormat('HH:mm:ss dd/MM/yyyy').format(provider.lastUpdated!)} • Tự làm mới mỗi 30s',
                              style: const TextStyle(
                                color: AdminColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          DateFilterDropdown(
                            selectedDays: provider.selectedDays,
                            onDaysChanged: (days) => provider.loadDashboard(days),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            tooltip: 'Làm mới dữ liệu ngay',
                            onPressed: provider.isLoading
                                ? null
                                : () => provider.loadDashboard(provider.selectedDays),
                            icon: provider.isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AdminColors.primary,
                                    ),
                                  )
                                : const Icon(
                                    Icons.refresh_rounded,
                                    color: AdminColors.text,
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildKpiCards(data),
                  const SizedBox(height: 24),
                  _buildChartsRow(data),
                  const SizedBox(height: 24),
                  TopMoviesWidget(data: data.topMovies),
                  const SizedBox(height: 24),
                  _buildUserAndCinemaRow(data),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpiCards(dynamic data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1400
            ? 4
            : constraints.maxWidth > 900
                ? 2
                : 1;

        final aspectRatio = constraints.maxWidth > 1400
            ? 1.7
            : constraints.maxWidth > 900
                ? 2.2
                : 3.0;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: aspectRatio,
          children: [
            KpiCard(
              icon: Icons.attach_money_rounded,
              label: 'Doanh thu',
              value: _formatCurrency(data.totalRevenue),
              color: const Color(0xFF10B981),
            ),
            KpiCard(
              icon: Icons.confirmation_num_outlined,
              label: 'Vé bán',
              value: _formatNumber(data.totalTickets),
              color: const Color(0xFF5EEAD4),
            ),
            KpiCard(
              icon: Icons.people_outline,
              label: 'Người dùng',
              value: _formatNumber(data.totalUsers),
              color: const Color(0xFF818CF8),
            ),
            KpiCard(
              icon: Icons.movie_outlined,
              label: 'Phim đang chiếu',
              value: _formatNumber(data.activeMovies),
              color: const Color(0xFFFFC857),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartsRow(dynamic data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1000) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: RevenueChartWidget(data: data.dailyRevenue)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: BookingStatusChartWidget(data: data.bookingStatusDistribution)),
            ],
          );
        }
        return Column(
          children: [
            RevenueChartWidget(data: data.dailyRevenue),
            const SizedBox(height: 16),
            BookingStatusChartWidget(data: data.bookingStatusDistribution),
          ],
        );
      },
    );
  }

  Widget _buildUserAndCinemaRow(dynamic data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: UserGrowthChartWidget(data: data.userGrowth)),
              const SizedBox(width: 16),
              Expanded(child: CinemaPerformanceWidget(data: data.cinemaPerformance)),
            ],
          );
        }
        return Column(
          children: [
            UserGrowthChartWidget(data: data.userGrowth),
            const SizedBox(height: 16),
            CinemaPerformanceWidget(data: data.cinemaPerformance),
          ],
        );
      },
    );
  }
}
