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

/// One subscription contract whose earnings are still on hold, with the
/// driver's early-release request status (if any) for that contract.
class PendingSubscriptionPayout {
  final String subscriptionId;
  final String? groupName;
  final double amount;
  final DateTime? scheduledReleaseDate;
  final String earlyReleaseRequestStatus; // none | pending | approved | rejected

  const PendingSubscriptionPayout({
    required this.subscriptionId,
    this.groupName,
    required this.amount,
    this.scheduledReleaseDate,
    required this.earlyReleaseRequestStatus,
  });

  factory PendingSubscriptionPayout.fromJson(Map<String, dynamic> json) {
    return PendingSubscriptionPayout(
      subscriptionId: json['subscriptionId'] as String? ?? '',
      groupName:      json['groupName'] as String?,
      amount:         (json['amount'] as num?)?.toDouble() ?? 0,
      scheduledReleaseDate: json['scheduledReleaseDate'] != null
          ? DateTime.tryParse(json['scheduledReleaseDate'] as String) : null,
      earlyReleaseRequestStatus: json['earlyReleaseRequestStatus'] as String? ?? 'none',
    );
  }

  bool get hasOpenRequest => earlyReleaseRequestStatus == 'pending';
  bool get canRequestEarlyRelease =>
      earlyReleaseRequestStatus == 'none' || earlyReleaseRequestStatus == 'rejected';
}

/// Lifetime wallet breakdown for the driver — distinguishes instantly
/// withdrawable income (packages, trips, extra rides) from subscription
/// income still on hold pending the contract's release date.
class DriverWalletOverview {
  final double totalIncome;
  final double availableBalance;
  final double unwithdrawnPackageBalance;
  final double pendingSubscriptionBalance;
  final DateTime? nextReleaseDate;
  final List<PendingSubscriptionPayout> pendingBySubscription;
  final String currency;

  const DriverWalletOverview({
    required this.totalIncome,
    required this.availableBalance,
    required this.unwithdrawnPackageBalance,
    required this.pendingSubscriptionBalance,
    this.nextReleaseDate,
    required this.pendingBySubscription,
    required this.currency,
  });

  factory DriverWalletOverview.fromJson(Map<String, dynamic> json) {
    final list = json['pendingBySubscription'] as List<dynamic>? ?? [];
    return DriverWalletOverview(
      totalIncome:                (json['totalIncome'] as num?)?.toDouble() ?? 0,
      availableBalance:           (json['availableBalance'] as num?)?.toDouble() ?? 0,
      unwithdrawnPackageBalance:  (json['unwithdrawnPackageBalance'] as num?)?.toDouble() ?? 0,
      pendingSubscriptionBalance: (json['pendingSubscriptionBalance'] as num?)?.toDouble() ?? 0,
      nextReleaseDate: json['nextReleaseDate'] != null
          ? DateTime.tryParse(json['nextReleaseDate'] as String) : null,
      pendingBySubscription: list
          .map((e) => PendingSubscriptionPayout.fromJson(e as Map<String, dynamic>))
          .toList(),
      currency: json['currency'] as String? ?? 'ETB',
    );
  }

  static DriverWalletOverview empty() => const DriverWalletOverview(
    totalIncome: 0, availableBalance: 0, unwithdrawnPackageBalance: 0,
    pendingSubscriptionBalance: 0, pendingBySubscription: [], currency: 'ETB',
  );
}

/// A driver's request to cash out held subscription earnings early.
class DriverEarlyReleaseRequest {
  final String id;
  final String subscriptionId;
  final double totalAmount;
  final String status; // pending | approved | rejected
  final DateTime? requestedAt;
  final DateTime? reviewedAt;
  final String? adminNote;

  const DriverEarlyReleaseRequest({
    required this.id,
    required this.subscriptionId,
    required this.totalAmount,
    required this.status,
    this.requestedAt,
    this.reviewedAt,
    this.adminNote,
  });

  factory DriverEarlyReleaseRequest.fromJson(Map<String, dynamic> json) {
    final sub = json['subscription'];
    final subscriptionId = sub is Map<String, dynamic>
        ? (sub['_id'] as String? ?? '')
        : (sub as String? ?? '');
    return DriverEarlyReleaseRequest(
      id:             json['_id'] as String? ?? '',
      subscriptionId: subscriptionId,
      totalAmount:    (json['totalAmount'] as num?)?.toDouble() ?? 0,
      status:         json['status'] as String? ?? 'pending',
      requestedAt: json['requestedAt'] != null
          ? DateTime.tryParse(json['requestedAt'] as String) : null,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'] as String) : null,
      adminNote: json['adminNote'] as String?,
    );
  }

  bool get isPending  => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
