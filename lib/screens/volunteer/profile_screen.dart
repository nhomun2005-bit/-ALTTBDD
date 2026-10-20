import 'package:flutter/material.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import 'certificate_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DataService _dataService = DataService();

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

  void _showEditProfileDialog() {
    final vol = _dataService.currentVolunteer;
    final nameCtrl = TextEditingController(text: vol.fullName);
    final phoneCtrl = TextEditingController(text: vol.phone);
    final emailCtrl = TextEditingController(text: vol.email);
    final facultyCtrl = TextEditingController(text: vol.faculty);
    final bloodCtrl = TextEditingController(text: vol.bloodType ?? '');
    final skillsCtrl = TextEditingController(text: vol.skills ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.edit_note, color: AppTheme.primaryGreen),
              SizedBox(width: 8),
              Text('Cập Nhật Thông Tin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Họ và tên *'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Số điện thoại *'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email *'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: facultyCtrl,
                  decoration: const InputDecoration(labelText: 'Khoa / Viện đào tạo *'),
                ),
                const SizedBox(height: 14),

                // Các trường không bắt buộc theo yêu cầu
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin bổ sung (Không bắt buộc)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: bloodCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nhóm máu (Không bắt buộc)',
                          hintText: 'A, B, AB, O...',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: skillsCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Kỹ năng / Sở trường (Không bắt buộc)',
                          hintText: 'VD: Nấu ăn, sơ cấp cứu, ca hát, bơi lội...',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                _dataService.updateVolunteerProfile(
                  fullName: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  faculty: facultyCtrl.text.trim(),
                  bloodType: bloodCtrl.text.trim().isEmpty ? null : bloodCtrl.text.trim(),
                  skills: skillsCtrl.text.trim().isEmpty ? null : skillsCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã cập nhật hồ sơ cá nhân thành công!'),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              },
              child: const Text('Lưu Thay Đổi'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final volunteer = _dataService.currentVolunteer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ Sơ Tình Nguyện Viên'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Chỉnh sửa thông tin',
            onPressed: _showEditProfileDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.primaryGreenLight,
                    child: Text(
                      volunteer.fullName.isNotEmpty ? volunteer.fullName[0] : 'V',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreenDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    volunteer.fullName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  Text(
                    'MSSV: ${volunteer.studentId} • ${volunteer.faculty}',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  if (volunteer.teamName != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.youthBlueLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        volunteer.teamName!,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.youthBlue),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Metrics Summary Card
            Row(
              children: [
                _buildStatBox(
                  '${volunteer.completedActivities}',
                  'Hoạt động',
                  Icons.task_alt,
                  AppTheme.primaryGreen,
                ),
                const SizedBox(width: 8),
                _buildStatBox(
                  '${volunteer.totalHours}h',
                  'Giờ tình nguyện',
                  Icons.access_time_filled,
                  AppTheme.youthBlue,
                ),
                const SizedBox(width: 8),
                _buildStatBox(
                  '+${volunteer.totalPoints}',
                  'Điểm rèn luyện',
                  Icons.stars_rounded,
                  AppTheme.accentGold,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Thông tin cá nhân chi tiết
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin chi tiết',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const Divider(height: 20),
                  _buildInfoRow('Số điện thoại', volunteer.phone),
                  _buildInfoRow('Email sinh viên', volunteer.email),
                  _buildInfoRow('Khoa / Đơn vị', volunteer.faculty),
                  _buildInfoRow(
                    'Nhóm máu',
                    volunteer.bloodType ?? 'Chưa cập nhật (Không bắt buộc)',
                  ),
                  _buildInfoRow(
                    'Kỹ năng sở trường',
                    volunteer.skills ?? 'Chưa cập nhật (Không bắt buộc)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Nút xem giấy chứng nhận nhanh
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CertificateScreen()),
                  );
                },
                icon: const Icon(Icons.workspace_premium),
                label: const Text('Xem Giấy Chứng Nhận MHX Điện Tử'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Nút đăng xuất mô phỏng
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hệ thống hoạt động offline cục bộ, luôn sẵn sàng phục vụ!')),
                  );
                },
                icon: const Icon(Icons.refresh, color: AppTheme.textMuted),
                label: const Text('Làm mới bộ nhớ đệm ứng dụng', style: TextStyle(color: AppTheme.textMuted)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String val, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              val,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
