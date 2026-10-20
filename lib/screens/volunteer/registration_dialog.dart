import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/campaign.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';

class RegistrationDialog extends StatefulWidget {
  final Campaign campaign;
  final VoidCallback? onSuccess;

  const RegistrationDialog({
    super.key,
    required this.campaign,
    this.onSuccess,
  });

  static Future<bool?> show(
    BuildContext context, {
    required Campaign campaign,
    VoidCallback? onSuccess,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => RegistrationDialog(
        campaign: campaign,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<RegistrationDialog> createState() => _RegistrationDialogState();
}

class _RegistrationDialogState extends State<RegistrationDialog> {
  final _formKey = GlobalKey<FormState>();
  final DataService _dataService = DataService();

  late final TextEditingController _studentIdCtrl;
  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _facultyCtrl;

  bool _isCommitted = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final vol = _dataService.currentVolunteer;
    _studentIdCtrl = TextEditingController(text: vol.studentId);
    _fullNameCtrl = TextEditingController(text: vol.fullName);
    _phoneCtrl = TextEditingController(text: vol.phone);
    _facultyCtrl = TextEditingController(text: vol.faculty);
  }

  @override
  void dispose() {
    _studentIdCtrl.dispose();
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _facultyCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isCommitted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đồng ý cam kết trách nhiệm chiến sĩ tình nguyện.'),
          backgroundColor: AppTheme.accentOrange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = _dataService.registerForCampaign(
      campaign: widget.campaign,
      studentId: _studentIdCtrl.text.trim(),
      volunteerName: _fullNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      faculty: _facultyCtrl.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context, true);
      widget.onSuccess?.call();

      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn hoặc MSSV này đã đăng ký tham gia hoạt động này rồi!'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 28),
            SizedBox(width: 10),
            Text('Đăng Ký Thành Công!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hồ sơ đăng ký hoạt động "${widget.campaign.title}" đã được gửi tới Ban Chỉ Huy.',
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreenLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.notifications_active, color: AppTheme.primaryGreenDark, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Admin Ban Chỉ Huy đã nhận được thông báo xét duyệt. Đơn đã được lưu trong mục "Đã đăng ký"!',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryGreenDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Hoàn Tất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề Dialog
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreenLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.assignment_ind, color: AppTheme.primaryGreenDark, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Đăng Ký Hoạt Động MHX',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                            Text(
                              'Điền thông tin và bấm Xác nhận để đăng ký',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: AppTheme.textMuted),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tóm tắt thông tin hoạt động
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.campaign.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: Colors.red),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.campaign.location,
                                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_month_outlined, size: 14, color: AppTheme.youthBlue),
                                const SizedBox(width: 4),
                                Text(
                                  '${dateFormat.format(widget.campaign.startDate)} - ${dateFormat.format(widget.campaign.endDate)}',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '+${widget.campaign.trainingPoints} ĐRL • ${widget.campaign.volunteerHours} giờ',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'Thông Tin Sinh Viên Đăng Ký',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreenDark,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 1. MSSV
                  TextFormField(
                    controller: _studentIdCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Mã số sinh viên (MSSV) *',
                      hintText: 'Ví dụ: 22120098',
                      prefixIcon: Icon(Icons.badge_outlined, size: 20),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Vui lòng nhập MSSV';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // 2. Tên đăng ký
                  TextFormField(
                    controller: _fullNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên sinh viên *',
                      hintText: 'Ví dụ: Nguyễn Văn An',
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Vui lòng nhập họ và tên';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // 3. Số điện thoại
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại liên lạc *',
                      hintText: 'Ví dụ: 0987654321',
                      prefixIcon: Icon(Icons.phone_outlined, size: 20),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Vui lòng nhập số điện thoại';
                      }
                      if (val.trim().length < 9) {
                        return 'Số điện thoại không hợp lệ (tối thiểu 9 số)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // 4. Khoa
                  TextFormField(
                    controller: _facultyCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Khoa / Viện đào tạo *',
                      hintText: 'Ví dụ: Công nghệ Thông tin, Kinh tế...',
                      prefixIcon: Icon(Icons.school_outlined, size: 20),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Vui lòng nhập Khoa / Viện đào tạo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Checkbox cam kết
                  InkWell(
                    onTap: () => setState(() => _isCommitted = !_isCommitted),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _isCommitted,
                            onChanged: (val) => setState(() => _isCommitted = val ?? true),
                            activeColor: AppTheme.primaryGreen,
                          ),
                          const Expanded(
                            child: Text(
                              'Tôi cam kết chấp hành phân công của Ban Chỉ Huy và hoàn thành tốt nhiệm vụ.',
                              style: TextStyle(fontSize: 12, color: AppTheme.textDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: const Text('Hủy bỏ'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submit,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.check_circle_outline, size: 18),
                        label: Text(_isSubmitting ? 'Đang xử lý...' : 'Xác Nhận Đăng Ký'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
