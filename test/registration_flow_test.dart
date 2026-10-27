import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:duanmuahexanh/models/campaign.dart';
import 'package:duanmuahexanh/models/registration.dart';
import 'package:duanmuahexanh/models/faculty.dart';
import 'package:duanmuahexanh/services/data_service.dart';
import 'package:duanmuahexanh/screens/volunteer/registration_dialog.dart';
import 'package:duanmuahexanh/screens/auth/auth_screen.dart';

void main() {
  group('Kiểm thử Quy trình Đăng ký Hoạt động Mùa Hè Xanh', () {
    late DataService dataService;

    setUp(() {
      dataService = DataService();
    });

    test('DataService registerForCampaign lưu thông tin sinh viên và tạo thông báo Admin', () {
      final initialRegCount = dataService.registrations.length;
      final initialNotifCount = dataService.adminNotifications.length;

      // Tìm một chiến dịch chưa đăng ký
      final testCampaign = Campaign(
        id: 'camp_test_001',
        title: 'Chiến dịch Test Xanh',
        category: 'Chuyển đổi số',
        location: 'Xã Bình Khánh, Cần Giờ',
        startDate: DateTime.now().add(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 10)),
        targetVolunteers: 20,
        currentRegistered: 5,
        description: 'Mô tả test',
        requirements: 'Yêu cầu test',
        volunteerHours: 30,
        trainingPoints: 10,
        status: 'Đang tuyển',
      );
      dataService.campaigns.add(testCampaign);

      final success = dataService.registerForCampaign(
        campaign: testCampaign,
        studentId: '22129999',
        volunteerName: 'Lê Văn Test',
        phone: '0988112233',
        faculty: 'Khoa Môi Trường',
      );

      expect(success, isTrue);
      expect(dataService.registrations.length, initialRegCount + 1);

      // Kiểm tra đơn đã được lưu trong mục đã đăng ký với đầy đủ thông tin
      final savedReg = dataService.registrations.firstWhere((r) => r.studentId == '22129999');
      expect(savedReg.volunteerName, 'Lê Văn Test');
      expect(savedReg.studentId, '22129999');
      expect(savedReg.phone, '0988112233');
      expect(savedReg.faculty, 'Khoa Môi Trường');
      expect(savedReg.campaignId, 'camp_test_001');
      expect(savedReg.status, RegistrationStatus.pending);

      // Kiểm tra Admin nhận được thông báo
      expect(dataService.adminNotifications.length, initialNotifCount + 1);
      final latestNotif = dataService.adminNotifications.first;
      expect(latestNotif.isRead, isFalse);
      expect(latestNotif.studentId, '22129999');
      expect(latestNotif.message, contains('Lê Văn Test'));
      expect(latestNotif.message, contains('22129999'));
      expect(latestNotif.message, contains('0988112233'));
      expect(latestNotif.message, contains('Khoa Môi Trường'));
      expect(latestNotif.message, contains('Chiến dịch Test Xanh'));

      // Đăng ký lại cùng chiến dịch phải bị chặn (không duplicate)
      final duplicateResult = dataService.registerForCampaign(
        campaign: testCampaign,
        studentId: '22129999',
        volunteerName: 'Lê Văn Test',
        phone: '0988112233',
        faculty: 'Khoa Môi Trường',
      );
      expect(duplicateResult, isFalse);
    });

    testWidgets('RegistrationDialog hiển thị form đủ MSSV, Tên, SĐT, Khoa và nút Xác nhận', (tester) async {
      final testCampaign = Campaign(
        id: 'camp_dialog_test',
        title: 'Hoạt Động Dạy Hè Yêu Thương',
        category: 'Dạy học hè',
        location: 'Trường Tiểu Học Phú Thạnh',
        startDate: DateTime.now().add(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 7)),
        targetVolunteers: 15,
        currentRegistered: 2,
        description: 'Dạy học cho học sinh',
        requirements: 'Nhiệt tình',
        volunteerHours: 25,
        trainingPoints: 10,
        status: 'Đang tuyển',
      );

      tester.view.physicalSize = const Size(1000, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => RegistrationDialog.show(context, campaign: testCampaign),
                child: const Text('Mở Form'),
              ),
            ),
          ),
        ),
      );

      // Mở dialog
      await tester.tap(find.text('Mở Form'));
      await tester.pumpAndSettle();

      // Kiểm tra form có đủ 4 trường
      expect(find.text('Đăng Ký Hoạt Động MHX'), findsOneWidget);
      expect(find.text('Mã số sinh viên (MSSV) *'), findsOneWidget);
      expect(find.text('Họ và tên sinh viên *'), findsOneWidget);
      expect(find.text('Số điện thoại liên lạc *'), findsOneWidget);
      expect(find.text('Khoa / Viện đào tạo *'), findsOneWidget);
      expect(find.text('Xác Nhận Đăng Ký'), findsOneWidget);
      expect(find.text('Hủy bỏ'), findsOneWidget);

      // Nhập thông tin sinh viên mới
      await tester.enterText(find.widgetWithText(TextFormField, 'Mã số sinh viên (MSSV) *'), '22123456');
      await tester.enterText(find.widgetWithText(TextFormField, 'Họ và tên sinh viên *'), 'Trần Quốc Bảo');
      await tester.enterText(find.widgetWithText(TextFormField, 'Số điện thoại liên lạc *'), '0918765432');
      await tester.enterText(find.widgetWithText(TextFormField, 'Khoa / Viện đào tạo *'), 'Khoa Xây Dựng');

      // Bấm nút Xác nhận
      await tester.ensureVisible(find.text('Xác Nhận Đăng Ký'));
      await tester.tap(find.text('Xác Nhận Đăng Ký'));
      await tester.pumpAndSettle();

      // Phải hiện dialog thông báo thành công
      expect(find.text('Đăng Ký Thành Công!'), findsOneWidget);
      expect(find.textContaining('Admin Ban Chỉ Huy đã nhận được thông báo xét duyệt'), findsOneWidget);

      // Bấm hoàn tất
      await tester.tap(find.text('Hoàn Tất'));
      await tester.pumpAndSettle();

      // Đơn đã lưu trong danh sách
      final reg = dataService.registrations.firstWhere((r) => r.studentId == '22123456');
      expect(reg.volunteerName, 'Trần Quốc Bảo');
      expect(reg.phone, '0918765432');
      expect(reg.faculty, 'Khoa Xây Dựng');
    });

    testWidgets('AuthScreen hiển thị form Đăng ký tài khoản an toàn không lỗi Dropdown khi có khoa trùng lặp', (WidgetTester tester) async {
      // Giả lập danh sách khoa có 2 khoa trùng tên nhau (nguyên nhân gây lỗi Dropdown)
      dataService.faculties.add(Faculty(
        id: 'fac_duplicate_test',
        code: 'CNTT_2',
        name: 'Khoa Công nghệ Thông tin & TT',
        description: 'Trùng tên kiểm thử',
        leaderName: 'Test',
        contactPhone: '0123456789',
        colorValue: 0xFF000000,
      ));

      await tester.pumpWidget(
        const MaterialApp(
          home: AuthScreen(initialIsRegister: true),
        ),
      );
      await tester.pumpAndSettle();

      // Kiểm tra các trường đăng ký tài khoản được hiển thị đầy đủ
      expect(find.text('ĐĂNG KÝ TÀI KHOẢN'), findsWidgets);
      expect(find.text('Họ và tên *'), findsOneWidget);
      expect(find.text('Số điện thoại *'), findsOneWidget);
      expect(find.text('Email sinh viên *'), findsOneWidget);
      expect(find.text('Khoa / Viện đào tạo *'), findsOneWidget);
      expect(find.text('Niên khóa *'), findsOneWidget);
      expect(find.text('Tên đăng nhập *'), findsOneWidget);
      expect(find.text('Mật khẩu (tối thiểu 6 ký tự) *'), findsOneWidget);
      expect(find.text('Xác nhận lại mật khẩu *'), findsOneWidget);
    });

    testWidgets('AuthScreen Đăng nhập hiển thị loading chuyển tiếp 2-3s trước khi vào trang chủ', (WidgetTester tester) async {
      bool loginSuccessCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AuthScreen(
            initialIsRegister: false,
            onSuccess: () => loginSuccessCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Nhập tài khoản admin
      await tester.enterText(find.widgetWithText(TextFormField, 'Nhập tên đăng nhập hoặc email'), 'admin');
      await tester.enterText(find.widgetWithText(TextFormField, 'Nhập mật khẩu'), 'admin123');

      // Bấm nút ĐĂNG NHẬP
      await tester.tap(find.widgetWithText(ElevatedButton, 'ĐĂNG NHẬP'));
      await tester.pump(); // frame đầu tiên

      // Kiểm tra giao diện Loading chuyển tiếp xuất hiện ngay
      expect(find.text('Đang Xác Thực Tài Khoản...'), findsOneWidget);
      expect(find.textContaining('Xin chào Ban Chỉ Huy Chiến Dịch!'), findsOneWidget);
      expect(loginSuccessCalled, isFalse);

      // Chờ thời gian chuyển tiếp 2s - 3s
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Sau 2-3s, đăng nhập thành công được kích hoạt
      expect(loginSuccessCalled, isTrue);
      expect(dataService.isLoggedIn, isTrue);
      expect(dataService.currentUser?.username, 'admin');
    });

    testWidgets('AuthScreen Đăng ký xong hiển thị loading 2-3s và yêu cầu đăng nhập lại', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AuthScreen(initialIsRegister: true),
        ),
      );
      await tester.pumpAndSettle();

      // Nhập thông tin đăng ký mới
      final uniqueUsername = 'testuser_${DateTime.now().millisecondsSinceEpoch}';
      await tester.enterText(find.widgetWithText(TextFormField, 'Ví dụ: Nguyễn Văn An'), 'Sinh Viên Mới');
      await tester.enterText(find.widgetWithText(TextFormField, '0987654321'), '0912345678');
      await tester.enterText(find.widgetWithText(TextFormField, 'sv@sinhvien.edu.vn'), '$uniqueUsername@sinhvien.edu.vn');
      await tester.enterText(find.widgetWithText(TextFormField, 'Ví dụ: nguyenvana22'), uniqueUsername);
      await tester.enterText(find.widgetWithText(TextFormField, 'Nhập mật khẩu'), '123456');
      await tester.enterText(find.widgetWithText(TextFormField, 'Nhập lại mật khẩu trên'), '123456');

      // Bấm ĐĂNG KÝ TÀI KHOẢN
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'ĐĂNG KÝ TÀI KHOẢN'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'ĐĂNG KÝ TÀI KHOẢN'));
      await tester.pump();

      // Kiểm tra màn hình loading xuất hiện
      expect(find.text('Đang Thiết Lập Tài Khoản...'), findsOneWidget);
      expect(find.textContaining('Tạo hồ sơ tình nguyện viên cho Sinh Viên Mới'), findsOneWidget);

      // Chờ thời gian chuyển tiếp 2s - 3s
      await tester.pump(const Duration(milliseconds: 850));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Đã chuyển về tab Đăng Nhập và yêu cầu đăng nhập lại
      expect(find.text('Đăng Nhập'), findsWidgets);
      expect(find.textContaining('Đăng ký tài khoản thành công! Vui lòng nhập mật khẩu để đăng nhập.'), findsOneWidget);
      expect(find.text(uniqueUsername), findsOneWidget); // Username được tự động điền
    });
  });
}

