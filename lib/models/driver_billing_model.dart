class DriverMonthlySummary {
  final String monthYear;
  final double grossTotal;
  final double ugoCommissionTotal;
  final double netEarnings;
  final int tripCount;
  final int subscriptionCount;
  final double driverPlatformFee;
  final String platformFeeStatus;
  final double platformFeeDeducted;
  final double estimatedPayout;
  final String currency;

  const DriverMonthlySummary({
    required this.monthYear,
    required this.grossTotal,
    required this.ugoCommissionTotal,
    required this.netEarnings,
    required this.tripCount,
    required this.subscriptionCount,
    required this.driverPlatformFee,
    required this.platformFeeStatus,
    required this.platformFeeDeducted,
    required this.estimatedPayout,
    required this.currency,
  });

  factory DriverMonthlySummary.fromJson(Map<String, dynamic> json) {
    return DriverMonthlySummary(
      monthYear:           json['monthYear'] as String? ?? '',
      grossTotal:          (json['grossTotal'] as num?)?.toDouble() ?? 0,
      ugoCommissionTotal:  (json['ugoCommissionTotal'] as num?)?.toDouble() ?? 0,
      netEarnings:         (json['netEarnings'] as num?)?.toDouble() ?? 0,
      tripCount:           (json['tripCount'] as num?)?.toInt() ?? 0,
      subscriptionCount:   (json['subscriptionCount'] as num?)?.toInt() ?? 0,
      driverPlatformFee:   (json['driverPlatformFee'] as num?)?.toDouble() ?? 0,
      platformFeeStatus:   json['platformFeeStatus'] as String? ?? 'none',
      platformFeeDeducted: (json['platformFeeDeducted'] as num?)?.toDouble() ?? 0,
      estimatedPayout:     (json['estimatedPayout'] as num?)?.toDouble() ?? 0,
      currency:            json['currency'] as String? ?? 'ETB',
    );
  }

  static DriverMonthlySummary empty(String monthYear) => DriverMonthlySummary(
    monthYear: monthYear, grossTotal: 0, ugoCommissionTotal: 0,
    netEarnings: 0, tripCount: 0, subscriptionCount: 0,
    driverPlatformFee: 0, platformFeeStatus: 'none',
    platformFeeDeducted: 0, estimatedPayout: 0, currency: 'ETB',
  );
}

class DriverEarningRecord {
  final String id;
  final String type;
  final String? groupName;
  final String? routeType;
  final String monthYear;
  final double grossAmount;
  final double commissionRate;
  final double ugoCommission;
  final double netAmount;
  final DateTime? earnedAt;
  final String? description;

  const DriverEarningRecord({
    required this.id,
    required this.type,
    this.groupName,
    this.routeType,
    required this.monthYear,
    required this.grossAmount,
    required this.commissionRate,
    required this.ugoCommission,
    required this.netAmount,
    this.earnedAt,
    this.description,
  });

  factory DriverEarningRecord.fromJson(Map<String, dynamic> json) {
    final group = json['group'] as Map<String, dynamic>?;
    final trip  = json['trip']  as Map<String, dynamic>?;
    return DriverEarningRecord(
      id:             json['_id'] as String? ?? '',
      type:           json['type'] as String? ?? '',
      groupName:      group?['name'] as String?,
      routeType:      trip?['route_type'] as String?,
      monthYear:      json['monthYear'] as String? ?? '',
      grossAmount:    (json['grossAmount'] as num?)?.toDouble() ?? 0,
      commissionRate: (json['commissionRate'] as num?)?.toDouble() ?? 0,
      ugoCommission:  (json['ugoCommission'] as num?)?.toDouble() ?? 0,
      netAmount:      (json['netAmount'] as num?)?.toDouble() ?? 0,
      earnedAt: json['earnedAt'] != null
          ? DateTime.tryParse(json['earnedAt'] as String) : null,
      description: json['description'] as String?,
    );
  }
}

class DriverPlatformSubscription {
  final String id;
  final String monthYear;
  final String vehicleType;
  final double fee;
  final String status;
  final String? paymentRef;
  final String? paymentBank;
  final DateTime? paidAt;

  const DriverPlatformSubscription({
    required this.id,
    required this.monthYear,
    required this.vehicleType,
    required this.fee,
    required this.status,
    this.paymentRef,
    this.paymentBank,
    this.paidAt,
  });

  factory DriverPlatformSubscription.fromJson(Map<String, dynamic> json) {
    return DriverPlatformSubscription(
      id:          json['_id'] as String? ?? '',
      monthYear:   json['monthYear'] as String? ?? '',
      vehicleType: json['vehicleType'] as String? ?? '',
      fee:         (json['fee'] as num?)?.toDouble() ?? 0,
      status:      json['status'] as String? ?? 'due',
      paymentRef:  json['paymentRef'] as String?,
      paymentBank: json['paymentBank'] as String?,
      paidAt: json['paidAt'] != null
          ? DateTime.tryParse(json['paidAt'] as String) : null,
    );
  }

  bool get isDue     => status == 'due' || status == 'overdue';
  bool get isPaid    => status == 'paid';
  bool get isWaived  => status == 'waived';
  bool get isPending => status == 'pending_payment';
}
