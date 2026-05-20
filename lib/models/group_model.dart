class GroupMember {
  final String childId;
  final String childName;
  final String? childGrade;
  final String? parentName;
  final String? parentPhone;
  final String status;
  final String? pickupAddress;
  final String? pickupLandmark;
  final List<double>? pickupCoordinates; // [lng, lat] GeoJSON
  final Map<String, dynamic>? destinationSchool;

  const GroupMember({
    required this.childId,
    required this.childName,
    this.childGrade,
    this.parentName,
    this.parentPhone,
    required this.status,
    this.pickupAddress,
    this.pickupLandmark,
    this.pickupCoordinates,
    this.destinationSchool,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    final child = json['child'] is Map ? json['child'] as Map<String, dynamic> : null;
    final parent = json['parent'] is Map ? json['parent'] as Map<String, dynamic> : null;
    final firstName = parent?['firstName'] as String? ?? '';
    final lastName = parent?['lastName'] as String? ?? '';
    final fullName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');

    List<double>? coords;
    final rawCoords = json['pickup_coordinates'];
    if (rawCoords is List && rawCoords.length == 2) {
      coords = [(rawCoords[0] as num).toDouble(), (rawCoords[1] as num).toDouble()];
    }

    return GroupMember(
      childId: child?['_id'] ?? child?['id'] ?? '',
      childName: child?['name'] ?? 'Unknown',
      childGrade: child?['grade'] as String?,
      parentName: fullName.isNotEmpty ? fullName : null,
      parentPhone: parent?['phone'] as String?,
      status: json['status'] as String? ?? 'active',
      pickupAddress: json['pickup_address'] as String?,
      pickupLandmark: json['pickup_landmark'] as String?,
      pickupCoordinates: coords,
      destinationSchool: json['destination_school'] is Map
          ? Map<String, dynamic>.from(json['destination_school'] as Map)
          : null,
    );
  }

  String get destinationName => destinationSchool?['name'] as String? ?? 'Unknown';
  double? get destinationLat => (destinationSchool?['latitude'] as num?)?.toDouble();
  double? get destinationLng => (destinationSchool?['longitude'] as num?)?.toDouble();
}

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
  final List<GroupMember> members;

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
    this.members = const [],
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'] as List? ?? [];
    final members = rawMembers
        .whereType<Map<String, dynamic>>()
        .map(GroupMember.fromJson)
        .toList();
    return GroupModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      vehicleType: json['vehicleType'] ?? json['vehicle_type'] ?? '',
      capacity: json['capacity'] ?? 0,
      currentMembers: members.isNotEmpty ? members.length : (json['currentMembers'] ?? 0),
      status: json['status'] ?? 'open',
      school: json['school'] is Map
          ? Map<String, dynamic>.from(json['school'] as Map)
          : null,
      pickupAddress: json['pickupAddress'] ?? json['pickup_address'],
      scheduleTime: json['scheduleTime'] ?? json['schedule_time'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      members: members,
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
