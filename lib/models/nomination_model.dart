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
