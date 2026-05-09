class GroupModel {
  final String id;
  final String name;
  final String vehicleType;
  final int capacity;
  final int currentMembers;
  final String status;
  final Map<String, dynamic>? school;
  final String? pickupAddress;
  final String? scheduleTime;
  final DateTime? createdAt;

  const GroupModel({
    required this.id,
    required this.name,
    required this.vehicleType,
    required this.capacity,
    required this.currentMembers,
    required this.status,
    this.school,
    this.pickupAddress,
    this.scheduleTime,
    this.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      vehicleType: json['vehicleType'] ?? json['vehicle_type'] ?? '',
      capacity: json['capacity'] ?? 0,
      currentMembers: (json['members'] as List?)?.length ?? json['currentMembers'] ?? 0,
      status: json['status'] ?? 'open',
      school: json['school'] as Map<String, dynamic>?,
      pickupAddress: json['pickupAddress'] ?? json['pickup_address'],
      scheduleTime: json['scheduleTime'] ?? json['schedule_time'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  String get schoolName => school?['name'] ?? 'Unknown School';
  int get spotsLeft => capacity - currentMembers;
}

class ScanResult {
  final String purchaseId;
  final String parentName;
  final String parentPhone;
  final String? childName;
  final String? childGrade;
  final String packageTitle;
  final String route;
  final int ridesUsed;
  final int ridesTotal;
  final int ridesLeft;
  final DateTime expiresAt;

  const ScanResult({
    required this.purchaseId,
    required this.parentName,
    required this.parentPhone,
    this.childName,
    this.childGrade,
    required this.packageTitle,
    required this.route,
    required this.ridesUsed,
    required this.ridesTotal,
    required this.ridesLeft,
    required this.expiresAt,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      purchaseId: json['purchaseId'] ?? '',
      parentName: json['parentName'] ?? '',
      parentPhone: json['parentPhone'] ?? '',
      childName: json['childName'],
      childGrade: json['childGrade'],
      packageTitle: json['packageTitle'] ?? '',
      route: json['route'] ?? '',
      ridesUsed: json['ridesUsed'] ?? 0,
      ridesTotal: json['ridesTotal'] ?? 0,
      ridesLeft: json['ridesLeft'] ?? 0,
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }
}
