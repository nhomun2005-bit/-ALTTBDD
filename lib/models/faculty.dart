class Faculty {
  final String id;
  final String code;
  final String name;
  final String description;
  final String leaderName;
  final String contactPhone;
  final int colorValue;

  Faculty({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.leaderName,
    required this.contactPhone,
    this.colorValue = 0xFF1E88E5,
  });

  Faculty copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    String? leaderName,
    String? contactPhone,
    int? colorValue,
  }) {
    return Faculty(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      leaderName: leaderName ?? this.leaderName,
      contactPhone: contactPhone ?? this.contactPhone,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'leaderName': leaderName,
      'contactPhone': contactPhone,
      'colorValue': colorValue,
    };
  }

  factory Faculty.fromMap(Map<String, dynamic> map) {
    return Faculty(
      id: map['id'],
      code: map['code'],
      name: map['name'],
      description: map['description'] ?? '',
      leaderName: map['leaderName'] ?? '',
      contactPhone: map['contactPhone'] ?? '',
      colorValue: map['colorValue'] ?? 0xFF1E88E5,
    );
  }
}
