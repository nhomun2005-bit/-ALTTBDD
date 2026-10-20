import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../../models/registration.dart';
import '../../utils/file_helper.dart';

class AdminExportScreen extends StatelessWidget {
  const AdminExportScreen({super.key});

  Future<Uint8List> _generatePdfBytes(DataService dataService) async {
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
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    final totalCampaigns = dataService.campaigns.length;
    final totalRegs = dataService.registrations.length;
    final approvedRegs = dataService.registrations.where((r) => r.status == RegistrationStatus.approved).length;
    final certifiedCount = dataService.registrations.where((r) => r.isCertified).length;

    double totalBudget = 0;
    double totalActualCost = 0;
    for (var b in dataService.budgetLogisticsMap.values) {
      totalBudget += b.estimatedBudget;
      totalActualCost += b.actualCost;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
          italic: fontItalic,
          boldItalic: fontBoldItalic,
        ),
        build: (pw.Context ctx) => [
          // Header
          pw.Center(
            child: pw.Text(
              'ĐOÀN TNCS HỒ CHÍ MINH - HỘI SINH VIÊN VIỆT NAM\nBAN CHỈ HUY CHIẾN DỊCH TÌNH NGUYỆN MÙA HÈ XANH',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Center(
            child: pw.Text(
              'BÁO CÁO TỔNG KẾT KẾT QUẢ TRIỂN KHAI\nCHIẾN DỊCH TÌNH NGUYỆN MÙA HÈ XANH NĂM ${now.year}',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: PdfColors.green800),
            ),
          ),
          pw.Divider(thickness: 1.5, color: PdfColors.grey400),
          pw.SizedBox(height: 10),

          // I. SỐ LIỆU TỔNG QUAN
          pw.Text('I. SỐ LIỆU TỔNG QUAN', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          pw.SizedBox(height: 6),
          pw.Bullet(text: '1. Tổng số chiến dịch / mặt trận triển khai: $totalCampaigns mặt trận.'),
          pw.Bullet(text: '2. Tổng số hồ sơ TNV đăng ký tham gia: $totalRegs sinh viên.'),
          pw.Bullet(text: '3. Số chiến sĩ tình nguyện chính thức được phê duyệt: $approvedRegs chiến sĩ.'),
          pw.Bullet(text: '4. Số chiến sĩ hoàn thành xuất sắc và cấp Giấy chứng nhận: $certifiedCount chiến sĩ.'),
          pw.SizedBox(height: 12),

          // II. KẾT QUẢ KINH PHÍ
          pw.Text('II. KẾT QUẢ KINH PHÍ HOẠT ĐỘNG TÌNH NGUYỆN', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          pw.SizedBox(height: 6),
          pw.Bullet(text: 'Tổng dự toán kinh phí phê duyệt: ${currencyFormat.format(totalBudget)}'),
          pw.Bullet(text: 'Chi phí thực tế đã quyết toán: ${currencyFormat.format(totalActualCost)}'),
          pw.Bullet(text: 'Tỷ lệ giải ngân: ${(totalBudget > 0 ? (totalActualCost / totalBudget * 100).toStringAsFixed(1) : "0")}%'),
          pw.SizedBox(height: 12),

          // III. BẢNG CHI TIẾT
          pw.Text('III. BẢNG THỐNG KÊ CHI TIẾT CÁC MẶT TRẬN', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          pw.SizedBox(height: 6),
          pw.Table.fromTextArray(
            headers: ['STT', 'Tên Chiến Dịch', 'Địa Bàn', 'Thời Gian', 'Tuyển', 'Kinh Phí'],
            data: dataService.campaigns.asMap().entries.map((entry) {
              final idx = entry.key;
              final camp = entry.value;
              final bl = dataService.budgetLogisticsMap[camp.id];
              final cost = bl != null ? currencyFormat.format(bl.actualCost) : '0 đ';
              return [
                '${idx + 1}',
                camp.title,
                camp.location,
                '${dateFormat.format(camp.startDate)} - ${dateFormat.format(camp.endDate)}',
                '${camp.currentRegistered}/${camp.targetVolunteers}',
                cost,
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green700),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          ),
          pw.SizedBox(height: 12),

          // IV. ĐÁNH GIÁ CHUNG
          pw.Text('IV. ĐÁNH GIÁ CHUNG CỦA BAN CHỈ HUY', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          pw.SizedBox(height: 6),
          pw.Text(
            'Các đội hình bám sát địa bàn, đảm bảo an toàn tuyệt đối cho chiến sĩ. Hệ thống phần mềm số hóa Mùa Hè Xanh vận hành thông suốt, thu nhận đầy đủ minh chứng hình ảnh thực địa và cấp phát giấy chứng nhận điện tử kịp thời.',
            style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.4),
          ),
          pw.SizedBox(height: 18),

          // Chữ ký
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('Ngày ${now.day} tháng ${now.month} năm ${now.year}', style: const pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic)),
                  pw.SizedBox(height: 4),
                  pw.Text('TM. BAN CHỈ HUY CHIẾN DỊCH', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text('CHỈ HUY TRƯỞNG', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.SizedBox(height: 20),
                  pw.Text('(Đã ký số điện tử & đóng dấu)', style: const pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  Future<void> _exportExcelCsv(BuildContext context, DataService dataService) async {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy');

    final buffer = StringBuffer();
    buffer.write('\uFEFF'); // UTF-8 BOM so Excel opens with full Vietnamese accents

    buffer.writeln('BÁO CÁO THỐNG KÊ CHI TIẾT MÙA HÈ XANH ${now.year}');
    buffer.writeln('Thời gian xuất:,${DateFormat('dd/MM/yyyy HH:mm').format(now)}');
    buffer.writeln('');
    buffer.writeln('STT,Tên Chiến Dịch,Địa Bàn,Ngày Bắt Đầu,Ngày Kết Thúc,Chỉ Tiêu,Đã Đăng Ký,Kinh Phí Dự Toán,Kinh Phí Thực Tế,Trạng Thái');

    final campaigns = dataService.campaigns;
    for (int i = 0; i < campaigns.length; i++) {
      final c = campaigns[i];
      final bl = dataService.budgetLogisticsMap[c.id];
      final est = bl != null ? bl.estimatedBudget.toStringAsFixed(0) : '0';
      final act = bl != null ? bl.actualCost.toStringAsFixed(0) : '0';

      buffer.writeln(
        '${i + 1},"${c.title}","${c.location}",${dateFormat.format(c.startDate)},${dateFormat.format(c.endDate)},${c.targetVolunteers},${c.currentRegistered},$est,$act,"${c.status}"',
      );
    }

    final bytes = Uint8List.fromList(utf8.encode(buffer.toString()));
    final fileName = 'Thong_Ke_Mua_He_Xanh_${now.year}.csv';
    final savedPath = await saveAndDownloadFile(bytes, fileName);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(savedPath != null && savedPath.contains('\\')
              ? 'Đã xuất file Excel về máy: $savedPath'
              : 'Đã xuất và tải thành công file Excel ($fileName) về máy tính!'),
          backgroundColor: AppTheme.primaryGreen,
          action: savedPath != null && savedPath.contains('\\')
              ? SnackBarAction(
                  label: 'Mở File',
                  textColor: Colors.white,
                  onPressed: () => openSavedFile(savedPath),
                )
              : null,
        ),
      );
    }
  }

  Future<void> _exportPdfDirect(BuildContext context, DataService dataService) async {
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
            Text('Đang tạo và lưu file PDF về máy tính...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final now = DateTime.now();
      final pdfBytes = await _generatePdfBytes(dataService);
      final fileName = 'Bao_Cao_Tong_Ket_Mua_He_Xanh_${now.year}.pdf';
      final savedPath = await saveAndDownloadFile(pdfBytes, fileName);

      scaffold.showSnackBar(
        SnackBar(
          content: Text(savedPath != null && savedPath.contains('\\')
              ? 'Đã lưu PDF vào máy: $savedPath'
              : 'Đã tải thành công $fileName về máy của bạn!'),
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
          content: Text('Lỗi khi xuất PDF: $e'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  void _showPdfPreviewDialog(BuildContext context, DataService dataService) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final now = DateTime.now();

    final totalCampaigns = dataService.campaigns.length;
    final totalRegs = dataService.registrations.length;
    final approvedRegs = dataService.registrations.where((r) => r.status == RegistrationStatus.approved).length;
    final certifiedCount = dataService.registrations.where((r) => r.isCertified).length;

    double totalBudget = 0;
    double totalActualCost = 0;
    for (var b in dataService.budgetLogisticsMap.values) {
      totalBudget += b.estimatedBudget;
      totalActualCost += b.actualCost;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.picture_as_pdf, color: AppTheme.dangerRed),
              SizedBox(width: 8),
              Text('Xem Trước Báo Cáo Tổng Hợp (PDF)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'ĐOÀN TNCS HỒ CHÍ MINH - HỘI SINH VIÊN VIỆT NAM\nBAN CHỈ HUY CHIẾN DỊCH MÙA HÈ XANH',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'BÁO CÁO TỔNG KẾT KẾT QUẢ TRIỂN KHAI\nCHIẾN DỊCH TÌNH NGUYỆN MÙA HÈ XANH NĂM ${now.year}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryGreenDark),
                      ),
                    ),
                    const Divider(height: 24),
                    const Text('I. SỐ LIỆU TỔNG QUAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text('1. Tổng số chiến dịch / hoạt động triển khai: $totalCampaigns mặt trận.'),
                    Text('2. Tổng số hồ sơ TNV đăng ký tham gia: $totalRegs sinh viên.'),
                    Text('3. Số chiến sĩ tình nguyện chính thức được phê duyệt: $approvedRegs chiến sĩ.'),
                    Text('4. Số chiến sĩ hoàn thành nhiệm vụ & cấp Giấy chứng nhận: $certifiedCount chiến sĩ.'),
                    const SizedBox(height: 12),
                    const Text('II. KẾT QUẢ KINH PHÍ HOẠT ĐỘNG TÌNH NGUYỆN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text('- Tổng dự toán phê duyệt: ${currencyFormat.format(totalBudget)}'),
                    Text('- Chi phí thực tế đã quyết toán: ${currencyFormat.format(totalActualCost)}'),
                    Text('- Tỷ lệ giải ngân: ${(totalBudget > 0 ? (totalActualCost / totalBudget * 100).toStringAsFixed(1) : "0")}%'),
                    const SizedBox(height: 12),
                    const Text('III. ĐÁNH GIÁ CHUNG CỦA BAN CHỈ HUY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    const Text(
                      'Các đội hình bám sát địa bàn, đảm bảo an toàn tuyệt đối cho chiến sĩ. Phần mềm quản lý vận hành mượt mà trên nền tảng mạng 3G, giúp thu thập báo cáo minh chứng và điểm danh kịp thời hàng ngày.',
                      style: TextStyle(fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          children: [
                            Text('Ngày ${now.day} tháng ${now.month} năm ${now.year}', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 11)),
                            const Text('TM. BAN CHỈ HUY CHIẾN DỊCH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const Text('CHỈ HUY TRƯỞNG\n(Đã ký điện tử)', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
            OutlinedButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                final pdfBytes = await _generatePdfBytes(dataService);
                Printing.layoutPdf(
                  onLayout: (format) async => pdfBytes,
                  name: 'Bao_Cao_Tong_Ket_Mua_He_Xanh_${now.year}.pdf',
                );
              },
              icon: const Icon(Icons.print, size: 16),
              label: const Text('In / Xem trước'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _exportPdfDirect(context, dataService);
              },
              icon: const Icon(Icons.download),
              label: const Text('Tải File PDF Về Máy'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataService = DataService();
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormat = DateFormat('dd/MM/yyyy');

    final totalCampaigns = dataService.campaigns.length;
    final totalRegs = dataService.registrations.length;
    final approvedRegs = dataService.registrations.where((r) => r.status == RegistrationStatus.approved).length;
    final certifiedCount = dataService.registrations.where((r) => r.isCertified).length;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng Hợp & Xuất Báo Cáo Chiến Dịch',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  Text(
                    'Xuất dữ liệu phục vụ báo cáo Đoàn trường, Tỉnh Đoàn và Hội Sinh Viên Việt Nam',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _exportExcelCsv(context, dataService),
                    icon: const Icon(Icons.table_view_outlined, color: AppTheme.primaryGreenDark),
                    label: const Text('Xuất Excel (.csv)'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _showPdfPreviewDialog(context, dataService),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Xuất Báo Cáo PDF'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tổng hợp số liệu dạng thẻ
          Row(
            children: [
              _buildMetricCard('Tổng Mặt Trận', '$totalCampaigns', 'Hoạt động đã mở', AppTheme.primaryGreen),
              const SizedBox(width: 12),
              _buildMetricCard('Hồ Sơ Đăng Ký', '$totalRegs', 'Chiến sĩ nộp đơn', AppTheme.youthBlue),
              const SizedBox(width: 12),
              _buildMetricCard('Đã Phê Duyệt', '$approvedRegs', 'Tham gia thực tế', AppTheme.accentOrange),
              const SizedBox(width: 12),
              _buildMetricCard('Chứng Nhận', '$certifiedCount', 'Đã cấp giấy CN', Colors.purple),
            ],
          ),
          const SizedBox(height: 16),

          // Bảng tóm tắt danh sách chiến dịch
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.summarize_outlined, color: AppTheme.primaryGreen, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Bảng Thống Kê Chi Tiết Từng Mặt Trận & Kinh Phí',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(AppTheme.primaryGreenLight),
                          columns: const [
                            DataColumn(label: Text('STT', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Tên Chiến Dịch', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Địa Bàn', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Thời Gian', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Chỉ Tiêu / Đã Tuyển', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Kinh Phí Thực Tế', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Trạng Thái', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: dataService.campaigns.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final camp = entry.value;
                            final bl = dataService.budgetLogisticsMap[camp.id];
                            final cost = bl != null ? currencyFormat.format(bl.actualCost) : '0 đ';

                            return DataRow(
                              cells: [
                                DataCell(Text('${idx + 1}')),
                                DataCell(Text(camp.title, style: const TextStyle(fontWeight: FontWeight.w600))),
                                DataCell(Text(camp.location)),
                                DataCell(Text('${dateFormat.format(camp.startDate)} - ${dateFormat.format(camp.endDate)}')),
                                DataCell(Text('${camp.currentRegistered}/${camp.targetVolunteers} TNV')),
                                DataCell(Text(cost, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreenDark))),
                                DataCell(Text(camp.status)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String val, String subtitle, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            const SizedBox(height: 4),
            Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}
