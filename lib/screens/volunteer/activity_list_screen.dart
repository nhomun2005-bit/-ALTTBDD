import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/campaign.dart';
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

  String _searchKeyword = '';
  String _selectedCategory = 'Tất cả';
  String? _selectedFacultyId; // null = Tất cả khoa
  bool _onlyNearCampus = false; // Lọc hoạt động gần trường

  // Quản lý khung Lịch
  DateTime _calendarMonth = DateTime.now();
  DateTime? _selectedCalendarDate; // Ngày đang được chọn để lọc

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

  // Kiểm tra danh sách hoạt động diễn ra trong 1 ngày cụ thể
  List<Campaign> _getCampaignsOnDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return _dataService.campaigns.where((c) {
      final start = DateTime(c.startDate.year, c.startDate.month, c.startDate.day);
      final end = DateTime(c.endDate.year, c.endDate.month, c.endDate.day);
      return !targetDate.isBefore(start) && !targetDate.isAfter(end);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Lọc danh sách chiến dịch theo các tiêu chí: Khoa, Gần trường, Lịch, Danh mục, Từ khóa
    final filtered = _dataService.campaigns.where((c) {
      // 1. Lọc theo Khoa / Viện
      if (_selectedFacultyId != null && c.facultyId != _selectedFacultyId) {
        return false;
      }

      // 2. Lọc theo phạm vi gần trường (< 5km)
      if (_onlyNearCampus) {
        final isNear = c.isNearCampus || (c.distanceFromCampusKm != null && c.distanceFromCampusKm! <= 5.0);
        if (!isNear) return false;
      }

      // 3. Lọc theo ngày chọn trên Khung Lịch
      if (_selectedCalendarDate != null) {
        final selectedDay = DateTime(_selectedCalendarDate!.year, _selectedCalendarDate!.month, _selectedCalendarDate!.day);
        final start = DateTime(c.startDate.year, c.startDate.month, c.startDate.day);
        final end = DateTime(c.endDate.year, c.endDate.month, c.endDate.day);
        if (selectedDay.isBefore(start) || selectedDay.isAfter(end)) {
          return false;
        }
      }

      // 4. Lọc theo Mảng hoạt động
      if (_selectedCategory != 'Tất cả' && c.category != _selectedCategory) {
        return false;
      }

      // 5. Lọc theo từ khóa tìm kiếm
      if (_searchKeyword.isNotEmpty) {
        final q = _searchKeyword.toLowerCase();
        final match = c.title.toLowerCase().contains(q) ||
            c.location.toLowerCase().contains(q) ||
            (c.facultyName ?? '').toLowerCase().contains(q);
        if (!match) return false;
      }

      return true;
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: AppTheme.primaryGreenLight,
            child: const Row(
              children: [
                Icon(Icons.bolt, color: AppTheme.primaryGreenDark, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Chế độ tiết kiệm 3G: Tải siêu tốc & Không tốn lưu lượng',
                    style: TextStyle(
                      color: AppTheme.primaryGreenDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm hoạt động, khoa tổ chức, địa bàn...',
                prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.textMuted),
                suffixIcon: _searchKeyword.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _searchKeyword = ''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (val) => setState(() => _searchKeyword = val),
            ),
          ),

          // Phần nội dung cuộn chính chứa: Chọn Khoa, Khung Lịch, Bộ lọc gần trường, Danh sách hoạt động
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: [
                // 1. KHUNG CHỌN KHOA / VIỆN TRỰC THUỘC
                _buildFacultySelectorSection(),

                const SizedBox(height: 10),

                // 2. KHUNG LỊCH HOẠT ĐỘNG (THIẾT KẾ GỌN GÀNG THEO MẪU)
                _buildCalendarSection(),

                const SizedBox(height: 10),

                // 3. THANH LỌC NHANH: TẤT CẢ / GẦN TRƯỜNG / DANH MỤC
                _buildFilterChipsRow(categories),

                // Banner hiển thị thông tin nếu đang lọc GẦN TRƯỜNG
                if (_onlyNearCampus) ...[
                  const SizedBox(height: 8),
                  _buildNearCampusBanner(),
                ],

                // Banner thông báo nếu đang lọc theo một ngày cụ thể trên lịch
                if (_selectedCalendarDate != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event, color: AppTheme.youthBlue, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Đang xem hoạt động ngày: ${dateFormat.format(_selectedCalendarDate!)} (${filtered.length} hoạt động)',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.youthBlue),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _selectedCalendarDate = null),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Xem tất cả ngày', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // Tiêu đề số lượng kết quả
                Row(
                  children: [
                    Text(
                      'Danh Sách Hoạt Động (${filtered.length})',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const Spacer(),
                    if (_selectedFacultyId != null || _onlyNearCampus || _selectedCategory != 'Tất cả' || _selectedCalendarDate != null)
                      TextButton.icon(
                        icon: const Icon(Icons.refresh, size: 14),
                        label: const Text('Đặt lại bộ lọc', style: TextStyle(fontSize: 11)),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedFacultyId = null;
                            _onlyNearCampus = false;
                            _selectedCategory = 'Tất cả';
                            _selectedCalendarDate = null;
                            _searchKeyword = '';
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 6),

                // Danh sách thẻ hoạt động
                if (filtered.isEmpty)
                  _buildEmptyState()
                else
                  ...filtered.map((item) => _buildCampaignCard(item, dateFormat)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET 1: KHUNG CHỌN KHOA / VIỆN ---
  Widget _buildFacultySelectorSection() {
    final faculties = _dataService.faculties;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.domain, color: AppTheme.primaryGreenDark, size: 18),
              const SizedBox(width: 6),
              const Text(
                'Khoa / Viện Trực Thuộc',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              const SizedBox(width: 6),
              Text(
                '(${faculties.length} khoa)',
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
              const Spacer(),
              if (_selectedFacultyId != null)
                InkWell(
                  onTap: () => setState(() => _selectedFacultyId = null),
                  child: const Text('Xem tất cả', style: TextStyle(fontSize: 11, color: AppTheme.youthBlue, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: faculties.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isAll = _selectedFacultyId == null;
                  return ChoiceChip(
                    label: const Text('Tất Cả Khoa'),
                    labelStyle: TextStyle(
                      color: isAll ? Colors.white : AppTheme.textDark,
                      fontSize: 11,
                      fontWeight: isAll ? FontWeight.bold : FontWeight.normal,
                    ),
                    selected: isAll,
                    selectedColor: AppTheme.primaryGreen,
                    backgroundColor: Colors.grey.shade100,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _selectedFacultyId = null),
                  );
                }

                final fac = faculties[index - 1];
                final isSelected = _selectedFacultyId == fac.id;
                final activityCount = _dataService.getCampaignCountByFaculty(fac.id);
                final facColor = Color(fac.colorValue);

                return ChoiceChip(
                  avatar: CircleAvatar(
                    backgroundColor: isSelected ? Colors.white : facColor,
                    child: Text(
                      fac.code.substring(0, fac.code.length > 2 ? 2 : fac.code.length),
                      style: TextStyle(
                        color: isSelected ? facColor : Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  label: Text('${fac.name} ($activityCount)'),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textDark,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  selected: isSelected,
                  selectedColor: facColor,
                  backgroundColor: Colors.white,
                  side: BorderSide(color: isSelected ? facColor : Colors.grey.shade300),
                  showCheckmark: false,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFacultyId = selected ? fac.id : null;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET 2: KHUNG LỊCH HOẠT ĐỘNG (THIẾT KẾ GỌN GÀNG THEO MẪU) ---
  Widget _buildCalendarSection() {
    final firstDayOfMonth = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    final daysInCurrentMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday; // 1 = T2 ... 7 = CN

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final totalRequiredCells = (startingWeekday - 1) + daysInCurrentMonth;
    final totalCells = totalRequiredCells > 35 ? 42 : 35;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Lịch
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFDBEAFE)),
                    ),
                    child: const Icon(Icons.calendar_today_outlined, color: Color(0xFF2563EB), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tháng ${_calendarMonth.month} Năm ${_calendarMonth.year}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'Lịch Hoạt Động & Sự Kiện',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Nút chuyển tháng trước
                  InkWell(
                    onTap: () => setState(() => _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month - 1)),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(Icons.chevron_left, size: 18, color: Color(0xFF64748B)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Nút chuyển tháng sau
                  InkWell(
                    onTap: () => setState(() => _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1)),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(Icons.chevron_right, size: 18, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Thứ trong tuần (T2 -> CN)
              Row(
                children: const ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'].map((w) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        w,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),

              // Grid các ô ngày
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalCells,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.05,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                ),
                itemBuilder: (context, index) {
                  final dayOffset = index - (startingWeekday - 1);
                  if (dayOffset < 0 || dayOffset >= daysInCurrentMonth) {
                    return const SizedBox.shrink();
                  }

                  final dayNumber = dayOffset + 1;
                  final date = DateTime(_calendarMonth.year, _calendarMonth.month, dayNumber);
                  final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
                  final isSelected = _selectedCalendarDate != null &&
                      date.year == _selectedCalendarDate!.year &&
                      date.month == _selectedCalendarDate!.month &&
                      date.day == _selectedCalendarDate!.day;

                  // Xác định trạng thái sự kiện
                  final campaignsOnDay = _getCampaignsOnDate(date);
                  bool hasOngoing = false;
                  bool hasUpcoming = false;
                  bool hasEnded = false;

                  for (final c in campaignsOnDay) {
                    final end = DateTime(c.endDate.year, c.endDate.month, c.endDate.day);
                    if (c.status == 'Đã hoàn thành' || end.isBefore(today)) {
                      hasEnded = true;
                    } else if (c.status == 'Đang diễn ra') {
                      hasOngoing = true;
                    } else {
                      hasUpcoming = true;
                    }
                  }

                  Color bgColor = const Color(0xFFF8FAFC);
                  Color textColor = const Color(0xFF94A3B8);
                  Border? cellBorder;
                  Widget? dotWidget;

                  if (hasOngoing) {
                    // Đỏ: Đang diễn ra
                    bgColor = const Color(0xFFFF2D55);
                    textColor = Colors.white;
                    dotWidget = Container(width: 3.5, height: 3.5, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle));
                  } else if (hasUpcoming) {
                    // Xanh: Sắp diễn ra / Đang tuyển
                    bgColor = const Color(0xFF00B074);
                    textColor = Colors.white;
                    dotWidget = Container(width: 3.5, height: 3.5, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle));
                  } else if (hasEnded) {
                    // Xám: Đã kết thúc
                    bgColor = const Color(0xFFE2E8F0);
                    textColor = const Color(0xFF1E293B);
                    dotWidget = Container(width: 3.5, height: 3.5, decoration: const BoxDecoration(color: Color(0xFF94A3B8), shape: BoxShape.circle));
                  }

                  // Hôm nay
                  if (isToday) {
                    cellBorder = Border.all(color: const Color(0xFF0084FF), width: 1.8);
                    if (!hasOngoing && !hasUpcoming && !hasEnded) {
                      bgColor = Colors.white;
                      textColor = const Color(0xFF0084FF);
                    }
                  }

                  // Đang chọn lọc
                  if (isSelected) {
                    cellBorder = Border.all(color: Colors.black87, width: 2);
                  }

                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedCalendarDate = null;
                        } else {
                          _selectedCalendarDate = date;
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: cellBorder,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNumber',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: (hasOngoing || hasUpcoming || hasEnded || isToday) ? FontWeight.bold : FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                          if (dotWidget != null) ...[
                            const SizedBox(height: 2),
                            dotWidget,
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Ghi chú dưới lịch
              const Center(
                child: Text(
                  'Bấm vào các ngày nổi màu để xem chi tiết sự kiện và đơn vị tổ chức',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
              const SizedBox(height: 8),

              // Chú thích (Legend)
              Wrap(
                alignment: WrapAlignment.spaceAround,
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildLegendItem(
                    iconWidget: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: const Color(0xFF0084FF), width: 1.4),
                      ),
                    ),
                    label: 'Hôm nay',
                  ),
                  _buildLegendItem(
                    iconWidget: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2D55),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    label: 'Đang diễn ra',
                  ),
                  _buildLegendItem(
                    iconWidget: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B074),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    label: 'Sắp diễn ra',
                  ),
                  _buildLegendItem(
                    iconWidget: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    label: 'Đã kết thúc',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem({required Widget iconWidget, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  // --- WIDGET 3: THANH LỌC NHANH (TẤT CẢ / GẦN TRƯỜNG / DANH MỤC) ---
  Widget _buildFilterChipsRow(List<String> categories) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Nút Lọc đặc biệt: "Gần trường (< 5km)"
          FilterChip(
            avatar: Icon(
              Icons.near_me,
              size: 15,
              color: _onlyNearCampus ? Colors.white : Colors.redAccent,
            ),
            label: const Text('Gần trường (< 5km)'),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _onlyNearCampus ? Colors.white : Colors.red.shade900,
            ),
            selected: _onlyNearCampus,
            selectedColor: Colors.red.shade700,
            backgroundColor: Colors.red.shade50,
            side: BorderSide(color: _onlyNearCampus ? Colors.red.shade700 : Colors.red.shade200),
            showCheckmark: false,
            onSelected: (val) => setState(() => _onlyNearCampus = val),
          ),
          const SizedBox(width: 8),

          // Các danh mục mảng hoạt động
          ...categories.map((cat) {
            final isSelected = _selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(cat),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textDark,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                selected: isSelected,
                selectedColor: AppTheme.primaryGreen,
                backgroundColor: Colors.white,
                side: BorderSide(color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300),
                showCheckmark: false,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedCategory = cat);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  // Banner hiển thị thông tin phạm vi trường học
  Widget _buildNearCampusBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school, size: 18, color: Colors.red),
              const SizedBox(width: 8),
              const Text(
                'Phạm Vi Gần Khuôn Viên Trường',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Bán kính < 5km', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Địa chỉ trường: ${_dataService.universityCampusAddress}',
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
          const SizedBox(height: 2),
          const Text(
            '• Các hoạt động này diễn ra ngay tại trường hoặc phường lân cận, sinh viên có thể tham gia và về trong ngày.',
            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  // Thẻ hiển thị một chiến dịch / hoạt động
  Widget _buildCampaignCard(Campaign item, DateFormat dateFormat) {
    final isRegistered = _dataService.registrations.any(
      (r) => r.campaignId == item.id && r.volunteerId == _dataService.currentVolunteer.id,
    );

    // Xác định màu khoa nếu có
    Color facColor = AppTheme.primaryGreen;
    if (item.facultyId != null) {
      final fac = _dataService.faculties.where((f) => f.id == item.facultyId);
      if (fac.isNotEmpty) {
        facColor = Color(fac.first.colorValue);
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              // Hàng badge: Khoa tổ chức + Mảng + Gần trường + Đã đăng ký
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  // Badge Khoa
                  if (item.facultyName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: facColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: facColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.domain, size: 11, color: facColor),
                          const SizedBox(width: 4),
                          Text(
                            item.facultyName!,
                            style: TextStyle(
                              color: facColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Badge Mảng hoạt động
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
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Badge Gần trường
                  if (item.isNearCampus || (item.distanceFromCampusKm != null && item.distanceFromCampusKm! <= 5.0))
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.near_me, size: 10, color: Colors.red),
                          const SizedBox(width: 3),
                          Text(
                            item.distanceFromCampusKm != null
                                ? 'Gần trường (${item.distanceFromCampusKm} km)'
                                : 'Tại trường',
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (item.distanceFromCampusKm != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Đi tỉnh • ${item.distanceFromCampusKm!.toInt()} km',
                        style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                      ),
                    ),

                  if (isRegistered)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, size: 11, color: AppTheme.youthBlue),
                          SizedBox(width: 3),
                          Text(
                            'Đã đăng ký',
                            style: TextStyle(
                              color: AppTheme.youthBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Tên chiến dịch
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 6),

              // Địa điểm
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

              // Thời gian
              Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, size: 14, color: AppTheme.youthBlue),
                  const SizedBox(width: 4),
                  Text(
                    '${dateFormat.format(item.startDate)} - ${dateFormat.format(item.endDate)}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const Spacer(),

                  // Trạng thái (Đang tuyển / Đang diễn ra / Đã hoàn thành)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.status == 'Đã hoàn thành'
                          ? Colors.grey.shade200
                          : AppTheme.primaryGreenLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: item.status == 'Đã hoàn thành'
                            ? Colors.grey.shade700
                            : AppTheme.primaryGreenDark,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),

              // Bottom Info: Tuyển, Giờ TN, ĐRL + Nút Đăng ký
              Row(
                children: [
                  _buildSmallBadge(
                    Icons.group_outlined,
                    '${item.currentRegistered}/${item.targetVolunteers}',
                    Colors.grey.shade700,
                  ),
                  const SizedBox(width: 12),
                  _buildSmallBadge(
                    Icons.timer_outlined,
                    '${item.volunteerHours}h',
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: const Size(0, 30),
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
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.volunteer_activism_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text('Không tìm thấy hoạt động phù hợp', style: TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _selectedFacultyId = null;
                _onlyNearCampus = false;
                _selectedCategory = 'Tất cả';
                _selectedCalendarDate = null;
                _searchKeyword = '';
              });
            },
            child: const Text('Bỏ tất cả bộ lọc'),
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
