import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task_report.dart';
import '../../models/registration.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../volunteer/certificate_screen.dart';
import '../../utils/file_helper.dart';

class AdminProofEvaluationScreen extends StatefulWidget {
  const AdminProofEvaluationScreen({super.key});

  @override
  State<AdminProofEvaluationScreen> createState() => _AdminProofEvaluationScreenState();
}

class _AdminProofEvaluationScreenState extends State<AdminProofEvaluationScreen> {
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

  void _showEvaluateDialog(TaskReport report) {
    final hoursCtrl = TextEditingController(text: '8');
    final pointsCtrl = TextEditingController(text: '5');
    final feedbackCtrl = TextEditingController(text: 'Hoàn thành tốt nhiệm vụ, minh chứng đạt yêu cầu mặt trận.');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.rate_review, color: AppTheme.primaryGreen),
              SizedBox(width: 8),
              Text('Đánh Giá & Chấm Điểm Báo Cáo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chiến sĩ: ${report.volunteerName} (MSSV: ${report.studentId})', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Nhiệm vụ: ${report.title}', style: const TextStyle(fontSize: 13, color: AppTheme.youthBlue)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(6)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Minh chứng nộp: ${report.proofDescription}', style: const TextStyle(fontSize: 12)),
                        if (report.proofImageBytes != null) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 180),
                              child: Image.memory(report.proofImageBytes!, fit: BoxFit.contain),
                            ),
                          ),
                          const SizedBox(height: 6),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final filename = report.proofImageName ?? 'minh_chung_${report.id}.png';
                              final savedPath = await saveAndDownloadFile(report.proofImageBytes!, filename);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(savedPath != null && savedPath.contains('\\')
                                        ? 'Đã tải ảnh về: $savedPath'
                                        : 'Đã tải ảnh $filename về máy!'),
                                    backgroundColor: AppTheme.primaryGreen,
                                    action: savedPath != null && savedPath.contains('\\')
                                        ? SnackBarAction(
                                            label: 'Mở File',
                                            textColor: Colors.white,
                                            onPressed: () => openSavedFile(savedPath),
                                          )
                                        : null,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.download, size: 14),
                            label: const Text('Tải ảnh minh chứng về máy', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: hoursCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Giờ tình nguyện ghi nhận'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: pointsCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Điểm rèn luyện cộng thêm'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Nhận xét của Chỉ huy trưởng:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: feedbackCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(hintText: 'Nhận xét ghi nhận hoặc yêu cầu chỉnh sửa...'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: AppTheme.dangerRed, side: const BorderSide(color: AppTheme.dangerRed)),
              onPressed: () {
                _dataService.evaluateTaskReport(
                  reportId: report.id,
                  status: ReportStatus.needsRevision,
                  awardedHours: 0,
                  awardedPoints: 0,
                  feedback: feedbackCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã yêu cầu sinh viên bổ sung thêm minh chứng!')),
                );
              },
              child: const Text('Yêu cầu bổ sung'),
            ),
            ElevatedButton(
              onPressed: () {
                final h = int.tryParse(hoursCtrl.text) ?? 8;
                final p = int.tryParse(pointsCtrl.text) ?? 5;
                _dataService.evaluateTaskReport(
                  reportId: report.id,
                  status: ReportStatus.approved,
                  awardedHours: h,
                  awardedPoints: p,
                  feedback: feedbackCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã duyệt báo cáo và cộng +$h giờ TN, +$p ĐRL cho ${report.volunteerName}!'),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              },
              child: const Text('Phê Duyệt Đạt'),
            ),
          ],
        );
      },
    );
  }

  void _showProofImageDialog(TaskReport report) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.image, color: AppTheme.youthBlue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Minh chứng: ${report.title}',
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chiến sĩ: ${report.volunteerName} (MSSV: ${report.studentId})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text('Chiến dịch: ${report.campaignTitle}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.youthBlue)),
                const SizedBox(height: 4),
                Text('Mô tả: ${report.proofDescription}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                const SizedBox(height: 12),
                if (report.proofImageBytes != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 350),
                      child: Image.memory(
                        report.proofImageBytes!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    ),
                  )
                else
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported_outlined, size: 44, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'Chưa có tệp hình ảnh đính kèm',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          if (report.proofImageBytes != null)
            ElevatedButton.icon(
              onPressed: () async {
                final filename = report.proofImageName ?? 'minh_chung_${report.id}.png';
                final savedPath = await saveAndDownloadFile(report.proofImageBytes!, filename);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(savedPath != null && savedPath.contains('\\')
                          ? 'Đã lưu ảnh vào: $savedPath'
                          : 'Đã tải ảnh $filename về máy!'),
                      backgroundColor: AppTheme.primaryGreen,
                      action: savedPath != null && savedPath.contains('\\')
                          ? SnackBarAction(
                              label: 'Mở File',
                              textColor: Colors.white,
                              onPressed: () => openSavedFile(savedPath),
                            )
                          : null,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Tải ảnh về máy'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.youthBlue),
            ),
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
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final reports = _dataService.taskReports;
    final approvedRegs = _dataService.registrations.where((r) => r.status == RegistrationStatus.approved).toList();

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
                    'Xem Xét Minh Chứng & Phê Duyệt Chứng Nhận',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  Text(
                    'Thẩm định kết quả công việc sinh viên nộp, ghi nhận điểm tích lũy và cấp Giấy chứng nhận điện tử',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Hai phân mục: Báo cáo minh chứng & Danh sách cấp chứng nhận
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cột trái: Danh sách Báo cáo minh chứng cần thẩm định
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              const Icon(Icons.assignment_turned_in_outlined, color: AppTheme.primaryGreen, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Báo Cáo Nhiệm Vụ & Minh Chứng Hiện Trường',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const Spacer(),
                              Text('${reports.length} báo cáo', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: reports.isEmpty
                              ? const Center(child: Text('Chưa có báo cáo nhiệm vụ nào được gửi'))
                              : ListView.separated(
                                  itemCount: reports.length,
                                  separatorBuilder: (_, _) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final rep = reports[index];

                                    Color statusColor;
                                    Color statusBg;
                                    switch (rep.status) {
                                      case ReportStatus.approved:
                                        statusColor = AppTheme.primaryGreenDark;
                                        statusBg = AppTheme.primaryGreenLight;
                                        break;
                                      case ReportStatus.needsRevision:
                                        statusColor = AppTheme.dangerRed;
                                        statusBg = Colors.red.shade50;
                                        break;
                                      case ReportStatus.pending:
                                        statusColor = AppTheme.accentOrange;
                                        statusBg = Colors.amber.shade50;
                                        break;
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '${rep.volunteerName} (MSSV: ${rep.studentId})',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                              const Spacer(),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(4)),
                                                child: Text(
                                                  rep.status.label,
                                                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            rep.title,
                                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textDark),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(rep.description, style: const TextStyle(fontSize: 12, color: AppTheme.textDark)),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: AppTheme.borderLight),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  rep.proofImageBytes != null ? Icons.image : Icons.attach_file,
                                                  size: 16,
                                                  color: AppTheme.youthBlue,
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    'Minh chứng: ${rep.proofDescription}',
                                                    style: const TextStyle(fontSize: 11, color: AppTheme.youthBlue),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (rep.proofImageBytes != null) ...[
                                                  const SizedBox(width: 6),
                                                  InkWell(
                                                    onTap: () => _showProofImageDialog(rep),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: AppTheme.youthBlue.withOpacity(0.12),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: const Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(Icons.visibility, size: 12, color: AppTheme.youthBlue),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            'Xem ảnh',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color: AppTheme.youthBlue,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text(
                                                'Gửi: ${dateFormat.format(rep.submittedAt)}',
                                                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                              ),
                                              const Spacer(),
                                              OutlinedButton.icon(
                                                onPressed: () => _showProofImageDialog(rep),
                                                icon: Icon(
                                                  rep.proofImageBytes != null ? Icons.image : Icons.description_outlined,
                                                  size: 13,
                                                ),
                                                label: Text(
                                                  rep.proofImageBytes != null ? 'Xem/Tải ảnh' : 'Chi tiết MC',
                                                  style: const TextStyle(fontSize: 11),
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton.icon(
                                                onPressed: () => _showEvaluateDialog(rep),
                                                icon: const Icon(Icons.rate_review, size: 14),
                                                label: const Text('Thẩm định & Chấm điểm', style: TextStyle(fontSize: 11)),
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                const SizedBox(width: 16),

                // Cột phải: Phê duyệt Giấy Chứng Nhận Điện Tử
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Icon(Icons.workspace_premium, color: AppTheme.accentGold, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Cấp Giấy Chứng Nhận MHX',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: approvedRegs.isEmpty
                              ? const Center(child: Text('Chưa có sinh viên hoàn thành'))
                              : ListView.separated(
                                  itemCount: approvedRegs.length,
                                  separatorBuilder: (_, _) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final reg = approvedRegs[index];
                                    return ListTile(
                                      dense: true,
                                      title: Text(reg.volunteerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text(
                                        'MSSV: ${reg.studentId} • Điểm danh: ${reg.attendanceDays} buổi',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      trailing: reg.isCertified
                                          ? IconButton(
                                              icon: const Icon(Icons.remove_red_eye_outlined, color: AppTheme.primaryGreen),
                                              tooltip: 'Xem chứng nhận đã cấp',
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => CertificateScreen(registration: reg),
                                                  ),
                                                );
                                              },
                                            )
                                          : ElevatedButton(
                                              onPressed: () {
                                                _dataService.issueCertificate(reg.id);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Đã phê duyệt và cấp Giấy chứng nhận cho ${reg.volunteerName}!'),
                                                    backgroundColor: AppTheme.primaryGreen,
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppTheme.accentOrange,
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              ),
                                              child: const Text('Phê Duyệt Cấp', style: TextStyle(fontSize: 11)),
                                            ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
