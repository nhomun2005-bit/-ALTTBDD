import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/registration.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';

class AdminVolunteerApprovalScreen extends StatefulWidget {
  const AdminVolunteerApprovalScreen({super.key});

  @override
  State<AdminVolunteerApprovalScreen> createState() => _AdminVolunteerApprovalScreenState();
}

class _AdminVolunteerApprovalScreenState extends State<AdminVolunteerApprovalScreen> {
  final DataService _dataService = DataService();
  String _selectedStatusFilter = 'Tất cả';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _dataService.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  void _showApproveDialog(Registration reg) {
    final teamCtrl = TextEditingController(
      text: reg.assignedTeam?.isNotEmpty == true
          ? reg.assignedTeam!
          : 'Đội hình Chuyển đổi số & Dạy tin học',
    );
    final noteCtrl = TextEditingController(text: 'Duyệt tham gia chiến dịch. Đề nghị có mặt đúng giờ.');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.how_to_reg, color: AppTheme.primaryGreen),
                  SizedBox(width: 8),
                  Text('Phê Duyệt Đơn & Phân Công Đội Hình', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tình nguyện viên: ${reg.volunteerName} (MSSV: ${reg.studentId})', style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (reg.phone != null || reg.faculty != null) ...[
                      const SizedBox(height: 4),
                      Text('SĐT: ${reg.phone ?? "Chưa cập nhật"} • Khoa: ${reg.faculty ?? "Chưa cập nhật"}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    ],
                    const SizedBox(height: 4),
                    Text('Hoạt động: ${reg.campaignTitle}', style: const TextStyle(fontSize: 13, color: AppTheme.youthBlue)),
                    const Divider(height: 20),
                    const Text('Phân công vào Đội hình chuyên trách *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: teamCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tên đội hình chuyên trách...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Ghi chú / Hướng dẫn của BCH cho sinh viên', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: noteCtrl,
                      decoration: const InputDecoration(hintText: 'Nhập dặn dò địa điểm tập trung, trang phục...'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: () {
                    final assignedTeam = teamCtrl.text.trim().isEmpty
                        ? 'Đội hình Sinh viên Tình nguyện'
                        : teamCtrl.text.trim();
                    _dataService.approveRegistration(reg.id, assignedTeam, noteCtrl.text.trim());
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã duyệt sinh viên ${reg.volunteerName} vào "$assignedTeam"!'),
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                    );
                  },
                  child: const Text('Xác Nhận Duyệt'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRejectDialog(Registration reg) {
    final reasonCtrl = TextEditingController(text: 'Số lượng đăng ký đã đủ chỉ tiêu mặt trận.');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cancel_outlined, color: AppTheme.dangerRed),
              SizedBox(width: 8),
              Text('Từ Chối Hồ Sơ Đăng Ký', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Từ chối đơn của sinh viên: ${reg.volunteerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Lý do từ chối (Sinh viên sẽ nhận được thông báo này):', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: reasonCtrl,
                maxLines: 2,
                decoration: const InputDecoration(hintText: 'Nhập lý do từ chối...'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
              onPressed: () {
                _dataService.rejectRegistration(reg.id, reasonCtrl.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã từ chối đơn đăng ký của ${reg.volunteerName}'),
                    backgroundColor: Colors.red.shade800,
                  ),
                );
              },
              child: const Text('Xác Nhận Từ Chối'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final registrations = _dataService.registrations.where((r) {
      final matchStatus = _selectedStatusFilter == 'Tất cả' ||
          (_selectedStatusFilter == 'Chờ duyệt' && r.status == RegistrationStatus.pending) ||
          (_selectedStatusFilter == 'Đã duyệt' && r.status == RegistrationStatus.approved) ||
          (_selectedStatusFilter == 'Từ chối' && r.status == RegistrationStatus.rejected);
      final matchSearch = _searchQuery.isEmpty ||
          r.volunteerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.studentId.contains(_searchQuery) ||
          r.campaignTitle.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchStatus && matchSearch;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quản Lý Hồ Sơ & Xét Duyệt Tình Nguyện Viên',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  Text(
                    'Tiếp nhận đơn đăng ký, phân công đội hình chuyên trách và phản hồi sinh viên',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bộ lọc tìm kiếm & trạng thái
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Tìm theo tên TNV, MSSV hoặc tên hoạt động...',
                    prefixIcon: Icon(Icons.search, size: 20),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _selectedStatusFilter,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'Tất cả', child: Text('Tất cả trạng thái')),
                  DropdownMenuItem(value: 'Chờ duyệt', child: Text('Chờ duyệt')),
                  DropdownMenuItem(value: 'Đã duyệt', child: Text('Đã duyệt')),
                  DropdownMenuItem(value: 'Từ chối', child: Text('Từ chối')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStatusFilter = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Bảng danh sách hồ sơ
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: registrations.isEmpty
                  ? Center(
                      child: Text(
                        'Không có hồ sơ nào phù hợp',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.separated(
                      itemCount: registrations.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final reg = registrations[index];

                        Color badgeColor;
                        Color badgeBg;
                        switch (reg.status) {
                          case RegistrationStatus.approved:
                            badgeColor = AppTheme.primaryGreenDark;
                            badgeBg = AppTheme.primaryGreenLight;
                            break;
                          case RegistrationStatus.rejected:
                            badgeColor = AppTheme.dangerRed;
                            badgeBg = Colors.red.shade50;
                            break;
                          case RegistrationStatus.pending:
                            badgeColor = AppTheme.accentOrange;
                            badgeBg = Colors.amber.shade50;
                            break;
                        }

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: badgeBg,
                            child: Icon(
                              reg.status == RegistrationStatus.approved
                                  ? Icons.check
                                  : (reg.status == RegistrationStatus.rejected ? Icons.close : Icons.hourglass_top),
                              color: badgeColor,
                              size: 18,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                reg.volunteerName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(MSSV: ${reg.studentId})',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  reg.status.label,
                                  style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (reg.phone != null && reg.phone!.isNotEmpty) ...[
                                    const Icon(Icons.phone_outlined, size: 13, color: AppTheme.primaryGreenDark),
                                    const SizedBox(width: 4),
                                    Text('SĐT: ${reg.phone}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                                    const SizedBox(width: 14),
                                  ],
                                  if (reg.faculty != null && reg.faculty!.isNotEmpty) ...[
                                    const Icon(Icons.school_outlined, size: 13, color: AppTheme.youthBlue),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Khoa: ${reg.faculty}',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Hoạt động: ${reg.campaignTitle}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.youthBlue, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 2),
                              if (reg.assignedTeam != null)
                                Text(
                                  'Đội hình: ${reg.assignedTeam}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryGreenDark),
                                ),
                              if (reg.note != null && reg.note!.isNotEmpty)
                                Text(
                                  'Ghi chú: ${reg.note}',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
                                ),
                              Text(
                                'Nộp đơn lúc: ${dateFormat.format(reg.registeredDate)}',
                                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (reg.status == RegistrationStatus.pending) ...[
                                ElevatedButton.icon(
                                  onPressed: () => _showApproveDialog(reg),
                                  icon: const Icon(Icons.check, size: 16),
                                  label: const Text('Duyệt & Phân Đội', style: TextStyle(fontSize: 12)),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                OutlinedButton(
                                  onPressed: () => _showRejectDialog(reg),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.dangerRed,
                                    side: const BorderSide(color: AppTheme.dangerRed),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                  child: const Text('Từ chối', style: TextStyle(fontSize: 12)),
                                ),
                              ] else ...[
                                TextButton.icon(
                                  onPressed: () => _showApproveDialog(reg),
                                  icon: const Icon(Icons.swap_horiz, size: 16),
                                  label: const Text('Đổi đội hình', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
