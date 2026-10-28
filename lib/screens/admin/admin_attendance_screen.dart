import 'package:flutter/material.dart';
import '../../models/registration.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  final DataService _dataService = DataService();
  String? _selectedCampaignId;

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onUpdate);
    if (_dataService.campaigns.isNotEmpty) {
      _selectedCampaignId = _dataService.campaigns.first.id;
    }
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
    final campaigns = _dataService.campaigns;
    if (_selectedCampaignId == null && campaigns.isNotEmpty) {
      _selectedCampaignId = campaigns.first.id;
    }

    final currentCamp = campaigns.firstWhere(
      (c) => c.id == _selectedCampaignId,
      orElse: () => campaigns.first,
    );

    // Lấy các TNV đã duyệt trong chiến dịch này
    final approvedList = _dataService.registrations
        .where((r) => r.campaignId == _selectedCampaignId && r.status == RegistrationStatus.approved)
        .toList();

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
                    'Điểm Danh & Xác Nhận Giờ Tình Nguyện',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  Text(
                    'Ghi nhận ngày công thực tế, tính toán giờ tình nguyện đạt chuẩn theo quy chế Đoàn - Hội',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              Row(
                children: [
                  // Chọn chiến dịch
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedCampaignId,
                      underline: const SizedBox(),
                      items: campaigns.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Text(c.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCampaignId = val);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tóm tắt chiến dịch
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.youthBlueLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.youthBlue, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Chiến dịch: ${currentCamp.title} | Định mức hoàn thành: ${currentCamp.volunteerHours} giờ | Điểm rèn luyện: +${currentCamp.trainingPoints} điểm',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.youthBlue),
                  ),
                ),
                Text(
                  'Chiến sĩ đã duyệt: ${approvedList.length} người',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.youthBlue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Bảng điểm danh
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: approvedList.isEmpty
                  ? const Center(
                      child: Text(
                        'Chưa có chiến sĩ nào được duyệt vào hoạt động này.',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    )
                  : ListView.separated(
                      itemCount: approvedList.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final reg = approvedList[index];
                        final calculatedHours = reg.attendanceDays * 7; // Ước tính 7 giờ công tác / buổi

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppTheme.primaryGreenLight,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreenDark),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reg.volunteerName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      'MSSV: ${reg.studentId} • ${reg.assignedTeam ?? "Chưa phân đội"}',
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              // Bộ đếm điểm danh buổi tham gia
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.grey, size: 20),
                                      onPressed: reg.attendanceDays > 0
                                          ? () => _dataService.updateAttendance(reg.id, reg.attendanceDays - 1)
                                          : null,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppTheme.borderLight),
                                      ),
                                      child: Text(
                                        '${reg.attendanceDays} buổi',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle, color: AppTheme.primaryGreen, size: 20),
                                      onPressed: () => _dataService.updateAttendance(reg.id, reg.attendanceDays + 1),
                                    ),
                                  ],
                                ),
                              ),
                              // Số giờ tình nguyện xác nhận
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$calculatedHours giờ TN',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.youthBlue, fontSize: 14),
                                    ),
                                    Text(
                                      reg.attendanceDays >= 5 ? 'Đạt chỉ tiêu' : 'Đang thực hiện',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: reg.attendanceDays >= 5 ? AppTheme.primaryGreenDark : AppTheme.accentOrange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Đánh dấu hoàn thành
                              ElevatedButton(
                                onPressed: () {
                                  _dataService.updateAttendance(reg.id, reg.attendanceDays + 1);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Đã điểm danh cho chiến sĩ ${reg.volunteerName} (+1 buổi)!'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                child: const Text('Điểm Danh Hôm Nay', style: TextStyle(fontSize: 12)),
                              ),
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
