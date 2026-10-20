import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'file_helper.dart';
import 'sample_proof_images.dart';

Future<PickedImage?> showImagePickerDialog(BuildContext context) async {
  return showModalBottomSheet<PickedImage?>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.add_a_photo, color: AppTheme.primaryGreen, size: 24),
                  const SizedBox(width: 10),
                  const Text(
                    'Đính Kèm Ảnh Minh Chứng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Cách 1: Chọn từ máy tính / thiết bị
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppTheme.borderLight),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreenLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.folder_open, color: AppTheme.primaryGreenDark),
                ),
                title: const Text('Chọn ảnh từ máy tính / điện thoại', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Hỗ trợ JPG, PNG, WEBP từ thư mục máy tính', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                onTap: () async {
                  final picked = await pickImageFromDevice();
                  if (ctx.mounted && picked != null) {
                    Navigator.pop(ctx, picked);
                  }
                },
              ),
              const SizedBox(height: 14),

              // Tiêu đề chọn ảnh mẫu
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppTheme.accentOrange, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Hoặc chọn nhanh ảnh thực địa chuẩn Mùa Hè Xanh:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Danh sách ảnh thực địa mẫu
              SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: kSampleProofImages.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, idx) {
                    final sample = kSampleProofImages[idx];
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        // Hiển thị indicator đang xử lý
                        showDialog(
                          context: ctx,
                          barrierDismissible: false,
                          builder: (_) => const Center(
                            child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                          ),
                        );
                        final bytes = await sample.generateBytes();
                        if (ctx.mounted) {
                          Navigator.pop(ctx); // đóng loading
                          final name = 'minh_chung_thuc_dia_${idx + 1}.png';
                          Navigator.pop(ctx, PickedImage(bytes: bytes, name: name));
                        }
                      },
                      child: Container(
                        width: 170,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: sample.gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: sample.gradientColors.first.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(sample.icon, color: Colors.white, size: 20),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('Chuẩn', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              sample.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              sample.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  );
}
