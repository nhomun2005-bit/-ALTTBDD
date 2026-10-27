import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/campaign.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';

class AdminActivityScreen extends StatefulWidget {
  const AdminActivityScreen({super.key});

  @override
  State<AdminActivityScreen> createState() => _AdminActivityScreenState();
}

class _AdminActivityScreenState extends State<AdminActivityScreen> {
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

  void _showAddEditCampaignDialog([Campaign? existing]) {
    final isEdit = existing != null;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final locationCtrl = TextEditingController(text: existing?.location ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final reqCtrl = TextEditingController(text: existing?.requirements ?? '');
    final targetCtrl = TextEditingController(text: existing != null ? '${existing.targetVolunteers}' : '30');
    final hoursCtrl = TextEditingController(text: existing != null ? '${existing.volunteerHours}' : '40');
    final pointsCtrl = TextEditingController(text: existing != null ? '${existing.trainingPoints}' : '15');
    
    String category = existing?.category ?? 'Xây dựng công trình';
    String status = existing?.status ?? 'Đang tuyển';
    String? selectedFacultyId = existing?.facultyId;
    bool isNearCampus = existing?.isNearCampus ?? false;
    final distanceCtrl = TextEditingController(
      text: existing?.distanceFromCampusKm != null ? '${existing!.distanceFromCampusKm}' : '0.8',
    );
    DateTime startDate = existing?.startDate ?? DateTime.now().add(const Duration(days: 2));
    DateTime endDate = existing?.endDate ?? DateTime.now().add(const Duration(days: 15));
    final dateFormat = DateFormat('dd/MM/yyyy');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(isEdit ? Icons.edit_note : Icons.add_circle, color: AppTheme.primaryGreen),
                  const SizedBox(width: 8),
                  Text(
                    isEdit ? 'Cập Nhật Chiến Dịch / Hoạt Động' : 'Tạo Hoạt Động Tình Nguyện Mới',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(labelText: 'Tên hoạt động / chiến dịch *'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: category,
                              decoration: const InputDecoration(labelText: 'Mảng hoạt động *'),
                              items: const [
                                DropdownMenuItem(value: 'Xây dựng công trình', child: Text('Xây dựng công trình')),
                                DropdownMenuItem(value: 'Chuyển đổi số', child: Text('Chuyển đổi số')),
                                DropdownMenuItem(value: 'Dạy học hè', child: Text('Dạy học hè')),
                                DropdownMenuItem(value: 'Y tế vì cộng đồng', child: Text('Y tế vì cộng đồng')),
                                DropdownMenuItem(value: 'Đền ơn đáp nghĩa', child: Text('Đền ơn đáp nghĩa')),
                              ],
                              onChanged: (val) {
                                if (val != null) setDialogState(() => category = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: status,
                              decoration: const InputDecoration(labelText: 'Trạng thái *'),
                              items: const [
                                DropdownMenuItem(value: 'Đang tuyển', child: Text('Đang tuyển')),
                                DropdownMenuItem(value: 'Đang diễn ra', child: Text('Đang diễn ra')),
                                DropdownMenuItem(value: 'Đã hoàn thành', child: Text('Đã hoàn thành')),
                              ],
                              onChanged: (val) {
                                if (val != null) setDialogState(() => status = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: locationCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Địa bàn triển khai (Xã, Huyện, Tỉnh) *',
                          hintText: 'VD: Xã Long Hòa, Huyện Cần Giờ, TP.HCM',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: startDate,
                                  firstDate: DateTime(2025),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  setDialogState(() => startDate = picked);
                                }
                              },
                              icon: const Icon(Icons.calendar_today, size: 16),
                              label: Text('Từ: ${dateFormat.format(startDate)}'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: endDate,
                                  firstDate: startDate,
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  setDialogState(() => endDate = picked);
                                }
                              },
                              icon: const Icon(Icons.event, size: 16),
                              label: Text('Đến: ${dateFormat.format(endDate)}'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: targetCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Chỉ tiêu TNV (Người)'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: hoursCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Giờ TN quy định'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: pointsCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Điểm rèn luyện'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Chọn Khoa / Viện tổ chức
                      DropdownButtonFormField<String?>(
                        initialValue: selectedFacultyId,
                        decoration: const InputDecoration(labelText: 'Khoa / Viện tổ chức *'),
                        items: [
                          const DropdownMenuItem<String?>(value: null, child: Text('Chung Toàn Trường / Ban Chỉ Huy')),
                          ..._dataService.faculties.map((f) => DropdownMenuItem<String?>(
                            value: f.id,
                            child: Text('${f.name} (${f.code})'),
                          )),
                        ],
                        onChanged: (val) => setDialogState(() => selectedFacultyId = val),
                      ),
                      const SizedBox(height: 10),
                      // Switch Hoạt động gần trường
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isNearCampus ? Colors.red.shade50 : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isNearCampus ? Colors.red.shade200 : Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Hoạt động gần trường (< 5km)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              subtitle: const Text('Diễn ra tại trường hoặc phường lân cận', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                              value: isNearCampus,
                              onChanged: (val) => setDialogState(() => isNearCampus = val),
                            ),
                            if (isNearCampus) ...[
                              const SizedBox(height: 6),
                              TextField(
                                controller: distanceCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Khoảng cách từ cổng trường (km)',
                                  hintText: 'VD: 0.6',
                                  prefixIcon: Icon(Icons.near_me, size: 18),
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Mô tả nội dung công việc'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: reqCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Yêu cầu đối với tình nguyện viên'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Đóng'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty || locationCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng điền đủ tên hoạt động và địa bàn!')),
                      );
                      return;
                    }

                    String? facultyName;
                    if (selectedFacultyId != null) {
                      final f = _dataService.faculties.where((fac) => fac.id == selectedFacultyId);
                      if (f.isNotEmpty) facultyName = f.first.name;
                    }

                    final campaign = Campaign(
                      id: existing?.id ?? 'camp_${DateTime.now().millisecondsSinceEpoch}',
                      title: titleCtrl.text.trim(),
                      category: category,
                      location: locationCtrl.text.trim(),
                      startDate: startDate,
                      endDate: endDate,
                      targetVolunteers: int.tryParse(targetCtrl.text) ?? 30,
                      currentRegistered: existing?.currentRegistered ?? 0,
                      description: descCtrl.text.trim().isEmpty
                          ? 'Thực hiện các công trình thanh niên theo kế hoạch của Ban chỉ huy.'
                          : descCtrl.text.trim(),
                      requirements: reqCtrl.text.trim().isEmpty
                          ? 'Tinh thần xung kích, tuân thủ kỷ luật mặt trận.'
                          : reqCtrl.text.trim(),
                      volunteerHours: int.tryParse(hoursCtrl.text) ?? 40,
                      trainingPoints: int.tryParse(pointsCtrl.text) ?? 15,
                      status: status,
                      facultyId: selectedFacultyId,
                      facultyName: facultyName,
                      isNearCampus: isNearCampus,
                      distanceFromCampusKm: isNearCampus ? double.tryParse(distanceCtrl.text) : (double.tryParse(distanceCtrl.text) ?? 60.0),
                    );

                    _dataService.saveCampaign(campaign);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEdit ? 'Đã cập nhật hoạt động thành công!' : 'Đã tạo hoạt động mới thành công!'),
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                    );
                  },
                  child: Text(isEdit ? 'Lưu Thay Đổi' : 'Tạo Hoạt Động'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final campaigns = _dataService.campaigns;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quản Lý Chiến Dịch & Hoạt Động',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  Text(
                    'Tạo, cập nhật thời gian, địa bàn, chỉ tiêu tuyển quân và tiêu chuẩn ghi nhận',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditCampaignDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Thêm Hoạt Động Mới'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Danh sách hoạt động dạng bảng quản trị
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: ListView.separated(
                itemCount: campaigns.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final camp = campaigns[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryGreenLight,
                      child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreenDark)),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            camp.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: camp.status == 'Đang tuyển'
                                ? Colors.green.shade50
                                : (camp.status == 'Đang diễn ra' ? Colors.amber.shade50 : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            camp.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: camp.status == 'Đang tuyển'
                                  ? Colors.green.shade800
                                  : (camp.status == 'Đang diễn ra' ? Colors.amber.shade900 : Colors.grey.shade700),
                            ),
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
                            if (camp.facultyName != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Text(
                                  camp.facultyName!,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.youthBlue),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            if (camp.isNearCampus) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Text(
                                  '📍 Gần trường (${camp.distanceFromCampusKm ?? 0.8} km)',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: Colors.red.shade700),
                            const SizedBox(width: 4),
                            Text(camp.location, style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 16),
                            const Icon(Icons.event_outlined, size: 14, color: AppTheme.youthBlue),
                            const SizedBox(width: 4),
                            Text('${dateFormat.format(camp.startDate)} - ${dateFormat.format(camp.endDate)}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text('Chỉ tiêu: ${camp.currentRegistered}/${camp.targetVolunteers} TNV', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 14),
                            Text('Quy chuẩn: ${camp.volunteerHours} giờ | +${camp.trainingPoints} ĐRL', style: const TextStyle(fontSize: 12, color: AppTheme.primaryGreenDark, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppTheme.youthBlue, size: 20),
                          tooltip: 'Chỉnh sửa hoạt động',
                          onPressed: () => _showAddEditCampaignDialog(camp),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppTheme.dangerRed, size: 20),
                          tooltip: 'Xóa',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Xác nhận xóa'),
                                content: Text('Bạn có chắc muốn xóa hoạt động "${camp.title}" không?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
                                    onPressed: () {
                                      _dataService.deleteCampaign(camp.id);
                                      Navigator.pop(ctx);
                                    },
                                    child: const Text('Xóa'),
                                  ),
                                ],
                              ),
                            );
                          },
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
