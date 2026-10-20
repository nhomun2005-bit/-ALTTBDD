class LogisticsItem {
  final String itemName; // Ví dụ: Áo thun Mùa Hè Xanh, Nón tai bèo, Cuốc xẻng, Túi thuốc y tế, Băng rôn
  final int quantity; // Số lượng
  final String unit; // Cái, Bộ, Chiếc, Hộp, Cuộn
  final String note; // Trạng thái/Ghi chú chuẩn bị

  LogisticsItem({
    required this.itemName,
    required this.quantity,
    required this.unit,
    this.note = 'Đã chuẩn bị',
  });

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'quantity': quantity,
      'unit': unit,
      'note': note,
    };
  }

  factory LogisticsItem.fromMap(Map<String, dynamic> map) {
    return LogisticsItem(
      itemName: map['itemName'] ?? '',
      quantity: map['quantity'] ?? 0,
      unit: map['unit'] ?? '',
      note: map['note'] ?? '',
    );
  }
}

class ActivityBudgetLogistics {
  final String id;
  final String campaignId;
  final String campaignTitle;
  final double estimatedBudget; // Ngân sách dự kiến (VNĐ)
  final double actualCost; // Chi phí hoạt động thực tế (VNĐ)
  final List<LogisticsItem> logisticsItems; // Vật tư hậu cần theo biểu mẫu
  final String generalNotes;
  final DateTime lastUpdated;

  ActivityBudgetLogistics({
    required this.id,
    required this.campaignId,
    required this.campaignTitle,
    required this.estimatedBudget,
    required this.actualCost,
    required this.logisticsItems,
    this.generalNotes = '',
    required this.lastUpdated,
  });

  ActivityBudgetLogistics copyWith({
    String? id,
    String? campaignId,
    String? campaignTitle,
    double? estimatedBudget,
    double? actualCost,
    List<LogisticsItem>? logisticsItems,
    String? generalNotes,
    DateTime? lastUpdated,
  }) {
    return ActivityBudgetLogistics(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      campaignTitle: campaignTitle ?? this.campaignTitle,
      estimatedBudget: estimatedBudget ?? this.estimatedBudget,
      actualCost: actualCost ?? this.actualCost,
      logisticsItems: logisticsItems ?? this.logisticsItems,
      generalNotes: generalNotes ?? this.generalNotes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campaignId': campaignId,
      'campaignTitle': campaignTitle,
      'estimatedBudget': estimatedBudget,
      'actualCost': actualCost,
      'logisticsItems': logisticsItems.map((e) => e.toMap()).toList(),
      'generalNotes': generalNotes,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory ActivityBudgetLogistics.fromMap(Map<String, dynamic> map) {
    return ActivityBudgetLogistics(
      id: map['id'],
      campaignId: map['campaignId'],
      campaignTitle: map['campaignTitle'],
      estimatedBudget: (map['estimatedBudget'] as num).toDouble(),
      actualCost: (map['actualCost'] as num).toDouble(),
      logisticsItems: (map['logisticsItems'] as List<dynamic>?)
              ?.map((e) => LogisticsItem.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      generalNotes: map['generalNotes'] ?? '',
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }
}
