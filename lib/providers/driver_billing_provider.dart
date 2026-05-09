import 'package:flutter/material.dart';
import '../models/driver_billing_model.dart';
import '../services/driver_billing_service.dart';
import '../services/api_service.dart';

class DriverBillingProvider extends ChangeNotifier {
  final DriverBillingService _service = DriverBillingService(ApiService());

  String _selectedMonth = _currentMonthYear();

  DriverMonthlySummary? _summary;
  bool _summaryLoading = false;
  String? _summaryError;

  List<DriverEarningRecord> _earnings = [];
  bool _earningsLoading = false;
  String? _earningsError;

  List<DriverPlatformSubscription> _platformSubs = [];
  bool _platformLoading = false;
  String? _platformError;

  bool _submitting = false;

  String get selectedMonth => _selectedMonth;

  DriverMonthlySummary? get summary => _summary;
  bool get summaryLoading => _summaryLoading;
  String? get summaryError => _summaryError;

  List<DriverEarningRecord> get earnings => _earnings;
  bool get earningsLoading => _earningsLoading;
  String? get earningsError => _earningsError;

  List<DriverPlatformSubscription> get platformSubs => _platformSubs;
  bool get platformLoading => _platformLoading;
  String? get platformError => _platformError;

  bool get submitting => _submitting;

  DriverPlatformSubscription? get currentMonthPlatformSub {
    try {
      return _platformSubs.firstWhere((s) => s.monthYear == _selectedMonth);
    } catch (_) {
      return null;
    }
  }

  void selectMonth(String monthYear) {
    if (_selectedMonth == monthYear) return;
    _selectedMonth = monthYear;
    notifyListeners();
    loadAll();
  }

  Future<void> loadAll() => Future.wait([loadSummary(), loadEarnings(), loadPlatformSubscriptions()]);

  Future<void> loadSummary() async {
    _summaryLoading = true;
    _summaryError = null;
    notifyListeners();
    try {
      _summary = await _service.getMonthlySummary(_selectedMonth);
    } catch (e) {
      _summaryError = e.toString().replaceFirst('Exception: ', '');
      _summary = DriverMonthlySummary.empty(_selectedMonth);
    } finally {
      _summaryLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEarnings() async {
    _earningsLoading = true;
    _earningsError = null;
    notifyListeners();
    try {
      _earnings = await _service.getEarnings(monthYear: _selectedMonth);
    } catch (e) {
      _earningsError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _earningsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPlatformSubscriptions() async {
    _platformLoading = true;
    _platformError = null;
    notifyListeners();
    try {
      _platformSubs = await _service.getPlatformSubscriptions();
    } catch (e) {
      _platformError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _platformLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitPlatformFeePayment({
    required String subscriptionId,
    required String paymentRef,
    required String paymentBank,
  }) async {
    _submitting = true;
    notifyListeners();
    try {
      await _service.submitPlatformFeePayment(
        subscriptionId: subscriptionId,
        paymentRef: paymentRef,
        paymentBank: paymentBank,
      );
      await loadAll();
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  static String _currentMonthYear() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }
}
