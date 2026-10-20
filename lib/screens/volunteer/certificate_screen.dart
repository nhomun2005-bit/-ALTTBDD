import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/registration.dart';
import '../../models/volunteer.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/file_helper.dart';

class CertificateScreen extends StatelessWidget {
  final Registration? registration;

  const CertificateScreen({super.key, this.registration});

  Future<Uint8List> _generateCertificatePdfBytes(Volunteer volunteer, String campaignName, String teamName) async {
    final pdf = pw.Document();

    pw.Font fontRegular = pw.Font.helvetica();
    pw.Font fontBold = pw.Font.helveticaBold();
    pw.Font fontItalic = pw.Font.helveticaOblique();
    pw.Font fontBoldItalic = pw.Font.helveticaBoldOblique();
    try {
      fontRegular = await PdfGoogleFonts.robotoRegular();
      fontBold = await PdfGoogleFonts.robotoBold();
      fontItalic = await PdfGoogleFonts.robotoItalic();
      fontBoldItalic = await PdfGoogleFonts.robotoBoldItalic();
    } catch (_) {}

    final now = DateTime.now();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
          italic: fontItalic,
          boldItalic: fontBoldItalic,
        ),
        build: (pw.Context ctx) => pw.Container(
          padding: const pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.amber700, width: 4),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
          ),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // Tiêu đề đoàn thể
              pw.Column(
                children: [
                  pw.Text(
                    'ĐOÀN TNCS HỒ CHÍ MINH - HỘI SINH VIÊN VIỆT NAM',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.grey700),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'BAN CHỈ HUY CHIẾN DỊCH TÌNH NGUYỆN MÙA HÈ XANH NĂM ${now.year}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: PdfColors.blue800),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Container(height: 2, width: 140, color: PdfColors.amber700),
                  pw.SizedBox(height: 14),
                  pw.Text(
                    'GIẤY CHỨNG NHẬN',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 24, color: PdfColors.green800),
                  ),
                  pw.Text(
                    'THANH NIÊN TÌNH NGUYỆN MÙA HÈ XANH',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.amber800),
                  ),
                ],
              ),

              // Nội dung khen thưởng
              pw.Column(
                children: [
                  pw.Text('BAN CHỈ HUY CHIẾN DỊCH CHỨNG NHẬN ĐỒNG CHÍ:', style: const pw.TextStyle(fontSize: 11)),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    volunteer.fullName.toUpperCase(),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20, color: PdfColors.green900),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'MSSV: ${volunteer.studentId}  |  Khoa: ${volunteer.faculty}',
                    style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Đã tích cực tham gia và hoàn thành xuất sắc nhiệm vụ tại chiến dịch:',
                    style: const pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '"$campaignName"',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: PdfColors.blue900),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text('Phân công tại: $teamName', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                ],
              ),

              // Footer chữ ký
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Số hiệu chứng nhận: MHX-${now.year}-${volunteer.studentId}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                      pw.Text('Hệ thống Quản lý Tình nguyện Mùa Hè Xanh', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                      pw.Text('Tra cứu mã số: https://muahexanh.edu.vn/verify', style: const pw.TextStyle(fontSize: 8, color: PdfColors.blue700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('TP. Hồ Chí Minh, ngày ${now.day} tháng ${now.month} năm ${now.year}', style: const pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic)),
                      pw.SizedBox(height: 2),
                      pw.Text('TM. BAN CHỈ HUY CHIẾN DỊCH', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text('CHỈ HUY TRƯỞNG', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.SizedBox(height: 22),
                      pw.Text('(Đã ký số điện tử & đóng dấu số)', style: const pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic, color: PdfColors.red800)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return pdf.save();
  }

  Future<void> _exportCertificatePdf(BuildContext context, Volunteer volunteer, String campaignName, String teamName) async {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Đang tạo Giấy chứng nhận PDF chính thức...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final now = DateTime.now();
      final pdfBytes = await _generateCertificatePdfBytes(volunteer, campaignName, teamName);
      final fileName = 'Giay_Chung_Nhan_MHX_${volunteer.studentId}_${now.year}.pdf';
      final savedPath = await saveAndDownloadFile(pdfBytes, fileName);

      scaffold.showSnackBar(
        SnackBar(
          content: Text(savedPath != null && savedPath.contains('\\')
              ? 'Đã tải Giấy chứng nhận về máy: $savedPath'
              : 'Đã tải thành công Giấy chứng nhận ($fileName) về máy!'),
          backgroundColor: AppTheme.primaryGreen,
          action: SnackBarAction(
            label: savedPath != null && savedPath.contains('\\') ? 'Mở File' : 'In / Xem',
            textColor: Colors.white,
            onPressed: () {
              if (savedPath != null && savedPath.contains('\\')) {
                openSavedFile(savedPath);
              } else {
                Printing.layoutPdf(
                  onLayout: (format) async => pdfBytes,
                  name: fileName,
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text('Lỗi khi xuất Giấy chứng nhận: $e'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataService = DataService();
    final volunteer = dataService.currentVolunteer;
    final now = DateTime.now();

    final campaignName = registration?.campaignTitle ?? 'Chiến dịch Tình nguyện Mùa Hè Xanh 2026';
    final teamName = registration?.assignedTeam ?? volunteer.teamName ?? 'Đội hình xung kích';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chứng Nhận Điện Tử Mùa Hè Xanh'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Tải giấy chứng nhận PDF về máy',
            onPressed: () => _exportCertificatePdf(context, volunteer, campaignName, teamName),
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'In / Xem trước',
            onPressed: () async {
              final bytes = await _generateCertificatePdfBytes(volunteer, campaignName, teamName);
              Printing.layoutPdf(
                onLayout: (format) async => bytes,
                name: 'Giay_Chung_Nhan_MHX_${volunteer.studentId}.pdf',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Khung Giấy chứng nhận trang trọng
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentGold, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Tiêu đề đoàn hội
                  const Text(
                    'ĐOÀN TNCS HỒ CHÍ MINH - HỘI SINH VIÊN VIỆT NAM',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: AppTheme.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'BAN CHỈ HUY CHIẾN DỊCH TÌNH NGUYỆN MÙA HÈ XANH',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.youthBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Huy hiệu Mùa Hè Xanh
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryGreenLight,
                      border: Border.all(color: AppTheme.primaryGreen, width: 2),
                    ),
                    child: const Icon(
                      Icons.military_tech,
                      color: AppTheme.primaryGreen,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'GIẤY CHỨNG NHẬN',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreenDark,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Text(
                    'THANH NIÊN TÌNH NGUYỆN MÙA HÈ XANH',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentGold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'BAN CHỈ HUY CHIẾN DỊCH CHỨNG NHẬN ĐỒNG CHÍ:',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    volunteer.fullName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'MSSV: ${volunteer.studentId}  |  ${volunteer.faculty}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Đã tích cực tham gia và hoàn thành xuất sắc nhiệm vụ trong hoạt động:\n"$campaignName"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppTheme.textDark,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreenLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Phân công: $teamName',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryGreenDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mã số xác thực & chữ ký
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Số hiệu: MHX-${now.year}-${volunteer.studentId}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textMuted,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Tra cứu chứng nhận điện tử tại:\nmuahexanh.edu.vn/verify',
                            style: TextStyle(fontSize: 9, color: AppTheme.youthBlue),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Ngày ${DateFormat('dd/MM/yyyy').format(now)}',
                            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'TM. BAN CHỈ HUY CHIẾN DỊCH\nCHỈ HUY TRƯỞNG',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '(Đã ký điện tử & đóng dấu số)',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppTheme.dangerRed,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nút hành động nhanh
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _exportCertificatePdf(context, volunteer, campaignName, teamName),
                    icon: const Icon(Icons.file_download_outlined),
                    label: const Text('Xuất PDF Về Máy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final bytes = await _generateCertificatePdfBytes(volunteer, campaignName, teamName);
                      Printing.layoutPdf(
                        onLayout: (format) async => bytes,
                        name: 'Giay_Chung_Nhan_MHX_${volunteer.studentId}.pdf',
                      );
                    },
                    icon: const Icon(Icons.print_outlined),
                    label: const Text('In / Xem Bản In'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
