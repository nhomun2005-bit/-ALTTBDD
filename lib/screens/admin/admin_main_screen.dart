import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/registration.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import 'admin_dashboard_screen.dart';
import 'admin_activity_screen.dart';
import 'admin_volunteer_approval_screen.dart';
import 'admin_attendance_screen.dart';
import 'admin_proof_evaluation_screen.dart';
import 'admin_budget_logistics_screen.dart';
import 'admin_export_screen.dart';
import 'admin_faculty_screen.dart';

class AdminMainScreen extends StatefulWidget {
  final VoidCallback? onSwitchToStudentApp;

  const AdminMainScreen({super.key, this.onSwitchToStudentApp});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _dataService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  void _showNotificationsDialog() {
    final dateFormat = DateFormat('dd/MM HH:mm');
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final notifications = _dataService.adminNotifications;
            final unreadCount = _dataService.unreadAdminNotificationCount;

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580, maxHeight: 620),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreenLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.notifications_active, color: AppTheme.primaryGreenDark, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Thông Báo Xét Duyệt',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                    ),
                                    if (unreadCount > 0) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '$unreadCount mới',
                                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const Text(
                                  'Cập nhật sinh viên đăng ký hoạt động Mùa Hè Xanh',
                                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20, color: AppTheme.textMuted),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Thanh công cụ: Đánh dấu đã đọc
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tổng số: ${notifications.length} thông báo',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                          if (unreadCount > 0)
                            TextButton.icon(
                              onPressed: () {
                                _dataService.markAllNotificationsAsRead();
                                setDialogState(() {});
                              },
                              icon: const Icon(Icons.done_all, size: 16, color: AppTheme.primaryGreen),
                              label: const Text('Đánh dấu tất cả đã đọc', style: TextStyle(fontSize: 12, color: AppTheme.primaryGreen)),
                            ),
                        ],
                      ),
                      const Divider(height: 16),

                      // Danh sách thông báo
                      Expanded(
                        child: notifications.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.notifications_none, size: 48, color: Colors.grey.shade400),
                                    const SizedBox(height: 8),
                                    const Text('Hiện không có thông báo nào', style: TextStyle(color: AppTheme.textMuted)),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                itemCount: notifications.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final notif = notifications[index];
                                  final isUnread = !notif.isRead;

                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isUnread ? const Color(0xFFF0FDF4) : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isUnread ? AppTheme.primaryGreen.withValues(alpha: 0.4) : AppTheme.borderLight,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: isUnread ? AppTheme.primaryGreenLight : Colors.grey.shade100,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.person_add_alt_1,
                                                size: 16,
                                                color: isUnread ? AppTheme.primaryGreenDark : Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                notif.title,
                                                style: TextStyle(
                                                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                                  fontSize: 13,
                                                  color: AppTheme.textDark,
                                                ),
                                              ),
                                            ),
                                            if (isUnread)
                                              Container(
                                                margin: const EdgeInsets.only(right: 6),
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade50,
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(color: Colors.red.shade200),
                                                ),
                                                child: const Text('Mới', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                                              ),
                                            Text(
                                              dateFormat.format(notif.createdAt),
                                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          notif.message,
                                          style: const TextStyle(fontSize: 13, color: AppTheme.textDark, height: 1.35),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton.icon(
                                              onPressed: () {
                                                _dataService.markNotificationAsRead(notif.id);
                                                Navigator.pop(ctx);
                                                setState(() => _selectedIndex = 2); // Tab Duyệt Đơn & Phân Đội
                                              },
                                              icon: const Icon(Icons.arrow_forward, size: 14, color: AppTheme.primaryGreenDark),
                                              label: const Text('Xem trong mục Đã đăng ký', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreenDark)),
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                backgroundColor: AppTheme.primaryGreenLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      AdminDashboardScreen(onNavigate: (index) => setState(() => _selectedIndex = index)),
      const AdminActivityScreen(),
      const AdminVolunteerApprovalScreen(),
      const AdminAttendanceScreen(),
      const AdminProofEvaluationScreen(),
      const AdminBudgetLogisticsScreen(),
      const AdminExportScreen(),
      const AdminFacultyScreen(),
    ];

    final pendingRegCount = _dataService.registrations.where((r) => r.status == RegistrationStatus.pending).length;

    final navItems = [
      {'title': 'Bảng Tổng Quan', 'icon': Icons.dashboard_outlined, 'selectedIcon': Icons.dashboard, 'badge': 0},
      {'title': 'Chiến Dịch & Hoạt Động', 'icon': Icons.campaign_outlined, 'selectedIcon': Icons.campaign, 'badge': 0},
      {'title': 'Duyệt Đơn & Phân Đội', 'icon': Icons.how_to_reg_outlined, 'selectedIcon': Icons.how_to_reg, 'badge': pendingRegCount},
      {'title': 'Điểm Danh Ngày Công', 'icon': Icons.fact_check_outlined, 'selectedIcon': Icons.fact_check, 'badge': 0},
      {'title': 'Thẩm Định Minh Chứng', 'icon': Icons.rate_review_outlined, 'selectedIcon': Icons.rate_review, 'badge': 0},
      {'title': 'Ngân Sách & Hậu Cần', 'icon': Icons.inventory_2_outlined, 'selectedIcon': Icons.inventory_2, 'badge': 0},
      {'title': 'Tổng Hợp & Báo Cáo', 'icon': Icons.analytics_outlined, 'selectedIcon': Icons.analytics, 'badge': 0},
      {'title': 'Quản Lý Khoa / Viện', 'icon': Icons.domain_outlined, 'selectedIcon': Icons.domain, 'badge': 0},
    ];

    return Scaffold(
      body: Row(
        children: [
          // Sidebar Admin
          SizedBox(
            width: 250,
            child: Material(
              color: const Color(0xFF0F2B1D), // Dark forest green
              child: Column(
              children: [
                // Header Logo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MÙA HÈ XANH',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Hệ Thống Web Admin',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),

                // Navigation list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    itemCount: navItems.length,
                    itemBuilder: (context, index) {
                      final item = navItems[index];
                      final isSelected = _selectedIndex == index;
                      final badge = item['badge'] as int;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              isSelected ? (item['selectedIcon'] as IconData) : (item['icon'] as IconData),
                              color: isSelected ? Colors.white : Colors.white70,
                              size: 20,
                            ),
                            title: Text(
                              item['title'] as String,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                            trailing: badge > 0
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$badge',
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : null,
                            onTap: () => setState(() => _selectedIndex = index),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Divider(color: Colors.white24, height: 1),
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(
                    child: Text(
                      'Hệ Thống Web Quản Trị • v1.0\nChuyển trang qua URL /admin & /student',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 10, height: 1.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

          // Main Content Area
          Expanded(
            child: Scaffold(
              backgroundColor: AppTheme.backgroundLight,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0.5,
                title: Text(
                  navItems[_selectedIndex]['title'] as String,
                  style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                actions: [
                  // Nút Chuông Thông Báo với Badge
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: AppTheme.textDark),
                        tooltip: 'Thông báo Ban Chỉ Huy',
                        onPressed: _showNotificationsDialog,
                      ),
                      if (_dataService.unreadAdminNotificationCount > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              '${_dataService.unreadAdminNotificationCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 4),

                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreenLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.wifi_tethering, size: 14, color: AppTheme.primaryGreenDark),
                        SizedBox(width: 6),
                        Text(
                          'Mạng 3G: Tải siêu tốc 0ms',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreenDark),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
              body: pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
