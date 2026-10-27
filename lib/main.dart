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

class MuaHeXanhApp extends StatelessWidget {
  const MuaHeXanhApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chiến Dịch Tình Nguyện Mùa Hè Xanh',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainContainerScreen(),
    );
  }
}

enum AppMode {
  volunteer, // Giao diện Mobile App cho Sinh viên, TNV
  admin,     // Giao diện Web Admin cho Ban chỉ huy
}

class MainContainerScreen extends StatefulWidget {
  const MainContainerScreen({super.key});

  @override
  State<MainContainerScreen> createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> {
  final DataService _dataService = DataService();
  AppMode _currentMode = AppMode.volunteer;

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onServiceUpdate);
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
        onSuccess: () => setState(() {}),
      );
    }

    final bool isAdmin = _dataService.isAdmin;
    // Kiểm soát quyền truy cập: Người dùng thông thường (user/volunteer) KHÔNG được vào trang Admin
    final AppMode effectiveMode = isAdmin ? _currentMode : AppMode.volunteer;

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

                            // Nút chuyển chế độ: CHỈ HIỂN THỊ KHI LÀ ADMIN (Admin truy cập được cả 2)
                            if (isAdmin) ...[
                              const SizedBox(width: 20),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () => setState(() => _currentMode = AppMode.volunteer),
                                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(7)),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: effectiveMode == AppMode.volunteer ? AppTheme.primaryGreen : Colors.transparent,
                                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(7)),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.phone_android, size: 14, color: Colors.white),
                                            SizedBox(width: 6),
                                            Text(
                                              'Mobile App Sinh Viên',
                                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => setState(() => _currentMode = AppMode.admin),
                                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(7)),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: effectiveMode == AppMode.admin ? AppTheme.primaryGreen : Colors.transparent,
                                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(7)),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.admin_panel_settings, size: 14, color: Colors.white),
                                            SizedBox(width: 6),
                                            Text(
                                              'Web Admin Ban Chỉ Huy',
                                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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

          // Nội dung chính: User thông thường KHÔNG BAO GIỜ truy cập được AdminMainScreen
          Expanded(
            child: (isAdmin && effectiveMode == AppMode.admin)
                ? AdminMainScreen(
                    onSwitchToStudentApp: () => setState(() => _currentMode = AppMode.volunteer),
                  )
                : const VolunteerMainScreen(),
          ),
        ],
      ),
    );
  }
}

