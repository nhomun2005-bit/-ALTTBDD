class Campaign {
  final String id;
  final String title;
  final String category;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final int targetVolunteers;
  final int currentRegistered;
  final String description;
  final String requirements;
  final int volunteerHours;
  final int trainingPoints;
  final String status; // 'Đang tuyển', 'Đang diễn ra', 'Đã hoàn thành'

  Campaign({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.targetVolunteers,
    this.currentRegistered = 0,
    required this.description,
    required this.requirements,
    required this.volunteerHours,
    required this.trainingPoints,
    this.status = 'Đang tuyển',
  });

  Campaign copyWith({
    String? id,
    String? title,
    String? category,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    int? targetVolunteers,
    int? currentRegistered,
    String? description,
    String? requirements,
    int? volunteerHours,
    int? trainingPoints,
    String? status,
  }) {
    return Campaign(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      targetVolunteers: targetVolunteers ?? this.targetVolunteers,
      currentRegistered: currentRegistered ?? this.currentRegistered,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      volunteerHours: volunteerHours ?? this.volunteerHours,
      trainingPoints: trainingPoints ?? this.trainingPoints,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'location': location,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'targetVolunteers': targetVolunteers,
      'currentRegistered': currentRegistered,
      'description': description,
      'requirements': requirements,
      'volunteerHours': volunteerHours,
      'trainingPoints': trainingPoints,
      'status': status,
    };
  }

  factory Campaign.fromMap(Map<String, dynamic> map) {
    return Campaign(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      location: map['location'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      targetVolunteers: map['targetVolunteers'],
      currentRegistered: map['currentRegistered'] ?? 0,
      description: map['description'],
      requirements: map['requirements'],
      volunteerHours: map['volunteerHours'],
      trainingPoints: map['trainingPoints'],
      status: map['status'] ?? 'Đang tuyển',
    );
  }
}
