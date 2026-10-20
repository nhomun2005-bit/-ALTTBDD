import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class SampleProofImageItem {
  final String title;
  final String category;
  final String location;
  final List<Color> gradientColors;
  final IconData icon;

  const SampleProofImageItem({
    required this.title,
    required this.category,
    required this.location,
    required this.gradientColors,
    required this.icon,
  });

  Future<Uint8List> generateBytes() async {
    const double width = 800;
    const double height = 500;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, width, height));

    // 1. Nền Gradient sinh động
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(width, height),
        gradientColors,
      );
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), bgPaint);

    // 2. Các dải trang trí hiện trường / thực địa
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    for (int i = -2; i < 8; i++) {
      canvas.drawLine(
        Offset(i * 120.0, 0),
        Offset(i * 120.0 + 300, height),
        linePaint,
      );
    }

    // 3. Khung bo viền chứng nhận hiện trường
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(16, 16, width - 32, height - 32),
        const Radius.circular(16),
      ),
      borderPaint,
    );

    // 4. Băng rôn tiêu đề
    final bannerPaint = Paint()..color = Colors.black.withValues(alpha: 0.45);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(30, 30, width - 60, 90),
        const Radius.circular(12),
      ),
      bannerPaint,
    );

    // Header Text
    final tpHeader = TextPainter(
      text: const TextSpan(
        text: 'CHIẾN DỊCH TÌNH NGUYỆN MÙA HÈ XANH 2026\nẢNH CHỨNG NHẬN HIỆN TRƯỜNG CÔNG TÁC',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          height: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: width - 80);
    tpHeader.paint(canvas, Offset((width - tpHeader.width) / 2, 45));

    // 5. Thẻ nội dung trọng tâm giữa ảnh
    final cardPaint = Paint()..color = Colors.white.withValues(alpha: 0.92);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(60, 150, width - 120, 200),
        const Radius.circular(16),
      ),
      cardPaint,
    );

    // Biểu tượng tròn
    final circlePaint = Paint()..color = gradientColors.first;
    canvas.drawCircle(const Offset(120, 250), 45, circlePaint);

    final tpIcon = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 42,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpIcon.paint(canvas, Offset(120 - tpIcon.width / 2, 250 - tpIcon.height / 2));

    // Tiêu đề công việc
    final tpTitle = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: Color(0xFF1B5E20),
          fontSize: 22,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width - 260);
    tpTitle.paint(canvas, const Offset(190, 180));

    // Địa bàn & Hạng mục
    final tpDesc = TextPainter(
      text: TextSpan(
        text: 'Chuyên mục: $category\nĐịa bàn công tác: $location\nTình trạng: Đã thi công nghiệm thu tại chỗ',
        style: const TextStyle(
          color: Color(0xFF37474F),
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width - 260);
    tpDesc.paint(canvas, const Offset(190, 240));

    // 6. Watermark GPS & Thời gian thực địa ở đáy ảnh
    final watermarkBg = Paint()..color = Colors.black.withValues(alpha: 0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(30, height - 90, width - 60, 56),
        const Radius.circular(10),
      ),
      watermarkBg,
    );

    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final tpWatermark = TextPainter(
      text: TextSpan(
        text: 'MINH CHỨNG SỐ HÓA: GPS 10.7769°N, 106.7009°E | $dateStr\nXÁC THỰC BỞI BAN CHỈ HUY MẶT TRẬN TÌNH NGUYỆN',
        style: const TextStyle(
          color: Color(0xFFFFD54F),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          height: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: width - 80);
    tpWatermark.paint(canvas, Offset((width - tpWatermark.width) / 2, height - 80));

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}

final List<SampleProofImageItem> kSampleProofImages = [
  const SampleProofImageItem(
    title: 'Hoàn thành đổ bê tông 200m đường nông thôn',
    category: 'Xây dựng & Môi trường nông thôn',
    location: 'Ấp 3, Xã Bình Chánh, Huyện Bình Chánh',
    gradientColors: [Color(0xFF2E7D32), Color(0xFF1565C0)],
    icon: Icons.engineering,
  ),
  const SampleProofImageItem(
    title: 'Hướng dẫn kích hoạt VNeID mức 2 cho 45 hộ dân',
    category: 'Chuyển đổi số cộng đồng',
    location: 'UBND Xã Tân Kiên, Huyện Bình Chánh',
    gradientColors: [Color(0xFF0277BD), Color(0xFF00897B)],
    icon: Icons.fingerprint,
  ),
  const SampleProofImageItem(
    title: 'Tổ chức lớp học hè & ôn tập văn hóa cho 30 em thiếu nhi',
    category: 'Đền ơn đáp nghĩa & Vì đàn em thân yêu',
    location: 'Nhà văn hóa Xã An Phú Tây',
    gradientColors: [Color(0xFFF57C00), Color(0xFFD81B60)],
    icon: Icons.school,
  ),
  const SampleProofImageItem(
    title: 'Dọn dẹp khai thông 1.2km dòng chảy kênh rạch',
    category: 'Bảo vệ môi trường & Xanh hóa dòng sông',
    location: 'Kênh rạch Liên Ấp 2-3',
    gradientColors: [Color(0xFF00695C), Color(0xFF2E7D32)],
    icon: Icons.cleaning_services,
  ),
  const SampleProofImageItem(
    title: 'Thăm hỏi, sửa nhà và tặng quà cho Mẹ Việt Nam Anh Hùng',
    category: 'Công tác an sinh xã hội',
    location: 'Huyện Cần Giờ, TP. Hồ Chí Minh',
    gradientColors: [Color(0xFFC2185B), Color(0xFF7B1FA2)],
    icon: Icons.favorite,
  ),
];
