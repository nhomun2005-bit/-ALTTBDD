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

    // Đăng nhập tài khoản demo
    dataService.loginUser(username: 'annguyen', password: 'password123');
    await tester.pumpAndSettle();

    // Sau khi đăng nhập với vai trò sinh viên:
    expect(find.text('CHIẾN DỊCH MÙA HÈ XANH'), findsOneWidget);
    expect(find.text('Sinh viên'), findsWidgets);
    expect(find.text('Đổi Tài Khoản'), findsOneWidget);
    expect(find.text('Đăng xuất'), findsOneWidget);
    // Sinh viên KHÔNG thấy nút và không thể truy cập trang Admin
    expect(find.text('Web Admin Ban Chỉ Huy'), findsNothing);

    // Chuyển sang tài khoản Admin
    dataService.loginUser(username: 'admin', password: 'admin123');
    await tester.pumpAndSettle();

    // Admin có thể truy cập cả 2
    expect(find.text('Ban Chỉ Huy'), findsWidgets);
    expect(find.text('Web Admin Ban Chỉ Huy'), findsOneWidget);
    expect(find.text('Mobile App Sinh Viên'), findsOneWidget);

    // Bấm chuyển sang trang Admin
    await tester.tap(find.text('Web Admin Ban Chỉ Huy'));
    await tester.pumpAndSettle();
    expect(find.text('Bảng Tổng Quan'), findsWidgets);

    // Bấm quay lại App Sinh Viên
    await tester.tap(find.text('Mobile App Sinh Viên'));
    await tester.pumpAndSettle();
    expect(find.text('Hoạt động'), findsWidgets);
  });
}
