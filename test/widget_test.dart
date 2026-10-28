import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:duanmuahexanh/main.dart';
import 'package:duanmuahexanh/services/data_service.dart';

void main() {
  testWidgets('Mua He Xanh App smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dataService = DataService();
    dataService.logout();

    await tester.pumpWidget(const MuaHeXanhApp());
    await tester.pumpAndSettle();

    // Khi chưa đăng nhập -> hiển thị AuthScreen
    expect(find.text('MÙA HÈ XANH'), findsWidgets);
    expect(find.text('Cổng Thông Tin Tình Nguyện & Quản Lý Chiến Dịch'), findsOneWidget);

    // Đăng nhập tài khoản demo vai trò Sinh viên
    dataService.loginUser(username: 'annguyen', password: 'password123');
    await tester.pumpAndSettle();

    // Sau khi đăng nhập vai trò sinh viên:
    expect(find.text('CHIẾN DỊCH MÙA HÈ XANH'), findsOneWidget);
    expect(find.text('Sinh viên'), findsWidgets);
    expect(find.text('Đổi Tài Khoản'), findsOneWidget);
    expect(find.text('Đăng xuất'), findsOneWidget);
    expect(find.text('CỔNG SINH VIÊN TÌNH NGUYỆN (/student)'), findsOneWidget);

    // Kiểm thử tài khoản Sinh viên truy cập /admin -> Bị từ chối truy cập 403
    dataService.loginUser(username: 'annguyen', password: 'password123');
    await tester.pumpWidget(
      const MaterialApp(
        home: MainContainerScreen(key: ValueKey('test_student_access_admin'), initialMode: AppMode.admin),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('403 - KHÔNG CÓ QUYỀN TRUY CẬP'), findsOneWidget);
    expect(find.text('TỪ CHỐI TRUY CẬP (/admin)'), findsOneWidget);
    expect(find.text('Chuyển Về Cổng Sinh Viên (/student)'), findsOneWidget);

    // Bấm nút chuyển về cổng sinh viên
    await tester.tap(find.text('Chuyển Về Cổng Sinh Viên (/student)'));
    await tester.pumpAndSettle();
    expect(find.text('Hoạt động'), findsWidgets);

    // Chuyển sang tài khoản Admin và kiểm thử giao diện Admin qua Route /admin
    dataService.loginUser(username: 'admin', password: 'admin123');
    await tester.pumpWidget(
      const MaterialApp(
        home: MainContainerScreen(key: ValueKey('test_admin_portal'), initialMode: AppMode.admin),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ban Chỉ Huy'), findsWidgets);
    expect(find.text('CỔNG QUẢN TRỊ BAN CHỈ HUY (/admin)'), findsOneWidget);
    expect(find.text('Bảng Tổng Quan'), findsWidgets);
  });
}
