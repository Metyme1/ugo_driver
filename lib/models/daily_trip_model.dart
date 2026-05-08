class StudentTripStatus {
  final String childId;
  final String parentId;
  final String? childName;
  final String? childGrade;
  final String? parentName;
  final bool pickedUp;
  final DateTime? pickedUpAt;
  final bool droppedOff;
  final DateTime? droppedOffAt;

  const StudentTripStatus({
    required this.childId,
    required this.parentId,
    this.childName,
    this.childGrade,
    this.parentName,
    required this.pickedUp,
    this.pickedUpAt,
    required this.droppedOff,
    this.droppedOffAt,
  });

  factory StudentTripStatus.fromJson(Map<String, dynamic> json) {
    final child  = json['child'];
    final parent = json['parent'];

    String? extractName(dynamic obj) {
      if (obj is! Map) return null;
      if (obj['name'] != null) return obj['name'].toString().trim();
      final first = obj['firstName']?.toString() ?? '';
      final last  = obj['lastName']?.toString() ?? '';
      final full  = '$first $last'.trim();
      return full.isNotEmpty ? full : null;
    }

    return StudentTripStatus(
      childId:      (child is Map ? child['_id'] : child)?.toString() ?? '',
      parentId:     (parent is Map ? parent['_id'] : parent)?.toString() ?? '',
      childName:    extractName(child),
      childGrade:   child is Map ? child['grade']?.toString() : null,
      parentName:   extractName(parent),
      pickedUp:     json['picked_up'] == true,
      pickedUpAt:   json['picked_up_at'] != null ? DateTime.tryParse(json['picked_up_at']) : null,
      droppedOff:   json['dropped_off'] == true,
      droppedOffAt: json['dropped_off_at'] != null ? DateTime.tryParse(json['dropped_off_at']) : null,
    );
  }
}

class DriverDailyTrip {
  final String id;
  final String groupId;
  final String groupName;
  final String? schoolName;
  final String routeType;
  final String routeLabel;
  final String scheduledTime;
  final String status;
  final int studentCount;
  final int pickedUpCount;
  final int droppedOffCount;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final List<StudentTripStatus> students;

  const DriverDailyTrip({
    required this.id,
    required this.groupId,
    required this.groupName,
    this.schoolName,
    required this.routeType,
    required this.routeLabel,
    required this.scheduledTime,
    required this.status,
    required this.studentCount,
    required this.pickedUpCount,
    required this.droppedOffCount,
    this.startedAt,
    this.completedAt,
    this.students = const [],
  });

  factory DriverDailyTrip.fromJson(Map<String, dynamic> json) {
    final school = json['school'];
    return DriverDailyTrip(
      id:             json['trip_id']?.toString() ?? '',
      groupId:        (json['group_id'] ?? json['group'])?.toString() ?? '',
      groupName:      json['group_name'] ?? '',
      schoolName:     school is Map ? school['name'] : school?.toString(),
      routeType:      json['route_type'] ?? '',
      routeLabel:     json['route_label'] ?? '',
      scheduledTime:  json['scheduled_time'] ?? '',
      status:         json['status'] ?? 'scheduled',
      studentCount:   json['student_count'] as int? ?? 0,
      pickedUpCount:  json['picked_up_count'] as int? ?? 0,
      droppedOffCount: json['dropped_off_count'] as int? ?? 0,
      startedAt:      json['started_at'] != null ? DateTime.tryParse(json['started_at']) : null,
      completedAt:    json['completed_at'] != null ? DateTime.tryParse(json['completed_at']) : null,
      students: (json['students'] as List<dynamic>? ?? [])
          .map((s) => StudentTripStatus.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get isScheduled  => status == 'scheduled';
  bool get isActive     => status == 'started' || status == 'in_progress';
  bool get isCompleted  => status == 'completed';
  bool get isToSchool   => routeType == 'morning_to_school' || routeType == 'afternoon_to_school';

  String get statusLabel {
    switch (status) {
      case 'scheduled':   return 'Scheduled';
      case 'started':     return 'Started';
      case 'in_progress': return 'In Progress';
      case 'completed':   return 'Completed';
      case 'cancelled':   return 'Cancelled';
      default:            return status;
    }
  }
}
