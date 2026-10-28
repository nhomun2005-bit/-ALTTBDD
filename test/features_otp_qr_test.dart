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
  });
}
