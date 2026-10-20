import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import 'activity_detail_screen.dart';
import 'registration_dialog.dart';

class ActivityListScreen extends StatefulWidget {
  const ActivityListScreen({super.key});

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  final DataService _dataService = DataService();
  String _selectedCategory = 'Tất cả';
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _dataService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    // Lọc danh sách chiến dịch
    final filtered = _dataService.campaigns.where((c) {
      final matchCategory = _selectedCategory == 'Tất cả' || c.category == _selectedCategory;
      final matchSearch = _searchKeyword.isEmpty ||
          c.title.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
          c.location.toLowerCase().contains(_searchKeyword.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();

    final categories = ['Tất cả', 'Xây dựng công trình', 'Chuyển đổi số', 'Dạy học hè', 'Y tế vì cộng đồng'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chiến Dịch Mùa Hè Xanh 2026'),
      ),
      body: Column(
        children: [
          // Banner thông tin tối ưu mạng 3G
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppTheme.primaryGreenLight,
            child: const Row(
              children: [
                Icon(Icons.bolt, color: AppTheme.primaryGreenDark, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Chế độ tiết kiệm 3G: Tải siêu tốc & Không tốn lưu lượng',
                    style: TextStyle(
                      color: AppTheme.primaryGreenDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm hoạt động, địa bàn xã/huyện...',
                prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.textMuted),
                suffixIcon: _searchKeyword.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _searchKeyword = ''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (val) => setState(() => _searchKeyword = val),
            ),
          ),

          // Thanh chọn danh mục ngang
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textDark,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryGreen,
                  backgroundColor: Colors.white,
                  showCheckmark: false,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = cat);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Danh sách hoạt động
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.volunteer_activism_outlined, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text('Không tìm thấy hoạt động phù hợp', style: TextStyle(color: AppTheme.textMuted)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final isRegistered = _dataService.registrations.any(
                        (r) => r.campaignId == item.id && r.volunteerId == _dataService.currentVolunteer.id,
                      );

                      return Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ActivityDetailScreen(campaign: item),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryGreenLight,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item.category,
                                        style: const TextStyle(
                                          color: AppTheme.primaryGreenDark,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (isRegistered)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.blue.shade200),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.check, size: 12, color: AppTheme.youthBlue),
                                            SizedBox(width: 4),
                                            Text(
                                              'Đã đăng ký',
                                              style: TextStyle(
                                                color: AppTheme.youthBlue,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.red),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        item.location,
                                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_month_outlined, size: 14, color: AppTheme.youthBlue),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${dateFormat.format(item.startDate)} - ${dateFormat.format(item.endDate)}',
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                    ),
                                  ],
                                ),
                                const Divider(height: 18),
                                Row(
                                  children: [
                                    _buildSmallBadge(
                                      Icons.group_outlined,
                                      'Tuyển: ${item.currentRegistered}/${item.targetVolunteers}',
                                      Colors.grey.shade700,
                                    ),
                                    const SizedBox(width: 12),
                                    _buildSmallBadge(
                                      Icons.timer_outlined,
                                      '${item.volunteerHours} giờ TN',
                                      AppTheme.youthBlue,
                                    ),
                                    const SizedBox(width: 12),
                                    _buildSmallBadge(
                                      Icons.stars_outlined,
                                      '+${item.trainingPoints} ĐRL',
                                      AppTheme.accentOrange,
                                    ),
                                    const Spacer(),
                                    if (!isRegistered && item.status != 'Đã hoàn thành')
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primaryGreen,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          minimumSize: const Size(0, 28),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        onPressed: () {
                                          RegistrationDialog.show(
                                            context,
                                            campaign: item,
                                            onSuccess: () {
                                              if (mounted) setState(() {});
                                            },
                                          );
                                        },
                                        child: const Text('Đăng ký', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      )
                                    else
                                      const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBadge(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}
