import 'package:flutter/material.dart';
import '../../models/faculty.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';

class AdminFacultyScreen extends StatefulWidget {
  const AdminFacultyScreen({super.key});

  @override
  State<AdminFacultyScreen> createState() => _AdminFacultyScreenState();
}

class _AdminFacultyScreenState extends State<AdminFacultyScreen> {
  final DataService _dataService = DataService();
  String _searchKeyword = '';

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

  void _showAddEditFacultyDialog([Faculty? existing]) {
    final isEdit = existing != null;
    final codeCtrl = TextEditingController(text: existing?.code ?? '');
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final leaderCtrl = TextEditingController(text: existing?.leaderName ?? '');
    final phoneCtrl = TextEditingController(text: existing?.contactPhone ?? '');
    int selectedColor = existing?.colorValue ?? 0xFF1E88E5;

    final colorOptions = [
      0xFF1E88E5, // Blue
      0xFFE65100, // Deep Orange
      0xFF00897B, // Teal
      0xFF7B1FA2, // Purple
      0xFF43A047, // Green
      0xFFD32F2F, // Red
      0xFF3949AB, // Indigo
      0xFF00ACC1, // Cyan
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreenLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(isEdit ? Icons.edit : Icons.domain_add, color: AppTheme.primaryGreenDark, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isEdit ? 'Chỉnh Sửa Khoa / Viện' : 'Thêm Mới Khoa / Viện',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                ],
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: codeCtrl,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                labelText: 'Mã Khoa / Viện *',
                                hintText: 'VD: CNTT, KTXD',
                                prefixIcon: Icon(Icons.tag, size: 18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 4,
                            child: TextField(
                              controller: nameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Tên Khoa / Viện đầy đủ *',
                                hintText: 'VD: Khoa Công nghệ Thông tin',
                                prefixIcon: Icon(Icons.school_outlined, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: leaderCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Đại diện / Bí thư Đoàn khoa',
                                hintText: 'Họ tên và chức vụ',
                                prefixIcon: Icon(Icons.person_outline, size: 18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: phoneCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Số điện thoại liên hệ',
                                hintText: 'VD: 0901234567',
                                prefixIcon: Icon(Icons.phone_outlined, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả / Mảng chuyên môn phụ trách',
                          hintText: 'VD: Phụ trách mũi nhọn chuyển đổi số, tổ chức các lớp tin học cộng đồng...',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Màu sắc đại diện Khoa:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        children: colorOptions.map((c) {
                          final isPicked = selectedColor == c;
                          return InkWell(
                            onTap: () => setDialogState(() => selectedColor = c),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Color(c),
                                shape: BoxShape.circle,
                                border: isPicked ? Border.all(color: Colors.black87, width: 2.5) : null,
                                boxShadow: [
                                  if (isPicked)
                                    BoxShadow(
                                      color: Color(c).withValues(alpha: 0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                ],
                              ),
                              child: isPicked ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Hủy'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save, size: 16),
                  label: Text(isEdit ? 'Lưu Thay Đổi' : 'Tạo Khoa Mới'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                  onPressed: () {
                    final code = codeCtrl.text.trim();
                    final name = nameCtrl.text.trim();
                    if (code.isEmpty || name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng nhập Mã và Tên Khoa/Viện!')),
                      );
                      return;
                    }

                    final faculty = Faculty(
                      id: existing?.id ?? 'fac_${DateTime.now().millisecondsSinceEpoch}',
                      code: code,
                      name: name,
                      description: descCtrl.text.trim(),
                      leaderName: leaderCtrl.text.trim(),
                      contactPhone: phoneCtrl.text.trim(),
                      colorValue: selectedColor,
                    );

                    _dataService.saveFaculty(faculty);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEdit ? 'Đã cập nhật thông tin khoa.' : 'Đã thêm khoa mới thành công.')),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteFaculty(Faculty faculty) {
    final activityCount = _dataService.getCampaignCountByFaculty(faculty.id);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            const Text('Xác Nhận Xóa Khoa / Viện', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn có chắc chắn muốn xóa khoa "${faculty.name}" (Mã: ${faculty.code})?'),
            if (activityCount > 0) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Khoa này hiện đang có $activityCount hoạt động liên kết. Nếu xóa, các hoạt động sẽ không còn thuộc khoa này.',
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _dataService.deleteFaculty(faculty.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa khoa "${faculty.name}".')),
              );
            },
            child: const Text('Xác nhận xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFacultyActivitiesDialog(Faculty faculty) {
    final activities = _dataService.getCampaignsByFaculty(faculty.id);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(faculty.colorValue).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.campaign, color: Color(faculty.colorValue), size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoạt Động Của ${faculty.name}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Tổng cộng ${activities.length} hoạt động thuộc khoa',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 550,
          height: 380,
          child: activities.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 10),
                      const Text(
                        'Khoa này chưa có hoạt động nào được tạo',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: activities.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final camp = activities[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryGreenLight,
                        child: Text('${index + 1}', style: const TextStyle(color: AppTheme.primaryGreenDark, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(camp.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text(
                        'Địa bàn: ${camp.location}\nThời gian: ${camp.startDate.day}/${camp.startDate.month} - ${camp.endDate.day}/${camp.endDate.month}/${camp.endDate.year} • Tuyển: ${camp.currentRegistered}/${camp.targetVolunteers}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: camp.status == 'Đã hoàn thành'
                              ? Colors.grey.shade200
                              : AppTheme.primaryGreenLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          camp.status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: camp.status == 'Đã hoàn thành'
                                ? Colors.grey.shade700
                                : AppTheme.primaryGreenDark,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final faculties = _dataService.faculties.where((f) {
      if (_searchKeyword.isEmpty) return true;
      final q = _searchKeyword.toLowerCase();
      return f.name.toLowerCase().contains(q) ||
          f.code.toLowerCase().contains(q) ||
          f.leaderName.toLowerCase().contains(q);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quản Lý Khoa / Viện Trực Thuộc',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quản lý danh sách các Khoa/Viện, phân quyền tổ chức hoạt động và cho phép sinh viên lọc chiến dịch theo đơn vị.',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm Khoa / Viện Mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _showAddEditFacultyDialog(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search and Summary
          Row(
            children: [
              SizedBox(
                width: 320,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm theo mã hoặc tên khoa...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    suffixIcon: _searchKeyword.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _searchKeyword = ''),
                          )
                        : null,
                  ),
                  onChanged: (val) => setState(() => _searchKeyword = val),
                ),
              ),
              const SizedBox(width: 16),
              Chip(
                backgroundColor: AppTheme.primaryGreenLight,
                label: Text(
                  'Tổng cộng: ${_dataService.faculties.length} Khoa / Viện',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreenDark, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Table / Grid of faculties
          Expanded(
            child: faculties.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text('Không tìm thấy Khoa/Viện phù hợp', style: TextStyle(color: AppTheme.textMuted)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: faculties.length,
                    itemBuilder: (context, index) {
                      final fac = faculties[index];
                      final activityCount = _dataService.getCampaignCountByFaculty(fac.id);
                      final cardColor = Color(fac.colorValue);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Mã Khoa Avatar
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: cardColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: cardColor.withValues(alpha: 0.4), width: 1.5),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  fac.code,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: cardColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Info
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          fac.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: Colors.grey.shade300),
                                          ),
                                          child: Text(
                                            'Mã: ${fac.code}',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      fac.description.isNotEmpty ? fac.description : 'Chưa có mô tả chi tiết.',
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        if (fac.leaderName.isNotEmpty) ...[
                                          const Icon(Icons.person_outline, size: 14, color: AppTheme.youthBlue),
                                          const SizedBox(width: 4),
                                          Text(
                                            fac.leaderName,
                                            style: const TextStyle(fontSize: 12, color: AppTheme.textDark, fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(width: 14),
                                        ],
                                        if (fac.contactPhone.isNotEmpty) ...[
                                          const Icon(Icons.phone_outlined, size: 14, color: Colors.green),
                                          const SizedBox(width: 4),
                                          Text(
                                            fac.contactPhone,
                                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Activity count badge & button
                              InkWell(
                                onTap: () => _showFacultyActivitiesDialog(fac),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreenLight,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.campaign_outlined, size: 18, color: AppTheme.primaryGreenDark),
                                      const SizedBox(width: 6),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$activityCount Hoạt Động',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: AppTheme.primaryGreenDark,
                                            ),
                                          ),
                                          const Text(
                                            'Bấm xem chi tiết',
                                            style: TextStyle(fontSize: 10, color: AppTheme.primaryGreenDark),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Actions: Edit / Delete
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Chỉnh sửa thông tin khoa',
                                    icon: const Icon(Icons.edit_outlined, color: AppTheme.youthBlue, size: 20),
                                    onPressed: () => _showAddEditFacultyDialog(fac),
                                  ),
                                  IconButton(
                                    tooltip: 'Xóa khoa',
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                    onPressed: () => _confirmDeleteFaculty(fac),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
