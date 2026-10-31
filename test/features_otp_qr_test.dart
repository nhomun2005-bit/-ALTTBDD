import 'package:flutter_test/flutter_test.dart';
import 'package:duanmuahexanh/services/data_service.dart';

void main() {
  group('Kiểm thử Chức năng Khôi phục Mật khẩu qua Email OTP', () {
    final dataService = DataService();

    test('Gửi mã OTP thất bại khi email không tồn tại hoặc không hợp lệ', () async {
      final invalidRes = await dataService.sendPasswordResetOtp('invalid_email');
      expect(invalidRes.success, isFalse);

      final notFoundRes = await dataService.sendPasswordResetOtp('nonexistent@gmail.com');
      expect(notFoundRes.success, isFalse);
    });

    test('Gửi mã OTP thành công cho tài khoản hợp lệ và đổi mật khẩu thành công', () async {
      // Tài khoản an.nguyen@sinhvien.edu.vn có trong danh sách mẫu
      final sendRes = await dataService.sendPasswordResetOtp('an.nguyen@sinhvien.edu.vn');
      expect(sendRes.success, isTrue);
      expect(sendRes.otp, isNotNull);
      expect(sendRes.otp!.length, 6);
      expect(sendRes.targetEmail, 'an.nguyen@sinhvien.edu.vn');

      // Thử xác thực với OTP sai
      final wrongOtpRes = await dataService.verifyOtpAndResetPassword(
        email: 'an.nguyen@sinhvien.edu.vn',
        otp: '000000',
        newPassword: 'newPassword123',
      );
      expect(wrongOtpRes.success, isFalse);

      // Xác thực với OTP đúng
      final correctRes = await dataService.verifyOtpAndResetPassword(
        email: 'an.nguyen@sinhvien.edu.vn',
        otp: sendRes.otp!,
        newPassword: 'newPassword123',
      );
      expect(correctRes.success, isTrue);

      // Kiểm tra mật khẩu đã được cập nhật
      final user = dataService.users.firstWhere((u) => u.email == 'an.nguyen@sinhvien.edu.vn');
      expect(user.password, 'newPassword123');
    });

    test('Tra cứu và gửi OTP đúng email theo tên tài khoản hoặc MSSV', () async {
      // 1. Nhập username 'annguyen' -> tự động gửi về 'an.nguyen@sinhvien.edu.vn'
      final resUser = await dataService.sendPasswordResetOtp('annguyen');
      expect(resUser.success, isTrue);
      expect(resUser.targetEmail, 'an.nguyen@sinhvien.edu.vn');
      expect(resUser.username, 'annguyen');
      expect(resUser.otp, isNotNull);

      // 2. Nhập MSSV '22120098' -> tự động gửi về 'an.nguyen@sinhvien.edu.vn'
      final resMssv = await dataService.sendPasswordResetOtp('22120098');
      expect(resMssv.success, isTrue);
      expect(resMssv.targetEmail, 'an.nguyen@sinhvien.edu.vn');

      // 3. Nhập tài khoản admin 'admin' -> gửi về 'bch.muahexanh@sinhvien.edu.vn'
      final resAdmin = await dataService.sendPasswordResetOtp('admin');
      expect(resAdmin.success, isTrue);
      expect(resAdmin.targetEmail, 'bch.muahexanh@sinhvien.edu.vn');
      expect(resAdmin.username, 'admin');

      // 4. Kiểm thử hàm gửi liên kết đặt lại mật khẩu qua email link
      final resLink = await dataService.sendPasswordResetEmailLink('annguyen');
      expect(resLink.success, isTrue);
      expect(resLink.targetEmail, 'an.nguyen@sinhvien.edu.vn');
      expect(resLink.username, 'annguyen');

      // Đổi mật khẩu qua tên tài khoản 'annguyen'
      final resetRes = await dataService.verifyOtpAndResetPassword(
        email: 'annguyen',
        otp: resMssv.otp!,
        newPassword: 'passwordMoi123',
      );
      expect(resetRes.success, isTrue);

      final user = dataService.users.firstWhere((u) => u.username == 'annguyen');
      expect(user.password, 'passwordMoi123');
    });
  });
}
