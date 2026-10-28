import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/volunteer/volunteer_main_screen.dart';
import 'screens/admin/admin_main_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'services/data_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MuaHeXanhApp());
}

enum AppMode {
  volunteer, // Giao diện Mobile App cho Sinh viên, TNV
  admin,     // Giao diện Web Admin cho Ban chỉ huy
}

/// Tự động phân giải chế độ AppMode từ URL trình duyệt (hỗ trợ cả /admin, /#/admin, /student, /#/student)
AppMode resolveAppModeFromUri(Uri uri, [AppMode? fallback]) {
  // Chỉ phân giải từ URL trình duyệt khi chạy trên Web (giao thức http hoặc https)
  if (uri.scheme == 'http' || uri.scheme == 'https') {
    final path = uri.path.toLowerCase();
    final fragment = uri.fragment.toLowerCase();
    final full = uri.toString().toLowerCase();

    if (path.contains('/admin') || path == 'admin' || fragment.contains('admin') || full.contains('/admin')) {
      return AppMode.admin;
    }
    if (path.contains('student') || fragment.contains('student') || path.contains('volunteer') || fragment.contains('volunteer')) {
      return AppMode.volunteer;
    }
  }
  return fallback ?? AppMode.volunteer;
}

class MuaHeXanhApp extends StatelessWidget {
  const MuaHeXanhApp({super.key});

  @override
  Widget build(BuildContext context) {
    final activeMode = resolveAppModeFromUri(Uri.base);

    return MaterialApp(
      title: 'Chiến Dịch Tình Nguyện Mùa Hè Xanh',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      onGenerateRoute: (settings) {
        final rawPath = (settings.name ?? '').toLowerCase().trim();
        final mode = (rawPath.contains('admin') || activeMode == AppMode.admin)
            ? AppMode.admin
            : AppMode.volunteer;

        if (rawPath == '/login') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => AuthScreen(onSuccess: () {}),
          );
        }

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MainContainerScreen(initialMode: mode),
        );
      },
      home: MainContainerScreen(initialMode: activeMode),
    );
  }
}

class MainContainerScreen extends StatefulWidget {
  final AppMode initialMode;

  const MainContainerScreen({
    super.key,
    this.initialMode = AppMode.volunteer,
  });

  @override
  State<MainContainerScreen> createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> {
  final DataService _dataService = DataService();
  late AppMode _currentMode;

  @override
  void initState() {
    super.initState();
    _currentMode = resolveAppModeFromUri(Uri.base, widget.initialMode);
    _dataService.addListener(_onServiceUpdate);
  }

  @override
  void didUpdateWidget(MainContainerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMode != oldWidget.initialMode) {
      setState(() {
        _currentMode = resolveAppModeFromUri(Uri.base, widget.initialMode);
      });
    }
  }

