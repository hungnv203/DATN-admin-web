import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'cinema_config_screen.dart';
import 'movie_catalog_screen.dart';
import 'showtime_config_screen.dart';
import 'pos_simulator_screen.dart';
import 'concession_management_screen.dart';
import 'login_screen.dart';
import 'checkin/checkin_screen.dart';
import 'account/account_management_screen.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CinemaConfigScreen(),
    const MovieCatalogScreen(),
    const ShowtimeConfigScreen(),
    const ConcessionManagementScreen(),
    const PosSimulatorScreen(),
    const CheckInScreen(),
    const AccountManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Redirect to login if token is deleted or logged out
    if (!authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F1015),
      body: Row(
        children: [
          // Sidebar Menu
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: const Color(0xFF16171E),
              border: Border(
                right: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 24,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF66FCF1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.movie_creation_outlined,
                          color: Color(0xFF66FCF1),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cổng Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Phòng vé MovieBooking',
                              style: TextStyle(
                                color: Color(0xFFC5C6C7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.white.withOpacity(0.05), height: 1),
                const SizedBox(height: 20),

                // Navigation items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildSidebarItem(
                        index: 0,
                        icon: Icons.chair_rounded,
                        label: 'Rạp & Sơ Đồ Ghế',
                      ),
                      _buildSidebarItem(
                        index: 1,
                        icon: Icons.movie_filter_rounded,
                        label: 'Danh Mục Phim',
                      ),
                      _buildSidebarItem(
                        index: 2,
                        icon: Icons.calendar_today_rounded,
                        label: 'Lịch Chiếu Phim',
                      ),
                      _buildSidebarItem(
                        index: 3,
                        icon: Icons.fastfood_rounded,
                        label: 'Bong nuoc',
                      ),
                      _buildSidebarItem(
                        index: 4,
                        icon: Icons.point_of_sale_rounded,
                        label: 'Ban ve tai quay',
                      ),
                      _buildSidebarItem(
                        index: 5,
                        icon: Icons.qr_code_scanner_rounded,
                        label: 'Check-in ve',
                      ),
                      _buildSidebarItem(
                        index: 6,
                        icon: Icons.manage_accounts_rounded,
                        label: 'Tai khoan & phan quyen',
                      ),
                    ],
                  ),
                ),

                // Logout Section
                Divider(color: Colors.white.withOpacity(0.05), height: 1),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: InkWell(
                    onTap: () async {
                      await authProvider.logout();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Đăng xuất',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Content View
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF66FCF1).withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF66FCF1)
                    : const Color(0xFFC5C6C7),
                size: 22,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFFC5C6C7),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
