class UniversityBookingPreview {
  final String bookingId;
  final String bookingCode;
  final String passengerName;
  final String studentId;
  final String fromCity;
  final String toCity;
  final String departureDate;
  final String departureTime;
  final int seatNumber;
  final double fare;
  final bool alreadyBoarded;

  const UniversityBookingPreview({
    required this.bookingId,
    required this.bookingCode,
    required this.passengerName,
    required this.studentId,
    required this.fromCity,
    required this.toCity,
    required this.departureDate,
    required this.departureTime,
    required this.seatNumber,
    required this.fare,
    required this.alreadyBoarded,
  });

  factory UniversityBookingPreview.fromJson(Map<String, dynamic> json) {
    return UniversityBookingPreview(
      bookingId:     json['bookingId'] as String? ?? '',
      bookingCode:   json['bookingCode'] as String? ?? '',
      passengerName: json['passengerName'] as String? ?? '',
      studentId:     json['studentId'] as String? ?? '',
      fromCity:      json['fromCity'] as String? ?? '',
      toCity:        json['toCity'] as String? ?? '',
      departureDate: json['departureDate'] as String? ?? '',
      departureTime: json['departureTime'] as String? ?? '',
      seatNumber:    (json['seatNumber'] as num?)?.toInt() ?? 0,
      fare:          (json['fare'] as num?)?.toDouble() ?? 0,
      alreadyBoarded: json['alreadyBoarded'] as bool? ?? false,
    );
  }

  String get routeLabel => '$fromCity → $toCity';
}

class UniversityScanResult {
  final String bookingCode;
  final String passengerName;
  final int seatNumber;
  final DateTime boardedAt;
  final double grossAmount;
  final double ugoCommission;
  final double netAmount;

  const UniversityScanResult({
    required this.bookingCode,
    required this.passengerName,
    required this.seatNumber,
    required this.boardedAt,
    required this.grossAmount,
    required this.ugoCommission,
    required this.netAmount,
  });

  factory UniversityScanResult.fromJson(Map<String, dynamic> json) {
    final earning = json['earning'] as Map<String, dynamic>? ?? {};
    return UniversityScanResult(
      bookingCode:   json['bookingCode'] as String? ?? '',
      passengerName: json['passengerName'] as String? ?? '',
      seatNumber:    (json['seatNumber'] as num?)?.toInt() ?? 0,
      boardedAt:     DateTime.tryParse(json['boardedAt'] as String? ?? '') ?? DateTime.now(),
      grossAmount:   (earning['grossAmount'] as num?)?.toDouble() ?? 0,
      ugoCommission: (earning['ugoCommission'] as num?)?.toDouble() ?? 0,
      netAmount:     (earning['netAmount'] as num?)?.toDouble() ?? 0,
    );
  }
}
