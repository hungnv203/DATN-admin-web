import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/admin_theme.dart';
import '../providers/auth_provider.dart';
import 'account/account_management_screen.dart';
import 'checkin/checkin_screen.dart';
import 'cinema_config_screen.dart';
import 'concession_management_screen.dart';
import 'login_screen.dart';
import 'movie_catalog_screen.dart';
import 'pos_simulator_screen.dart';
import 'promotion_management_screen.dart';
import 'showtime_config_screen.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardDestination {
  const _DashboardDestination(this.label, this.icon, this.screen);

  final String label;
  final IconData icon;
  final Widget screen;
}

class _DashboardShellState extends State<DashboardShell> {
  static const _destinations = <_DashboardDestination>[
    _DashboardDestination('Rạp & sơ đồ ghế', Icons.chair_outlined, CinemaConfigScreen()),
    _DashboardDestination('Danh mục phim', Icons.movie_outlined, MovieCatalogScreen()),
    _DashboardDestination('Lịch chiếu', Icons.calendar_month_outlined, ShowtimeConfigScreen()),
    _DashboardDestination('Bắp nước', Icons.fastfood_outlined, ConcessionManagementScreen()),
    _DashboardDestination('Khuyến mãi', Icons.local_offer_outlined, PromotionManagementScreen()),
    _DashboardDestination('Bán vé tại quầy', Icons.point_of_sale_outlined, PosSimulatorScreen()),
    _DashboardDestination('Check-in vé', Icons.qr_code_scanner_outlined, CheckInScreen()),
    _DashboardDestination('Tài khoản', Icons.manage_accounts_outlined, AccountManagementScreen()),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.select<AuthProvider, bool>(
      (provider) => provider.isAuthenticated,
    );

    if (!isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final showSidebar = constraints.maxWidth >= 1050;
        final compactSidebar = constraints.maxWidth < 1280;

        return Scaffold(
          drawer: showSidebar ? null : Drawer(child: _buildDrawer()),
          appBar: showSidebar
              ? null
              : AppBar(
                  title: Text(_destinations[_selectedIndex].label),
                  actions: [
                    IconButton(
                      tooltip: 'Đăng xuất',
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded),
                    ),
                  ],
                ),
          body: SafeArea(
            child: Row(
              children: [
                if (showSidebar) _buildNavigationRail(compactSidebar),
                Expanded(
                  child: ColoredBox(
                    color: AdminColors.background,
                    child: _destinations[_selectedIndex].screen,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationRail(bool compact) {
    return Container(
      width: compact ? 96 : 260,
      decoration: const BoxDecoration(
        color: AdminColors.surface,
        border: Border(right: BorderSide(color: AdminColors.outline)),
      ),
      child: Column(
        children: [
          _Brand(compact: compact),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _destinations.length,
              itemBuilder: (context, index) => _NavigationItem(
                destination: _destinations[index],
                selected: index == _selectedIndex,
                compact: compact,
                onTap: () => setState(() => _selectedIndex = index),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: compact
                ? IconButton(
                    tooltip: 'Đăng xuất',
                    onPressed: _logout,
                    color: AdminColors.danger,
                    icon: const Icon(Icons.logout_rounded),
                  )
                : OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Đăng xuất'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return SafeArea(
      child: Column(
        children: [
          const _Brand(compact: false),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _destinations.length,
              itemBuilder: (context, index) => _NavigationItem(
                destination: _destinations[index],
                selected: index == _selectedIndex,
                compact: false,
                onTap: () {
                  setState(() => _selectedIndex = index);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 20, vertical: 24),
      child: Row(
        mainAxisAlignment: compact ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AdminColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.local_movies_rounded, color: AdminColors.primary),
          ),
          if (!compact) ...[
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MovieOps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  SizedBox(height: 2),
                  Text('Trung tâm vận hành', style: TextStyle(color: AdminColors.muted, fontSize: 12)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.destination,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final _DashboardDestination destination;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Tooltip(
        message: compact ? destination.label : '',
        child: Material(
          color: selected ? AdminColors.primary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 14, vertical: 13),
              child: Row(
                mainAxisAlignment: compact ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Icon(
                    destination.icon,
                    size: 22,
                    color: selected ? AdminColors.primary : AdminColors.muted,
                  ),
                  if (!compact) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        destination.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected ? AdminColors.text : AdminColors.muted,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
