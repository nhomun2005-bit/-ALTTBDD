import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/budget_logistics.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';

class AdminBudgetLogisticsScreen extends StatefulWidget {
  const AdminBudgetLogisticsScreen({super.key});

  @override
  State<AdminBudgetLogisticsScreen> createState() => _AdminBudgetLogisticsScreenState();
}

class _AdminBudgetLogisticsScreenState extends State<AdminBudgetLogisticsScreen> {
  final DataService _dataService = DataService();
  String? _selectedCampaignId;

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onUpdate);
    if (_dataService.campaigns.isNotEmpty) {
      _selectedCampaignId = _dataService.campaigns.first.id;
    }
  }

  @override
  void dispose() {
    _dataService.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  void _showEditBudgetDialog(ActivityBudgetLogistics data) {
    final estCtrl = TextEditingController(text: '${data.estimatedBudget.toInt()}');
    final actCtrl = TextEditingController(text: '${data.actualCost.toInt()}');
    final noteCtrl = TextEditingController(text: data.generalNotes);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.monetization_on_outlined, color: AppTheme.primaryGreen),
              SizedBox(width: 8),
              Text('Cập Nhật Kinh Phí Hoạt Động', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hoạt động: ${data.campaignTitle}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const Divider(height: 16),
              TextField(
                controller: estCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Ngân sách dự kiến (VNĐ) *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: actCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Chi phí thực tế hoạt động (VNĐ) *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Ghi chú nguồn thu - chi / tài trợ'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                final est = double.tryParse(estCtrl.text) ?? data.estimatedBudget;
                final act = double.tryParse(actCtrl.text) ?? data.actualCost;

                final updated = data.copyWith(
                  estimatedBudget: est,
                  actualCost: act,
                  generalNotes: noteCtrl.text.trim(),
                  lastUpdated: DateTime.now(),
                );
                _dataService.updateBudgetLogistics(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã cập nhật kinh phí hoạt động tình nguyện thành công!'),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              },
              child: const Text('Lưu Thay Đổi'),
            ),
          ],
        );
      },
    );
  }

  void _showAddLogisticsItemDialog(ActivityBudgetLogistics data) {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '10');
    final unitCtrl = TextEditingController(text: 'Cái');
    final noteCtrl = TextEditingController(text: 'Đã sẵn sàng bàn giao cho đội');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.inventory_2_outlined, color: AppTheme.primaryGreen),
              SizedBox(width: 8),
              Text('Thêm Vật Tư Hậu Cần Biểu Mẫu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tên vật tư theo biểu mẫu *',
                  hintText: 'VD: Nón tai bèo, Áo thun, Cuốc xẻng, Túi thuốc...',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Số lượng *'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: unitCtrl,
                      decoration: const InputDecoration(labelText: 'Đơn vị tính (Cái, Bộ, Hộp...)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: 'Tình trạng / Ghi chú kiểm đếm'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                final newItem = LogisticsItem(
                  itemName: nameCtrl.text.trim(),
                  quantity: int.tryParse(qtyCtrl.text) ?? 1,
                  unit: unitCtrl.text.trim().isEmpty ? 'Cái' : unitCtrl.text.trim(),
                  note: noteCtrl.text.trim(),
                );

                final updatedItems = List<LogisticsItem>.from(data.logisticsItems)..add(newItem);
                final updated = data.copyWith(
                  logisticsItems: updatedItems,
                  lastUpdated: DateTime.now(),
                );
                _dataService.updateBudgetLogistics(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã thêm vật tư hậu cần vào biểu mẫu theo dõi!'),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              },
              child: const Text('Thêm Vào Biểu Mẫu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final campaigns = _dataService.campaigns;
    if (_selectedCampaignId == null && campaigns.isNotEmpty) {
      _selectedCampaignId = campaigns.first.id;
    }

    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    final data = _dataService.budgetLogisticsMap[_selectedCampaignId] ??
        ActivityBudgetLogistics(
          id: 'bl_default',
          campaignId: _selectedCampaignId ?? '',
          campaignTitle: 'Hoạt động Mùa Hè Xanh',
          estimatedBudget: 0,
          actualCost: 0,
          logisticsItems: [],
          lastUpdated: DateTime.now(),
        );

    final remaining = data.estimatedBudget - data.actualCost;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Select Campaign
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ngân Sách & Hậu Cần Cơ Bản Theo Hoạt Động',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  Text(
                    'Theo dõi kinh phí và vật tư theo biểu mẫu thống nhất của chiến dịch tình nguyện',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: DropdownButton<String>(
                  value: _selectedCampaignId,
                  underline: const SizedBox(),
                  items: campaigns.map((c) {
                    return DropdownMenuItem(
                      value: c.id,
                      child: Text(c.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCampaignId = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Quy định nghiệp vụ từ yêu cầu đề bài
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.accentOrange, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Quy định: Phần hậu cần được giới hạn ở thông tin cần theo dõi cho từng hoạt động theo biểu mẫu đã thống nhất (không quản lý kho độc lập). Chi phí ghi nhận trên hệ thống là chi phí của hoạt động tình nguyện, phân biệt với chi phí xây dựng và vận hành phần mềm.',
                    style: TextStyle(fontSize: 12, color: Colors.brown.shade800, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3 Thẻ Ngân Sách
          Row(
            children: [
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
                      const Text('Ngân sách dự kiến', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                        currencyFormat.format(data.estimatedBudget),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.youthBlue),
                      ),
                      const SizedBox(height: 4),
                      const Text('Dự toán được phê duyệt', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
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
                      const Text('Chi phí thực tế hoạt động', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                        currencyFormat.format(data.actualCost),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGreenDark),
                      ),
                      const SizedBox(height: 4),
                      const Text('Đã quyết toán chứng từ', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
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
                      const Text('Chênh lệch / Tiết kiệm', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                        currencyFormat.format(remaining),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: remaining >= 0 ? AppTheme.accentOrange : AppTheme.dangerRed,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cập nhật: ${dateFormat.format(data.lastUpdated)}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Danh sách vật tư hậu cần theo biểu mẫu
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(Icons.checklist_rounded, color: AppTheme.primaryGreen, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Danh Mục Vật Tư Hậu Cần Theo Biểu Mẫu Thống Nhất',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: () => _showEditBudgetDialog(data),
                          icon: const Icon(Icons.edit, size: 14),
                          label: const Text('Sửa ngân sách', style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showAddLogisticsItemDialog(data),
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text('Thêm vật tư', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: data.logisticsItems.isEmpty
                        ? const Center(child: Text('Chưa có danh mục vật tư nào trong biểu mẫu'))
                        : ListView.separated(
                            itemCount: data.logisticsItems.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = data.logisticsItems[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.youthBlueLight,
                                  child: Icon(
                                    item.itemName.contains('Áo')
                                        ? Icons.checkroom
                                        : (item.itemName.contains('Nón')
                                            ? Icons.face
                                            : (item.itemName.contains('thuốc') || item.itemName.contains('y tế')
                                                ? Icons.medical_services
                                                : Icons.handyman)),
                                    color: AppTheme.youthBlue,
                                    size: 18,
                                  ),
                                ),
                                title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                subtitle: Text('Trạng thái: ${item.note}', style: const TextStyle(fontSize: 12)),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreenLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${item.quantity} ${item.unit}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreenDark, fontSize: 13),
                                  ),
                                ),
                              );
                            },
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
}
