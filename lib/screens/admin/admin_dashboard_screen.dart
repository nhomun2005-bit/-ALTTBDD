import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../../models/registration.dart';
import '../../models/task_report.dart';

class AdminDashboardScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const AdminDashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final dataService = DataService();
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    final totalCampaigns = dataService.campaigns.length;
    final totalVolunteers = dataService.registrations.map((r) => r.volunteerId).toSet().length;
    final pendingRegistrations = dataService.registrations.where((r) => r.status == RegistrationStatus.pending).length;
    final pendingReports = dataService.taskReports.where((r) => r.status == ReportStatus.pending).length;
    final totalCertified = dataService.registrations.where((r) => r.isCertified).length;

    double totalBudget = 0;
    double totalActualCost = 0;
    for (var b in dataService.budgetLogisticsMap.values) {
      totalBudget += b.estimatedBudget;
      totalActualCost += b.actualCost;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner chào mừng Ban Chỉ Huy
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreenDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'HỆ THỐNG QUẢN LÝ CHIẾN DỊCH TÌNH NGUYỆN MÙA HÈ XANH',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ban Chỉ Huy Chiến Dịch • Tổng số chiến sĩ đăng ký: $totalVolunteers • Tối ưu 3G',
                        style: TextStyle(
                          color: Colors.green.shade100,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt, color: Colors.amberAccent, size: 20),
                      SizedBox(width: 6),
                      Text(
                        '3G Low-Bandwidth Mode: ON',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Banner thông báo hồ sơ mới nếu có
          if (dataService.unreadAdminNotificationCount > 0) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade400),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active, color: Colors.amber, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Thông báo: Có ${dataService.unreadAdminNotificationCount} sinh viên mới nộp đơn đăng ký tham gia hoạt động đang chờ duyệt!',
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentOrange,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    onPressed: () => onNavigate(2),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('Xem mục Đã đăng ký', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 4 Thẻ KPI chính
          Row(
            children: [
              _buildKPICard(
                'Hoạt động / Chiến dịch',
                '$totalCampaigns',
                'Chiến dịch đang triển khai',
                Icons.campaign,
                AppTheme.primaryGreen,
                () => onNavigate(1),
              ),
              const SizedBox(width: 14),
              _buildKPICard(
                'Hồ sơ chờ duyệt',
                '$pendingRegistrations',
                'Đơn TNV cần xử lý',
                Icons.how_to_reg,
                pendingRegistrations > 0 ? AppTheme.accentOrange : AppTheme.primaryGreen,
                () => onNavigate(2),
              ),
              const SizedBox(width: 14),
              _buildKPICard(
                'Minh chứng cần chấm',
                '$pendingReports',
                'Báo cáo nhiệm vụ mới',
                Icons.assignment_late,
                pendingReports > 0 ? AppTheme.accentGold : AppTheme.primaryGreen,
                () => onNavigate(4),
              ),
              const SizedBox(width: 14),
              _buildKPICard(
                'Chứng nhận đã cấp',
                '$totalCertified',
                'Chiến sĩ hoàn thành',
                Icons.workspace_premium,
                AppTheme.youthBlue,
                () => onNavigate(4),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tổng quan Ngân sách & Hậu cần tóm tắt
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cột trái: Tiến độ giải ngân ngân sách hoạt động
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Kinh Phí Hoạt Động Tình Nguyện',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => onNavigate(5),
                            icon: const Icon(Icons.arrow_forward, size: 16),
                            label: const Text('Chi tiết hậu cần'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Dự toán phê duyệt', style: TextStyle(fontSize: 12, color: AppTheme.youthBlue)),
                                  const SizedBox(height: 4),
                                  Text(
                                    currencyFormat.format(totalBudget),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.youthBlue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Chi phí thực tế phát sinh', style: TextStyle(fontSize: 12, color: AppTheme.primaryGreenDark)),
                                  const SizedBox(height: 4),
                                  Text(
                                    currencyFormat.format(totalActualCost),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreenDark),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '* Ghi chú: Chi phí trên là kinh phí dành riêng cho các hoạt động tình nguyện tại cơ sở (vật tư, hậu cần, hỗ trợ ăn uống), không bao gồm chi phí phát triển phần mềm.',
                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Cột phải: Lối tắt điều hành
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thao Tác Nhanh Ban Chỉ Huy',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 12),
                      _buildQuickAction(
                        Icons.add_circle_outline,
                        'Tạo chiến dịch / hoạt động mới',
                        'Mở đợt tuyển quân & địa bàn mới',
                        () => onNavigate(1),
                      ),
                      _buildQuickAction(
                        Icons.group_add_outlined,
                        'Xét duyệt & phân đội tình nguyện',
                        'Duyệt đơn và gán vào đội hình',
                        () => onNavigate(2),
                      ),
                      _buildQuickAction(
                        Icons.fact_check_outlined,
                        'Điểm danh ngày công TNV',
                        'Ghi nhận giờ tình nguyện chuẩn',
                        () => onNavigate(3),
                      ),
                      _buildQuickAction(
                        Icons.file_download_outlined,
                        'Tổng hợp & Xuất báo cáo',
                        'Báo cáo Đoàn - Hội (Excel/PDF)',
                        () => onNavigate(6),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Danh sách đơn đăng ký mới nhất (Mục Đã Đăng Ký)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.how_to_reg, color: AppTheme.primaryGreenDark, size: 20),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Hồ Sơ Đăng Ký Chờ Phê Duyệt',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => onNavigate(2),
                      icon: const Icon(Icons.arrow_forward, size: 16, color: AppTheme.primaryGreen),
                      label: Text('Xem tất cả ($pendingRegistrations đơn)', style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (dataService.registrations.where((r) => r.status == RegistrationStatus.pending).isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: const Text('Hiện tại không có đơn đăng ký nào đang chờ duyệt', style: TextStyle(color: AppTheme.textMuted)),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dataService.registrations
                        .where((r) => r.status == RegistrationStatus.pending)
                        .take(3)
                        .length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final pendingList = dataService.registrations
                          .where((r) => r.status == RegistrationStatus.pending)
                          .toList();
                      final reg = pendingList[index];

                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: Colors.amber.shade50,
                          child: const Icon(Icons.hourglass_top, color: AppTheme.accentOrange, size: 16),
                        ),
                        title: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(reg.volunteerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(width: 6),
                            Text('(MSSV: ${reg.studentId})', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                            if (reg.phone != null && reg.phone!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.phone_outlined, size: 12, color: AppTheme.textMuted),
                              const SizedBox(width: 2),
                              Text(reg.phone!, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                            ],
                            if (reg.faculty != null && reg.faculty!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.school_outlined, size: 12, color: AppTheme.youthBlue),
                              const SizedBox(width: 2),
                              Text(reg.faculty!, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          'Hoạt động: ${reg.campaignTitle}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.youthBlue),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: const Size(0, 30),
                          ),
                          onPressed: () => onNavigate(2),
                          child: const Text('Xét duyệt', style: TextStyle(fontSize: 11)),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.primaryGreen),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: AppTheme.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