  @override
  void dispose() {
    _dataService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // GATE: Nếu chưa đăng nhập → hiển thị màn hình Auth
    if (!_dataService.isLoggedIn) {
      return AuthScreen(
        onSuccess: () => setState(() {
          _currentMode = resolveAppModeFromUri(Uri.base, _currentMode);
        }),
      );
    }

    final currentUrlMode = resolveAppModeFromUri(Uri.base, _currentMode);
    final bool isAdmin = _dataService.isAdmin;
    final bool isAccessDenied = (!isAdmin && currentUrlMode == AppMode.admin);

    final Color badgeColor = isAccessDenied
        ? Colors.redAccent
        : (isAdmin && currentUrlMode == AppMode.admin)
            ? Colors.amberAccent
            : Colors.greenAccent;
    final Color badgeBg = isAccessDenied
        ? Colors.redAccent.withValues(alpha: 0.15)
        : (isAdmin && currentUrlMode == AppMode.admin)
            ? Colors.amber.withValues(alpha: 0.15)
            : Colors.greenAccent.withValues(alpha: 0.15);
    final String badgeText = isAccessDenied
        ? 'TỪ CHỐI TRUY CẬP (/admin)'
        : (isAdmin && currentUrlMode == AppMode.admin)
            ? 'CỔNG QUẢN TRỊ BAN CHỈ HUY (/admin)'
            : 'CỔNG SINH VIÊN TÌNH NGUYỆN (/student)';

    return Scaffold(
      body: Column(
        children: [
          // Thanh điều khiển trên cùng
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Cụm bên trái: Logo & Nút chuyển chế độ cho Admin
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.volunteer_activism, color: Colors.greenAccent, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'CHIẾN DỊCH MÙA HÈ XANH',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),

                            const SizedBox(width: 16),
                            // Hiển thị nhãn cổng hiện tại theo URL
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: badgeColor,
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                badgeText,
                                style: TextStyle(
                                  color: badgeColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 16),

                        // Cụm bên phải: Tên đăng nhập kèm ảnh đại diện, Đổi tài khoản, Đăng xuất
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ─── Tên đăng nhập kèm ảnh đại diện ───
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 13,
                                    backgroundColor: isAdmin
                                        ? const Color(0xFFDC2626)
                                        : AppTheme.primaryGreen,
                                    child: Icon(
                                      isAdmin ? Icons.shield : Icons.person,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _dataService.currentUser?.fullName ?? _dataService.currentUser?.username ?? 'Tình nguyện viên',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        isAdmin ? 'Ban Chỉ Huy' : 'Sinh viên',
                                        style: TextStyle(
                                          color: isAdmin ? Colors.redAccent.shade100 : Colors.greenAccent.shade100,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Nút Đổi Tài Khoản
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => Dialog(
                                    insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 520),
                                      child: AuthScreen(
                                        onSuccess: () {
                                          Navigator.of(context).pop();
                                          setState(() {
                                            if (!_dataService.isAdmin) {
                                              _currentMode = AppMode.volunteer;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.switch_account_outlined, size: 14, color: Colors.white),
                                    SizedBox(width: 5),
                                    Text(
                                      'Đổi Tài Khoản',
                                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Nút Đăng xuất
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    title: const Row(
                                      children: [
                                        Icon(Icons.logout, color: Colors.redAccent),
                                        SizedBox(width: 8),
                                        Text('Xác nhận đăng xuất', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    content: Text(
                                      'Bạn có chắc muốn đăng xuất tài khoản "${_dataService.currentUser?.username ?? ''}" không?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Hủy'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _dataService.logout();
                                          setState(() {
                                            _currentMode = AppMode.volunteer;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: const Text('Đăng xuất'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.logout, size: 14, color: Colors.redAccent),
                                    SizedBox(width: 5),
                                    Text(
                                      'Đăng xuất',
                                      style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
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

          // Nội dung chính: Nếu sinh viên truy cập /admin -> Hiển thị màn hình Từ chối truy cập
          Expanded(
            child: isAccessDenied
                ? _buildAccessDeniedView()
                : (isAdmin && currentUrlMode == AppMode.admin)
                    ? const AdminMainScreen()
                    : const VolunteerMainScreen(),
          ),
        ],
      ),
    );
  }

  // Màn hình thông báo không có quyền truy cập khi sinh viên gõ URL /admin
  Widget _buildAccessDeniedView() {
    final userName = _dataService.currentUser?.fullName ??
        _dataService.currentUser?.username ??
        'Sinh viên';

    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    size: 56,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '403 - KHÔNG CÓ QUYỀN TRUY CẬP',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.redAccent,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tài khoản "$userName" thuộc vai trò Sinh viên / Tình nguyện viên, không có quyền truy cập Cổng Quản Trị Ban Chỉ Huy (/admin).',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.amber.shade900),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Tài khoản sinh viên chỉ được phép sử dụng ở cổng /student.',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentMode = AppMode.volunteer;
                    });
                  },
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text(
                    'Chuyển Về Cổng Sinh Viên (/student)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

