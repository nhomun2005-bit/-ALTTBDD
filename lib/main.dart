import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/volunteer/volunteer_main_screen.dart';
import 'screens/admin/admin_main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  AppMode _currentMode = AppMode.volunteer;
  bool _simulatePhoneFrame = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Thanh điều khiển nhanh trên cùng (Dành cho việc trải nghiệm và kiểm thử cả App & Web)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B), // Dark slate
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
              children: [
                // Logo & Tên dự án
                const Icon(Icons.volunteer_activism, color: Colors.greenAccent, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'CHIẾN DỊCH MÙA HÈ XANH',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 16),

                // Nút chuyển chế độ: App Sinh Viên vs Web Admin
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => setState(() => _currentMode = AppMode.volunteer),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _currentMode == AppMode.volunteer ? AppTheme.primaryGreen : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _currentMode == AppMode.admin ? AppTheme.primaryGreen : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
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
                const SizedBox(width: 24),

                // Toggle mô phỏng khung điện thoại (khi xem App trên màn hình Web)
                if (_currentMode == AppMode.volunteer) ...[
                  InkWell(
                    onTap: () => setState(() => _simulatePhoneFrame = !_simulatePhoneFrame),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _simulatePhoneFrame ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _simulatePhoneFrame ? Icons.stay_current_portrait : Icons.fullscreen,
                            color: Colors.white70,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _simulatePhoneFrame ? 'Khung Điện Thoại' : 'Mở Rộng',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Huy hiệu tối ưu mạng 3G
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.bolt, size: 14, color: Colors.greenAccent),
                      SizedBox(width: 4),
                      Text(
                        '3G Siêu Tốc (Offline-First)',
                        style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

          // Nội dung chính: Sinh viên hoặc Web Admin
          Expanded(
            child: _currentMode == AppMode.admin
                ? AdminMainScreen(
                    onSwitchToStudentApp: () => setState(() => _currentMode = AppMode.volunteer),
                  )
                : (_simulatePhoneFrame
                    ? Center(
                        child: Container(
                          width: 410,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            border: Border.all(color: Colors.grey.shade800, width: 6),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: const VolunteerMainScreen(),
                          ),
                        ),
                      )
                    : const VolunteerMainScreen()),
          ),
        ],
      ),
    );
  }
}
