import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task_report.dart';
import '../../models/registration.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/file_helper.dart';
import '../../utils/image_picker_dialog.dart';

class SubmitReportScreen extends StatefulWidget {
  final String? preselectedCampaignId;

  const SubmitReportScreen({super.key, this.preselectedCampaignId});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onUpdate);

    // Nếu chuyển sang từ trang khác với campaignId chỉ định, tự động mở form nộp báo cáo
    if (widget.preselectedCampaignId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNewReportModal(preselectedCampaignId: widget.preselectedCampaignId);
      });
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

  void _showNewReportModal({String? preselectedCampaignId}) {
    // Lấy các chiến dịch mà sinh viên đã được duyệt
    final approvedCampaigns = _dataService.registrations
        .where((r) => r.volunteerId == _dataService.currentVolunteer.id && r.status == RegistrationStatus.approved)
        .toList();

    if (approvedCampaigns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần có ít nhất 1 chiến dịch đã được duyệt để gửi báo cáo nhiệm vụ.'),
          backgroundColor: AppTheme.accentOrange,
        ),
      );
      return;
    }

    String selectedCampaignId = preselectedCampaignId != null &&
            approvedCampaigns.any((r) => r.campaignId == preselectedCampaignId)
        ? preselectedCampaignId
        : approvedCampaigns.first.campaignId;

    String selectedCampaignTitle =
        approvedCampaigns.firstWhere((r) => r.campaignId == selectedCampaignId).campaignTitle;

    final titleController = TextEditingController();
    final descController = TextEditingController();
    final proofController = TextEditingController();
    String selectedProofType = 'image';
    Uint8List? pickedImageBytes;
    String? pickedImageName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.assignment_turned_in_outlined, color: AppTheme.primaryGreen),
                        const SizedBox(width: 8),
                        const Text(
                          'Gửi Báo Cáo & Minh Chứng',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Chọn hoạt động
                    const Text('Chiến dịch / Hoạt động', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCampaignId,
                      isExpanded: true,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                      items: approvedCampaigns.map((reg) {
                        return DropdownMenuItem(
                          value: reg.campaignId,
                          child: Text(
                            reg.campaignTitle,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            selectedCampaignId = val;
                            selectedCampaignTitle = approvedCampaigns.firstWhere((r) => r.campaignId == val).campaignTitle;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Tiêu đề báo cáo
                    const Text('Tiêu đề công việc hoàn thành', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: 'VD: Hoàn thành thi công mố cầu số 1, dọn vệ sinh 1.5km đường...',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Mô tả kết quả
                    const Text('Mô tả chi tiết kết quả thực hiện', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Nêu rõ khối lượng công việc, số người tham gia, thời gian hoàn thành...',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Loại minh chứng
                    const Text('Loại minh chứng đính kèm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Hình ảnh'),
                          selected: selectedProofType == 'image',
                          onSelected: (val) {
                            if (val) setModalState(() => selectedProofType = 'image');
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Video hoạt động'),
                          selected: selectedProofType == 'video',
                          onSelected: (val) {
                            if (val) setModalState(() => selectedProofType = 'video');
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Biên bản / Giấy xác nhận'),
                          selected: selectedProofType == 'document',
                          onSelected: (val) {
                            if (val) setModalState(() => selectedProofType = 'document');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Minh chứng Ảnh
                    if (selectedProofType == 'image') ...[
                      const Text('Ảnh minh chứng hiện trường (bắt buộc)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () async {
                          final result = await showImagePickerDialog(context);
                          if (result != null) {
                            setModalState(() {
                              pickedImageBytes = result.bytes;
                              pickedImageName = result.name;
                              proofController.text = result.name;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: pickedImageBytes != null
                                ? AppTheme.primaryGreenLight.withValues(alpha: 0.3)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: pickedImageBytes != null
                                  ? AppTheme.primaryGreen
                                  : Colors.grey.shade300,
                              width: pickedImageBytes != null ? 1.5 : 1.0,
                            ),
                          ),
                          child: pickedImageBytes != null
                              ? Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        pickedImageBytes!,
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 18),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            pickedImageName ?? 'Ảnh minh chứng đã chọn',
                                            style: const TextStyle(color: AppTheme.primaryGreenDark, fontSize: 13, fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton.icon(
                                          onPressed: () {
                                            setModalState(() {
                                              pickedImageBytes = null;
                                              pickedImageName = null;
                                            });
                                          },
                                          icon: const Icon(Icons.delete_outline, size: 14, color: AppTheme.dangerRed),
                                          label: const Text('Xoá', style: TextStyle(color: AppTheme.dangerRed, fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                    const Text('(Nhấn vào ảnh để đổi sang ảnh khác)', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                  ],
                                )
                              : const Column(
                                  children: [
                                    Icon(Icons.add_photo_alternate_rounded, size: 48, color: AppTheme.primaryGreen),
                                    SizedBox(height: 8),
                                    Text('Nhấn để chọn ảnh từ máy tính hoặc bộ ảnh mẫu thực địa', style: TextStyle(color: AppTheme.primaryGreenDark, fontSize: 13, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 4),
                                    Text('Hỗ trợ JPG, PNG, WEBP trên cả Máy tính & Trình duyệt', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Nếu không phải image, vẫn cho nhập text/link
                    if (selectedProofType != 'image') ...[
                      const Text('Thông tin đường link hoặc biên bản', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: proofController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: selectedProofType == 'video'
                              ? 'Dán đường link video (YouTube/Drive/Cloud)...'
                              : 'Mô tả biên bản hoặc tên file giấy xác nhận...',
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Nút gửi
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (titleController.text.trim().isEmpty || descController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập tiêu đề và mô tả công việc!')),
                            );
                            return;
                          }

                          // Kiểm tra ảnh nếu loại image
                          if (selectedProofType == 'image' && pickedImageBytes == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Vui lòng chọn ảnh minh chứng từ máy tính hoặc bộ ảnh mẫu!'),
                                backgroundColor: AppTheme.accentOrange,
                              ),
                            );
                            return;
                          }

                          _dataService.submitTaskReport(
                            campaignId: selectedCampaignId,
                            campaignTitle: selectedCampaignTitle,
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                            proofDescription: pickedImageName ?? (proofController.text.trim().isEmpty
                                ? 'Ảnh hiện trường nộp trực tiếp tại mặt trận'
                                : proofController.text.trim()),
                            proofType: selectedProofType,
                            proofImageBytes: pickedImageBytes,
                            proofImageName: pickedImageName,
                          );

                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã gửi báo cáo nhiệm vụ kèm ảnh minh chứng thành công!'),
                              backgroundColor: AppTheme.primaryGreen,
                            ),
                          );
                        },
                        icon: const Icon(Icons.send_rounded),
                        label: const Text('Gửi Báo Cáo Nhiệm Vụ', style: TextStyle(fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Modal cập nhật / bổ sung ảnh minh chứng để hoàn thiện báo cáo
  void _showEditReportModal(TaskReport report) {
    final titleController = TextEditingController(text: report.title);
    final descController = TextEditingController(text: report.description);
    Uint8List? pickedImageBytes = report.proofImageBytes;
    String? pickedImageName = report.proofImageName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.edit_note, color: AppTheme.accentOrange, size: 24),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Bổ Sung Ảnh & Hoàn Thiện Báo Cáo',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 6),

                    if (report.feedback != null && report.feedback!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.feedback_outlined, color: AppTheme.dangerRed, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Góp ý từ BCH: ${report.feedback}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.dangerRed, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    const Text('Tiêu đề công việc', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(controller: titleController),
                    const SizedBox(height: 12),

                    const Text('Mô tả kết quả', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(controller: descController, maxLines: 3),
                    const SizedBox(height: 12),

                    const Text('Ảnh minh chứng thực địa bổ sung', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () async {
                        final result = await showImagePickerDialog(context);
                        if (result != null) {
                          setModalState(() {
                            pickedImageBytes = result.bytes;
                            pickedImageName = result.name;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: pickedImageBytes != null
                              ? AppTheme.primaryGreenLight.withValues(alpha: 0.3)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: pickedImageBytes != null ? AppTheme.primaryGreen : Colors.grey.shade300,
                          ),
                        ),
                        child: pickedImageBytes != null
                            ? Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.memory(
                                      pickedImageBytes!,
                                      height: 160,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 16),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          pickedImageName ?? 'Ảnh mới đã chọn',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Text('(Nhấn để thay đổi ảnh)', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                ],
                              )
                            : const Column(
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppTheme.primaryGreen),
                                  SizedBox(height: 6),
                                  Text('Nhấn để tải lên ảnh minh chứng mới', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryGreenDark)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                        onPressed: () {
                          if (titleController.text.trim().isEmpty || descController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng không để trống thông tin!')),
                            );
                            return;
                          }

                          _dataService.updateTaskReport(
                            reportId: report.id,
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                            proofImageBytes: pickedImageBytes,
                            proofImageName: pickedImageName,
                            proofDescription: pickedImageName ?? report.proofDescription,
                            resubmit: true,
                          );

                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã cập nhật ảnh và nộp lại báo cáo thành công!'),
                              backgroundColor: AppTheme.primaryGreen,
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Cập Nhật & Nộp Lại Báo Cáo', style: TextStyle(fontSize: 15)),
                      ),
                    ),
                  ],
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
    final myReports = _dataService.taskReports
        .where((r) => r.volunteerId == _dataService.currentVolunteer.id)
        .toList();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo Cáo & Minh Chứng'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewReportModal(),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Gửi Báo Cáo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: myReports.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 56, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('Chưa có báo cáo nhiệm vụ nào được gửi', style: TextStyle(color: AppTheme.textMuted)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showNewReportModal(),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Nộp báo cáo đầu tiên'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: myReports.length,
              itemBuilder: (context, index) {
                final report = myReports[index];

                Color statusColor;
                Color statusBg;
                switch (report.status) {
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

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status & Date
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                report.status.label,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              dateFormat.format(report.submittedAt),
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Title
                        Text(
                          report.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Campaign name
                        Text(
                          report.campaignTitle,
                          style: const TextStyle(fontSize: 13, color: AppTheme.youthBlue, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),

                        // Description
                        Text(
                          report.description,
                          style: const TextStyle(fontSize: 13, color: AppTheme.textDark, height: 1.4),
                        ),
                        const SizedBox(height: 10),

                        // Proof card
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    report.proofType == 'video'
                                        ? Icons.video_file_outlined
                                        : (report.proofType == 'document' ? Icons.description_outlined : Icons.image_outlined),
                                    color: AppTheme.primaryGreen,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      report.proofDescription,
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
                                    ),
                                  ),
                                ],
                              ),
                              if (report.proofImageBytes != null) ...[
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.memory(
                                    report.proofImageBytes!,
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () async {
                                      final name = report.proofImageName ?? 'minh_chung_${report.id}.png';
                                      final savedPath = await saveAndDownloadFile(report.proofImageBytes!, name);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(savedPath != null && savedPath.contains('\\')
                                                ? 'Đã tải ảnh về: $savedPath'
                                                : 'Đã tải ảnh $name về máy!'),
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
                                    label: const Text('Tải ảnh về máy', style: TextStyle(fontSize: 11)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Nếu cần bổ sung minh chứng, hiển thị thông báo & nút bổ sung
                        if (report.status == ReportStatus.needsRevision) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, size: 18, color: AppTheme.dangerRed),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Yêu cầu bổ sung từ Ban chỉ huy:',
                                      style: TextStyle(color: AppTheme.dangerRed, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ),
                                if (report.feedback != null && report.feedback!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    report.feedback!,
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentOrange),
                                    onPressed: () => _showEditReportModal(report),
                                    icon: const Icon(Icons.add_photo_alternate, size: 16),
                                    label: const Text('Bổ Sung Ảnh & Hoàn Thiện Báo Cáo', style: TextStyle(fontSize: 13)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Nếu đang chờ đánh giá, vẫn cho phép chỉnh sửa nếu muốn
                        if (report.status == ReportStatus.pending) ...[
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => _showEditReportModal(report),
                              icon: const Icon(Icons.edit_outlined, size: 14),
                              label: const Text('Cập nhật / Đổi ảnh', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],

                        // Đánh giá từ người quản lý khi đã duyệt
                        if (report.status == ReportStatus.approved) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreenLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.verified, size: 16, color: AppTheme.primaryGreen),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Ghi nhận: +${report.awardedHours} giờ TN | +${report.awardedPoints} Điểm rèn luyện',
                                      style: const TextStyle(
                                        color: AppTheme.primaryGreenDark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                if (report.feedback != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Nhận xét BCH: ${report.feedback}',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
                                  ),
                                ],
                              ],
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
