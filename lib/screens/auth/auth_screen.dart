import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  final bool initialIsRegister;
  final VoidCallback? onSuccess;

  const AuthScreen({
    super.key,
    this.initialIsRegister = false,
    this.onSuccess,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final DataService _dataService = DataService();

  late bool _isRegister;

  // Controllers cho Đăng nhập
  final _loginUsernameCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  bool _obscureLoginPassword = true;

  // Controllers cho Đăng ký
  final _regFullNameCtrl = TextEditingController();
  final _regPhoneCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regAcademicYearCtrl = TextEditingController(text: 'Khóa 2022 - 2026');
  final _regStudentIdCtrl = TextEditingController();
  final _regUsernameCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _regConfirmPasswordCtrl = TextEditingController();
  String? _selectedFaculty;
  bool _obscureRegPassword = true;
  bool _obscureRegConfirmPassword = true;

  bool _isLoading = false;
  String? _errorMessage;

  // Trạng thái Loading chuyển tiếp 2-3s sau khi Đăng nhập / Đăng ký
  bool _isTransitionLoading = false;
  String _transitionTitle = '';
  String _transitionSubtitle = '';
  String _transitionStep = '';
  double _transitionProgress = 0.0;
  IconData _transitionIcon = Icons.verified_user_rounded;
  Color _transitionColor = AppTheme.primaryGreen;

  @override
  void initState() {
    super.initState();
    _isRegister = widget.initialIsRegister;
    _dataService.addListener(_onDataServiceChanged);
    _initSelectedFaculty();
  }

  void _onDataServiceChanged() {
    if (mounted) {
      setState(() {
        _initSelectedFaculty();
      });
    }
  }

  void _initSelectedFaculty() {
    final available = _dataService.faculties
        .map((f) => f.name.trim())
        .where((n) => n.isNotEmpty)
        .toSet();
    if (available.isNotEmpty) {
      if (_selectedFaculty == null || !available.contains(_selectedFaculty)) {
        _selectedFaculty = available.first;
      }
    }
  }

  @override
  void dispose() {
    _dataService.removeListener(_onDataServiceChanged);
    _loginUsernameCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _regFullNameCtrl.dispose();
    _regPhoneCtrl.dispose();
    _regEmailCtrl.dispose();
    _regAcademicYearCtrl.dispose();
    _regStudentIdCtrl.dispose();
    _regUsernameCtrl.dispose();
    _regPasswordCtrl.dispose();
    _regConfirmPasswordCtrl.dispose();
    super.dispose();
  }

  // Xử lý đăng nhập
  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
    });

    final username = _loginUsernameCtrl.text.trim();
    final password = _loginPasswordCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập tên tài khoản và mật khẩu.';
      });
      return;
    }

    setState(() => _isLoading = true);

    // Xác thực tài khoản với Firebase Authentication
    final result = await _dataService.loginWithFirebaseAuth(
      usernameOrEmail: username,
      password: password,
      applyImmediately: false,
    );

    setState(() => _isLoading = false);

    if (result.success && result.user != null) {
      final user = result.user!;

      // Hiển thị giao diện loading 2s đến 3s trước khi vào trang chủ
      setState(() {
        _isTransitionLoading = true;
        _transitionTitle = 'Đang Xác Thực Tài Khoản...';
        _transitionSubtitle = 'Xin chào ${user.fullName}!';
        _transitionStep = 'Kiểm tra bảo mật và quyền truy cập...';
        _transitionProgress = 0.25;
        _transitionIcon = Icons.verified_user_rounded;
        _transitionColor = AppTheme.primaryGreen;
      });

      await Future.delayed(const Duration(milliseconds: 750));
      if (!mounted) return;
      setState(() {
        _transitionStep = user.role == 'admin'
            ? 'Đang kết nối Bảng Điều Khiển Ban Chỉ Huy...'
            : 'Đang tải dữ liệu chiến dịch & bản đồ tình nguyện...';
        _transitionProgress = 0.70;
      });

      await Future.delayed(const Duration(milliseconds: 950));
      if (!mounted) return;
      setState(() {
        _transitionStep = 'Xác thực hoàn tất! Đang chuyển đến trang chủ...';
        _transitionProgress = 1.0;
      });

      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;

      // Hoàn tất đăng nhập và chuyển vào trang chủ
      _dataService.completeLogin(user);

      if (widget.onSuccess != null) {
        widget.onSuccess!();
      } else if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } else {
      setState(() {
        _errorMessage = result.message;
      });
    }
  }

  // Xử lý đăng ký
  Future<void> _handleRegister() async {
    setState(() {
      _errorMessage = null;
    });

    final fullName = _regFullNameCtrl.text.trim();
    final phone = _regPhoneCtrl.text.trim();
    final email = _regEmailCtrl.text.trim();
    final faculty = _selectedFaculty ?? (_dataService.faculties.isNotEmpty ? _dataService.faculties.first.name : 'Chung');
    final academicYear = _regAcademicYearCtrl.text.trim();
    final studentId = _regStudentIdCtrl.text.trim();
    final username = _regUsernameCtrl.text.trim();
    final password = _regPasswordCtrl.text.trim();
    final confirmPassword = _regConfirmPasswordCtrl.text.trim();

    if (fullName.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập họ và tên.');
      return;
    }
    if (phone.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập số điện thoại.');
      return;
    }
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập địa chỉ email.');
      return;
    }
    if (username.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập tên đăng nhập.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập mật khẩu.');
      return;
    }
    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Mật khẩu xác nhận không khớp.');
      return;
    }

    setState(() => _isLoading = true);

    // Đăng ký tài khoản nhưng KHÔNG tự động đăng nhập (autoLogin: false)
    final result = await _dataService.registerUser(
      fullName: fullName,
      phone: phone,
      email: email,
      faculty: faculty,
      academicYear: academicYear.isNotEmpty ? academicYear : 'Khóa 2022 - 2026',
      studentId: studentId.isNotEmpty ? studentId : null,
      username: username,
      password: password,
      autoLogin: false,
    );

    setState(() => _isLoading = false);

    if (result.success) {
      // Hiển thị giao diện loading tầm 2s - 3s
      setState(() {
        _isTransitionLoading = true;
        _transitionTitle = 'Đang Thiết Lập Tài Khoản...';
        _transitionSubtitle = 'Tạo hồ sơ tình nguyện viên cho $fullName';
        _transitionStep = 'Đang lưu tài khoản và đồng bộ cơ sở dữ liệu...';
        _transitionProgress = 0.25;
        _transitionIcon = Icons.app_registration_rounded;
        _transitionColor = const Color(0xFF0284C7);
      });

      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() {
        _transitionStep = 'Đã lưu thông tin an toàn trên Firebase Realtime DB...';
        _transitionProgress = 0.70;
      });

      await Future.delayed(const Duration(milliseconds: 950));
      if (!mounted) return;
      setState(() {
        _transitionStep = 'Khởi tạo thành công! Đang chuyển về màn hình đăng nhập...';
        _transitionProgress = 1.0;
      });

      await Future.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;

      // Kết thúc loading, chuyển sang tab Đăng Nhập và yêu cầu đăng nhập lại
      setState(() {
        _isTransitionLoading = false;
        _isRegister = false;
        _loginUsernameCtrl.text = username;
        _loginPasswordCtrl.clear();
        _regPasswordCtrl.clear();
        _regConfirmPasswordCtrl.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '🎉 Đăng ký tài khoản thành công! Vui lòng nhập mật khẩu để đăng nhập.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      setState(() {
        _errorMessage = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo & Header
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00B074), Color(0xFF0D9488)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00B074).withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.volunteer_activism,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'MÙA HÈ XANH',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Cổng Thông Tin Tình Nguyện & Quản Lý Chiến Dịch',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Card chứa Form
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tab chuyển Đăng nhập / Đăng ký
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() {
                                    _isRegister = false;
                                    _errorMessage = null;
                                  }),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: !_isRegister ? Colors.white : Colors.transparent,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: !_isRegister
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.05),
                                                blurRadius: 6,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Đăng Nhập',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: !_isRegister
                                              ? AppTheme.primaryGreen
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() {
                                    _isRegister = true;
                                    _errorMessage = null;
                                  }),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _isRegister ? Colors.white : Colors.transparent,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: _isRegister
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.05),
                                                blurRadius: 6,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Đăng Ký Tài Khoản',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: _isRegister
                                              ? AppTheme.primaryGreen
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Báo lỗi nếu có
                              if (_errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.red.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Nội dung Form theo Tab
                              if (!_isRegister)
                                _buildLoginForm()
                              else
                                _buildRegisterForm(),

                              const SizedBox(height: 24),

                              // Nút Submit
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : (_isRegister ? _handleRegister : _handleLogin),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryGreen,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          _isRegister ? 'ĐĂNG KÝ TÀI KHOẢN' : 'ĐĂNG NHẬP',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

          // Lớp phủ Giao diện Loading chuyển tiếp 2s đến 3s
          if (_isTransitionLoading)
            _buildTransitionLoadingOverlay(),
        ],
      ),
    );
  }

  // Giao diện Loading Chuyển tiếp (2s đến 3s)
  Widget _buildTransitionLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.65),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              constraints: const BoxConstraints(maxWidth: 380),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Pulsing Icon
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 86,
                        height: 86,
                        child: CircularProgressIndicator(
                          value: _transitionProgress > 0 ? _transitionProgress : null,
                          strokeWidth: 3.5,
                          color: _transitionColor,
                          backgroundColor: _transitionColor.withValues(alpha: 0.15),
                        ),
                      ),
                      Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          color: _transitionColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _transitionIcon,
                          color: _transitionColor,
                          size: 34,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tiêu đề
                  Text(
                    _transitionTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Mô tả phụ
                  Text(
                    _transitionSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Thanh tiến trình Linear
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 8,
                      color: const Color(0xFFF1F5F9),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              width: constraints.maxWidth * _transitionProgress.clamp(0.0, 1.0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _transitionColor,
                                    _transitionColor.withValues(alpha: 0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Thông điệp trạng thái & phần trăm
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _transitionStep,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(_transitionProgress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: _transitionColor,
                          fontWeight: FontWeight.bold,
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

  // Form Đăng nhập
  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextFieldLabel('Tên đăng nhập hoặc Email'),
        TextFormField(
          controller: _loginUsernameCtrl,
          decoration: _inputDecoration(
            hintText: 'Nhập tên đăng nhập hoặc email',
            prefixIcon: Icons.person_outline,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextFieldLabel('Mật khẩu'),
        TextFormField(
          controller: _loginPasswordCtrl,
          obscureText: _obscureLoginPassword,
          decoration: _inputDecoration(
            hintText: 'Nhập mật khẩu',
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureLoginPassword ? Icons.visibility_off : Icons.visibility,
                size: 20,
                color: Colors.grey.shade600,
              ),
              onPressed: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _showForgotPasswordDialog,
            icon: const Icon(Icons.lock_reset_rounded, size: 16, color: AppTheme.primaryGreenDark),
            label: const Text(
              'Quên mật khẩu?',
              style: TextStyle(
                color: AppTheme.primaryGreenDark,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
    );
  }

  // Hộp thoại khôi phục mật khẩu qua Liên kết Email (Firebase Password Reset Link)
  void _showForgotPasswordDialog() {
    final messenger = ScaffoldMessenger.of(context);
    final accountCtrl = TextEditingController(
      text: _loginUsernameCtrl.text.trim(),
    );

    int step = 1; // 1: Nhập tài khoản/email, 2: Xác nhận đã gửi link qua email
    bool isSubmitting = false;
    String? dialogError;
    String? resolvedEmail;
    String? resolvedUsername;

    showDialog(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: step == 1 ? AppTheme.primaryGreenLight : Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              step == 1 ? Icons.lock_reset_rounded : Icons.mark_email_read_rounded,
                              color: step == 1 ? AppTheme.primaryGreenDark : AppTheme.youthBlue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step == 1 ? 'Khôi Phục Mật Khẩu' : 'Đã Gửi Liên Kết Xác Nhận',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
                                ),
                                Text(
                                  step == 1
                                      ? 'Nhận liên kết đặt lại mật khẩu qua Email'
                                      : 'Gửi tới ${resolvedEmail ?? accountCtrl.text.trim()}',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: isSubmitting ? null : () => Navigator.pop(dialogCtx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      if (dialogError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, size: 16, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(dialogError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Bước 1: Nhập tên tài khoản, MSSV hoặc Email
                      if (step == 1) ...[
                        const Text(
                          'Nhập Tên tài khoản, MSSV hoặc địa chỉ Email đã đăng ký. Hệ thống sẽ tự động gửi đường dẫn liên kết đặt lại mật khẩu về đúng hòm thư liên kết của tài khoản đó.',
                          style: TextStyle(fontSize: 13, color: AppTheme.textDark, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        _buildTextFieldLabel('Tên tài khoản, MSSV hoặc Email *'),
                        TextFormField(
                          controller: accountCtrl,
                          decoration: _inputDecoration(
                            hintText: 'ví dụ: annguyen, 22120098 hoặc email@gmail.com',
                            prefixIcon: Icons.account_circle_outlined,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    final input = accountCtrl.text.trim();
                                    if (input.isEmpty) {
                                      setModalState(() => dialogError = 'Vui lòng nhập tên tài khoản hoặc địa chỉ email.');
                                      return;
                                    }
                                    setModalState(() {
                                      isSubmitting = true;
                                      dialogError = null;
                                    });

                                    final res = await _dataService.sendPasswordResetEmailLink(input);
                                    setModalState(() => isSubmitting = false);

                                    if (res.success) {
                                      setModalState(() {
                                        resolvedEmail = res.targetEmail;
                                        resolvedUsername = res.username;
                                        step = 2;
                                        dialogError = null;
                                      });
                                    } else {
                                      setModalState(() => dialogError = res.message);
                                    }
                                  },
                            icon: isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.send_rounded, size: 18),
                            label: Text(
                              isSubmitting ? 'ĐANG GỬI LIÊN KẾT...' : 'GỬI LIÊN KẾT ĐẶT LẠI MẬT KHẨU',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],

                      // Bước 2: Thông báo đã gửi liên kết thành công
                      if (step == 2) ...[
                        // Hộp thông tin tài khoản và email liên kết
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.youthBlueLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, size: 18, color: AppTheme.youthBlue),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Thông tin gửi email:',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.youthBlue),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '• Tài khoản: ${resolvedUsername ?? accountCtrl.text.trim()}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textDark, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '• Email nhận liên kết: ${resolvedEmail ?? accountCtrl.text.trim()}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textDark, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),

                        // Hướng dẫn mở email và bấm link
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Các bước tiếp theo:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '1. Mở ứng dụng Gmail hoặc hòm thư của bạn.\n'
                                '2. Tìm email từ "duanmuahexanh" (kiểm tra cả mục Hộp thư đến và Thư rác / Spam).\n'
                                '3. Nhấn vào đường liên kết (Link) trong thư để đặt mật khẩu mới trên trình duyệt web.\n'
                                '4. Sau khi đổi mật khẩu xong, quay lại ứng dụng để đăng nhập bằng mật khẩu mới.',
                                style: TextStyle(fontSize: 12, color: AppTheme.textDark, height: 1.5),
                              ),
                            ],
                          ),
                        ),

                        // Nút Quay lại đăng nhập
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(dialogCtx);
                              _loginUsernameCtrl.text = resolvedUsername ?? resolvedEmail ?? accountCtrl.text.trim();
                              _loginPasswordCtrl.clear();
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Vui lòng kiểm tra email ${resolvedEmail ?? accountCtrl.text.trim()} để đặt lại mật khẩu.',
                                  ),
                                  backgroundColor: AppTheme.primaryGreenDark,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.login_rounded, size: 18),
                            label: const Text(
                              'ĐÃ HIỂU - QUAY LẠI ĐĂNG NHẬP',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Nút gửi lại email nếu chưa nhận được
                        Center(
                          child: TextButton.icon(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    setModalState(() {
                                      isSubmitting = true;
                                      dialogError = null;
                                    });
                                    final res = await _dataService.sendPasswordResetEmailLink(
                                      resolvedEmail ?? accountCtrl.text.trim(),
                                    );
                                    setModalState(() => isSubmitting = false);
                                    if (res.success) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text('Đã gửi lại liên kết tới ${resolvedEmail ?? accountCtrl.text.trim()}!'),
                                          backgroundColor: AppTheme.primaryGreenDark,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    } else {
                                      setModalState(() => dialogError = res.message);
                                    }
                                  },
                            icon: const Icon(Icons.refresh_rounded, size: 16, color: AppTheme.textMuted),
                            label: const Text(
                              'Chưa nhận được email? Gửi lại liên kết',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Form Đăng ký
  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Họ và tên
        _buildTextFieldLabel('Họ và tên *'),
        TextFormField(
          controller: _regFullNameCtrl,
          decoration: _inputDecoration(
            hintText: 'Ví dụ: Nguyễn Văn An',
            prefixIcon: Icons.badge_outlined,
          ),
        ),
        const SizedBox(height: 14),

        // 2. Số điện thoại & Email
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFieldLabel('Số điện thoại *'),
                  TextFormField(
                    controller: _regPhoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration(
                      hintText: '0987654321',
                      prefixIcon: Icons.phone_outlined,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFieldLabel('Email sinh viên *'),
                  TextFormField(
                    controller: _regEmailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(
                      hintText: 'sv@sinhvien.edu.vn',
                      prefixIcon: Icons.email_outlined,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 3. Khoa / Viện
        _buildTextFieldLabel('Khoa / Viện đào tạo *'),
        Builder(
          builder: (context) {
            // Lọc danh sách tên khoa duy nhất, loại bỏ trùng lặp và rỗng
            final facultyNames = <String>[];
            final seenNames = <String>{};
            for (final f in _dataService.faculties) {
              final name = f.name.trim();
              if (name.isNotEmpty && seenNames.add(name)) {
                facultyNames.add(name);
              }
            }
            if (facultyNames.isEmpty) {
              facultyNames.addAll([
                'Khoa Công nghệ Thông tin & TT',
                'Khoa Kỹ thuật Xây dựng',
                'Khoa Y Dược & Sức Khỏe',
                'Khoa Sư phạm & Ngôn ngữ',
                'Khoa Môi trường & Đô thị',
              ]);
            }

            final currentSelectedValue = (facultyNames.contains(_selectedFaculty))
                ? _selectedFaculty
                : facultyNames.first;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: currentSelectedValue,
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                  items: facultyNames.map((name) {
                    return DropdownMenuItem<String>(
                      value: name,
                      child: Text(
                        name,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedFaculty = val);
                  },
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),

        // 4. Niên khóa & Mã số sinh viên
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFieldLabel('Niên khóa *'),
                  TextFormField(
                    controller: _regAcademicYearCtrl,
                    decoration: _inputDecoration(
                      hintText: 'Ví dụ: K22 (2022-2026)',
                      prefixIcon: Icons.date_range_outlined,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFieldLabel('Mã số sinh viên (MSSV)'),
                  TextFormField(
                    controller: _regStudentIdCtrl,
                    decoration: _inputDecoration(
                      hintText: 'Ví dụ: 22120098',
                      prefixIcon: Icons.numbers_outlined,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 5. Tên đăng nhập
        _buildTextFieldLabel('Tên đăng nhập *'),
        TextFormField(
          controller: _regUsernameCtrl,
          decoration: _inputDecoration(
            hintText: 'Ví dụ: nguyenvana22',
            prefixIcon: Icons.account_circle_outlined,
          ),
        ),
        const SizedBox(height: 14),

        // 6. Mật khẩu
        _buildTextFieldLabel('Mật khẩu (tối thiểu 6 ký tự) *'),
        TextFormField(
          controller: _regPasswordCtrl,
          obscureText: _obscureRegPassword,
          decoration: _inputDecoration(
            hintText: 'Nhập mật khẩu',
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureRegPassword ? Icons.visibility_off : Icons.visibility,
                size: 20,
                color: Colors.grey.shade600,
              ),
              onPressed: () => setState(() => _obscureRegPassword = !_obscureRegPassword),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 7. Xác nhận mật khẩu
        _buildTextFieldLabel('Xác nhận lại mật khẩu *'),
        TextFormField(
          controller: _regConfirmPasswordCtrl,
          obscureText: _obscureRegConfirmPassword,
          decoration: _inputDecoration(
            hintText: 'Nhập lại mật khẩu trên',
            prefixIcon: Icons.lock_reset,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureRegConfirmPassword ? Icons.visibility_off : Icons.visibility,
                size: 20,
                color: Colors.grey.shade600,
              ),
              onPressed: () => setState(() => _obscureRegConfirmPassword = !_obscureRegConfirmPassword),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
      prefixIcon: Icon(prefixIcon, size: 20, color: const Color(0xFF64748B)),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 1.6),
      ),
    );
  }
}
