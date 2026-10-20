import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/campaign.dart';
import '../../models/registration.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import 'registration_dialog.dart';

class ActivityDetailScreen extends StatefulWidget {
  final Campaign campaign;

  const ActivityDetailScreen({super.key, required this.campaign});

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
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
    final dateFormat = DateFormat('dd/MM/yyyy');
    final campaign = widget.campaign;

    // Kiểm tra đã đăng ký chưa
    final isRegistered = _dataService.registrations.any(
      (r) => r.campaignId == campaign.id && r.volunteerId == _dataService.currentVolunteer.id,
    );
    final existingReg = isRegistered
        ? _dataService.registrations.firstWhere(
            (r) => r.campaignId == campaign.id && r.volunteerId == _dataService.currentVolunteer.id,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Hoạt động MHX'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
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
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreenLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          campaign.category,
                          style: const TextStyle(
                            color: AppTheme.primaryGreenDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: campaign.status == 'Đang tuyển'
                              ? Colors.green.shade50
                              : (campaign.status == 'Đang diễn ra' ? Colors.amber.shade50 : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          campaign.status,
                          style: TextStyle(
                            color: campaign.status == 'Đang tuyển'
                                ? Colors.green.shade800
                                : (campaign.status == 'Đang diễn ra' ? Colors.amber.shade900 : Colors.grey.shade700),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    campaign.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildIconText(Icons.location_on_outlined, campaign.location, Colors.red.shade700),
                  const SizedBox(height: 6),
                  _buildIconText(
                    Icons.calendar_month_outlined,
                    '${dateFormat.format(campaign.startDate)} - ${dateFormat.format(campaign.endDate)}',
                    AppTheme.youthBlue,
                  ),
                  const SizedBox(height: 6),
                  _buildIconText(
                    Icons.people_alt_outlined,
                    'Tuyển: ${campaign.currentRegistered}/${campaign.targetVolunteers} chiến sĩ tình nguyện',
                    AppTheme.primaryGreen,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Highlight metrics
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.youthBlueLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.timer_outlined, color: AppTheme.youthBlue, size: 24),
                        const SizedBox(height: 4),
                        Text(
                          '${campaign.volunteerHours} Giờ',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.youthBlue),
                        ),
                        const Text('Giờ tình nguyện', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade100),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.star_outline_rounded, color: AppTheme.accentGold, size: 24),
                        const SizedBox(height: 4),
                        Text(
                          '+${campaign.trainingPoints} Điểm',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.accentOrange),
                        ),
                        const Text('Điểm rèn luyện', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mô tả công việc
            const Text(
              'Nội dung công việc',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Text(
                campaign.description,
                style: const TextStyle(fontSize: 14, color: AppTheme.textDark, height: 1.45),
              ),
            ),
            const SizedBox(height: 16),

            // Yêu cầu đối với tình nguyện viên
            const Text(
              'Yêu cầu & Điều kiện tham gia',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Text(
                campaign.requirements,
                style: const TextStyle(fontSize: 14, color: AppTheme.textDark, height: 1.45),
              ),
            ),
            const SizedBox(height: 24),

            // Trạng thái hoặc nút đăng ký
            if (isRegistered) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: existingReg?.status == RegistrationStatus.approved
                      ? AppTheme.primaryGreenLight
                      : (existingReg?.status == RegistrationStatus.rejected ? Colors.red.shade50 : Colors.amber.shade50),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: existingReg?.status == RegistrationStatus.approved
                        ? AppTheme.primaryGreen
                        : (existingReg?.status == RegistrationStatus.rejected ? AppTheme.dangerRed : AppTheme.accentOrange),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          existingReg?.status == RegistrationStatus.approved
                              ? Icons.check_circle_outline
                              : (existingReg?.status == RegistrationStatus.rejected ? Icons.cancel_outlined : Icons.hourglass_top_outlined),
                          color: existingReg?.status == RegistrationStatus.approved
                              ? AppTheme.primaryGreen
                              : (existingReg?.status == RegistrationStatus.rejected ? AppTheme.dangerRed : AppTheme.accentOrange),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Trạng thái đơn: ${existingReg?.status.label}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: existingReg?.status == RegistrationStatus.approved
                                ? AppTheme.primaryGreenDark
                                : (existingReg?.status == RegistrationStatus.rejected ? AppTheme.dangerRed : AppTheme.accentOrange),
                          ),
                        ),
                      ],
                    ),
                    if (existingReg?.assignedTeam != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Đội hình phân công: ${existingReg!.assignedTeam}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                    if (existingReg?.note != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Ghi chú BCH: ${existingReg!.note}',
                        style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: campaign.status == 'Đã hoàn thành'
                      ? null
                      : () {
                          RegistrationDialog.show(
                            context,
                            campaign: campaign,
                            onSuccess: () {
                              if (mounted) setState(() {});
                            },
                          );
                        },
                  icon: const Icon(Icons.app_registration_rounded),
                  label: const Text('Đăng Ký Tham Gia Hoạt Động', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
          ),
        ),
      ],
    );
  }
}
