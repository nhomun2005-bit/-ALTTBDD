import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/registration.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import 'certificate_screen.dart';
import 'submit_report_screen.dart';

class RegistrationStatusScreen extends StatefulWidget {
  const RegistrationStatusScreen({super.key});

  @override
  State<RegistrationStatusScreen> createState() => _RegistrationStatusScreenState();
}

class _RegistrationStatusScreenState extends State<RegistrationStatusScreen> {
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


  @override
  Widget build(BuildContext context) {
    final currentUserId = _dataService.currentUser?.id;
    final currentVolId = _dataService.currentVolunteer.id;
    final currentStudentId = (_dataService.currentUser?.studentId != null && _dataService.currentUser!.studentId!.isNotEmpty)
        ? _dataService.currentUser!.studentId!
        : _dataService.currentVolunteer.studentId;
    final currentName = _dataService.currentUser?.fullName ?? _dataService.currentVolunteer.fullName;

    final myRegistrations = _dataService.registrations.where((r) {
      return r.volunteerId == currentVolId ||
          (currentUserId != null && r.volunteerId == currentUserId) ||
          (currentStudentId.isNotEmpty && r.studentId == currentStudentId) ||
          r.volunteerName == currentName;
    }).toList();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ Sơ Đăng Ký Của Tôi'),
      ),
      body: myRegistrations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'Bạn chưa đăng ký hoạt động nào',
                    style: TextStyle(fontSize: 15, color: AppTheme.textMuted),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myRegistrations.length,
              itemBuilder: (context, index) {
                final reg = myRegistrations[index];

                // Kiểm tra xem sinh viên đã nộp minh chứng nhiệm vụ cho chiến dịch này chưa
                final userReport = _dataService.taskReports.where(
                  (r) => (r.campaignId == reg.campaignId || r.campaignTitle == reg.campaignTitle) &&
                         (r.volunteerId == reg.volunteerId || r.studentId == reg.studentId),
                ).toList();
                final bool hasSubmittedProof = userReport.any((r) => r.proofImageBytes != null || r.proofDescription.isNotEmpty);
                final bool isCompleted = reg.status == RegistrationStatus.approved && hasSubmittedProof;

                String displayStatusLabel = reg.status.label;
                Color statusColor;
                Color statusBg;
                IconData statusIcon;

                if (isCompleted) {
                  displayStatusLabel = 'Đã hoàn thành';
                  statusColor = AppTheme.primaryGreenDark;
                  statusBg = AppTheme.primaryGreenLight;
                  statusIcon = Icons.task_alt;
                } else {
                  switch (reg.status) {
                    case RegistrationStatus.approved:
                      statusColor = AppTheme.primaryGreenDark;
                      statusBg = AppTheme.primaryGreenLight;
                      statusIcon = Icons.check_circle;
                      break;
                    case RegistrationStatus.rejected:
                      statusColor = AppTheme.dangerRed;
                      statusBg = Colors.red.shade50;
                      statusIcon = Icons.cancel;
                      break;
                    case RegistrationStatus.pending:
                      statusColor = AppTheme.accentOrange;
                      statusBg = Colors.amber.shade50;
                      statusIcon = Icons.hourglass_bottom;
                      break;
                  }
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status & Date row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(statusIcon, size: 14, color: statusColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    displayStatusLabel,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              dateFormat.format(reg.registeredDate),
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                        if (isCompleted) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreenLight.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.4)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.verified, size: 16, color: AppTheme.primaryGreen),
                                SizedBox(width: 6),
                                Text(
                                  'Đã nộp minh chứng & hoàn thành hoạt động',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreenDark),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),

                        // Campaign title
                        Text(
                          reg.campaignTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Thông tin cá nhân đã đăng ký
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.badge_outlined, size: 14, color: AppTheme.textMuted),
                                const SizedBox(width: 4),
                                Text('MSSV: ${reg.studentId}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                              ],
                            ),
                            if (reg.phone != null && reg.phone!.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.phone_outlined, size: 14, color: AppTheme.textMuted),
                                  const SizedBox(width: 4),
                                  Text(reg.phone!, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                                ],
                              ),
                            if (reg.faculty != null && reg.faculty!.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.school_outlined, size: 14, color: AppTheme.textMuted),
                                  const SizedBox(width: 4),
                                  Text(reg.faculty!, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Phân công đội hình
                        if (reg.assignedTeam != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.youthBlueLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.groups, size: 18, color: AppTheme.youthBlue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Đội hình: ${reg.assignedTeam}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: AppTheme.youthBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],

                        // Điểm danh ngày công
                        if (reg.status == RegistrationStatus.approved) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreenLight.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.event_available, size: 18, color: AppTheme.primaryGreen),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Điểm danh ghi nhận: ${reg.attendanceDays} buổi tham gia',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryGreenDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Phản hồi / Lý do
                        if (reg.note != null && reg.note!.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppTheme.borderLight),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline, size: 16, color: AppTheme.textMuted),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Ghi chú BCH: ${reg.note}',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],

                        // Nút nộp báo cáo hoàn thành & upload ảnh minh chứng cho chiến dịch đã duyệt
                        if (reg.status == RegistrationStatus.approved) ...[
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SubmitReportScreen(
                                      preselectedCampaignId: reg.campaignId,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                              label: const Text(
                                'Nộp Báo Cáo Hoàn Thành & Ảnh',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        ],

                        // Nút xem chứng nhận nếu đã hoàn thành & được duyệt chứng nhận
                        if (reg.isCertified) ...[
                          const Divider(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CertificateScreen(registration: reg),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.military_tech, color: AppTheme.accentOrange),
                              label: const Text(
                                'Xem Giấy Chứng Nhận Mùa Hè Xanh',
                                style: TextStyle(color: AppTheme.accentOrange, fontWeight: FontWeight.bold),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.accentOrange),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
