class DriverNomination {
  final String groupId;
  final String groupName;
  final Map<String, dynamic>? school;
  final String vehicleType;
  final int capacity;
  final int currentMembers;
  final String? pickupAddress;
  final String assignmentStatus;
  final String myResponse; // pending | accepted | declined
  final DateTime? offeredAt;
  final DateTime? respondedAt;

  const DriverNomination({
    required this.groupId,
    required this.groupName,
    this.school,
    required this.vehicleType,
    required this.capacity,
    required this.currentMembers,
    this.pickupAddress,
    required this.assignmentStatus,
    required this.myResponse,
    this.offeredAt,
    this.respondedAt,
  });

  factory DriverNomination.fromJson(Map<String, dynamic> json) {
    return DriverNomination(
      groupId: json['group_id'] ?? '',
      groupName: json['group_name'] ?? '',
      school: json['school'] as Map<String, dynamic>?,
      vehicleType: json['vehicle_type'] ?? '',
      capacity: json['capacity'] ?? 0,
      currentMembers: json['current_members'] ?? 0,
      pickupAddress: json['pickup_address'],
      assignmentStatus: json['assignment_status'] ?? '',
      myResponse: json['my_response'] ?? 'pending',
      offeredAt: json['offered_at'] != null ? DateTime.tryParse(json['offered_at']) : null,
      respondedAt: json['responded_at'] != null ? DateTime.tryParse(json['responded_at']) : null,
    );
  }

  bool get isPending => myResponse == 'pending';
  bool get isAccepted => myResponse == 'accepted';
  String get schoolName => school?['name'] ?? 'Unknown School';
}

// ─── Full nomination detail (fetched on demand) ────────────────────────────

class NominationDetail {
  final String groupId;
  final String groupName;
  final Map<String, dynamic>? school;
  final String vehicleType;
  final int capacity;
  final int currentMembers;
  final String? pickupAddress;
  final List<double>? pickupCoordinates; // [lng, lat]
  final String assignmentStatus;
  final String myResponse;
  final double? basePrice;
  final String? description;
  final DateTime? offeredAt;
  final DateTime? respondedAt;
  final List<NominationStudent> students;

  const NominationDetail({
    required this.groupId,
    required this.groupName,
    this.school,
    required this.vehicleType,
    required this.capacity,
    required this.currentMembers,
    this.pickupAddress,
    this.pickupCoordinates,
    required this.assignmentStatus,
    required this.myResponse,
    this.basePrice,
    this.description,
    this.offeredAt,
    this.respondedAt,
    required this.students,
  });

  factory NominationDetail.fromJson(Map<String, dynamic> json) {
    List<double>? coords;
    final rawCoords = json['pickup_location']?['coordinates'];
    if (rawCoords is List && rawCoords.length == 2) {
      coords = [
        (rawCoords[0] as num).toDouble(),
        (rawCoords[1] as num).toDouble(),
      ];
    }

    return NominationDetail(
      groupId: json['group_id'] ?? '',
      groupName: json['group_name'] ?? '',
      school: json['school'] as Map<String, dynamic>?,
      vehicleType: json['vehicle_type'] ?? '',
      capacity: json['capacity'] ?? 0,
      currentMembers: json['current_members'] ?? 0,
      pickupAddress: json['pickup_address'],
      pickupCoordinates: coords,
      assignmentStatus: json['assignment_status'] ?? '',
      myResponse: json['my_response'] ?? 'pending',
      basePrice: json['base_price'] != null ? (json['base_price'] as num).toDouble() : null,
      description: json['description'],
      offeredAt: json['offered_at'] != null ? DateTime.tryParse(json['offered_at']) : null,
      respondedAt: json['responded_at'] != null ? DateTime.tryParse(json['responded_at']) : null,
      students: (json['students'] as List? ?? [])
          .map((s) => NominationStudent.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get isPending => myResponse == 'pending';
  String get schoolName => school?['name'] ?? 'Unknown School';
}

class NominationStudent {
  final String childId;
  final String name;
  final String grade;
  final String? pickupAddress;
  final String? pickupLandmark;
  final List<double>? pickupCoordinates; // [lng, lat]
  final Map<String, dynamic>? destinationSchool;
  final String? vehiclePreference;

  const NominationStudent({
    required this.childId,
    required this.name,
    required this.grade,
    this.pickupAddress,
    this.pickupLandmark,
    this.pickupCoordinates,
    this.destinationSchool,
    this.vehiclePreference,
  });

  factory NominationStudent.fromJson(Map<String, dynamic> json) {
    List<double>? coords;
    final rawCoords = json['pickup_coordinates'];
    if (rawCoords is List && rawCoords.length == 2) {
      coords = [(rawCoords[0] as num).toDouble(), (rawCoords[1] as num).toDouble()];
    }
    return NominationStudent(
      childId: json['child_id'] ?? '',
      name: json['name'] ?? '',
      grade: json['grade'] ?? '',
      pickupAddress: json['pickup_address'],
      pickupLandmark: json['pickup_landmark'],
      pickupCoordinates: coords,
      destinationSchool: json['destination_school'] as Map<String, dynamic>?,
      vehiclePreference: json['vehicle_preference'],
    );
  }

  String get destinationName => destinationSchool?['name'] ?? 'Unknown';
  double? get destinationLat => (destinationSchool?['latitude'] as num?)?.toDouble();
  double? get destinationLng => (destinationSchool?['longitude'] as num?)?.toDouble();
}
