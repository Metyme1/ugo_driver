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

  DriverWalletOverview? _walletOverview;
  bool _walletLoading = false;
  String? _walletError;

  List<DriverEarlyReleaseRequest> _earlyReleaseRequests = [];
  bool _earlyReleaseLoading = false;

  bool _submitting = false;
  bool _requestingEarlyRelease = false;

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

  DriverWalletOverview? get walletOverview => _walletOverview;
  bool get walletLoading => _walletLoading;
  String? get walletError => _walletError;

  List<DriverEarlyReleaseRequest> get earlyReleaseRequests => _earlyReleaseRequests;
  bool get earlyReleaseLoading => _earlyReleaseLoading;
  bool get requestingEarlyRelease => _requestingEarlyRelease;

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

  Future<void> loadAll() => Future.wait([
    loadSummary(),
    loadEarnings(),
    loadPlatformSubscriptions(),
    loadWalletOverview(),
    loadEarlyReleaseRequests(),
  ]);

  Future<void> loadWalletOverview() async {
    _walletLoading = true;
    _walletError = null;
    notifyListeners();
    try {
      _walletOverview = await _service.getWalletOverview();
    } catch (e) {
      _walletError = e.toString().replaceFirst('Exception: ', '');
      _walletOverview = DriverWalletOverview.empty();
    } finally {
      _walletLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEarlyReleaseRequests() async {
    _earlyReleaseLoading = true;
    notifyListeners();
    try {
      _earlyReleaseRequests = await _service.getEarlyReleaseRequests();
    } catch (_) {
      // Non-critical for the wallet view — fail silently and keep prior state.
    } finally {
      _earlyReleaseLoading = false;
      notifyListeners();
    }
  }

  /// Submits a request to cash out a held subscription's earnings early.
  /// Throws on failure so the calling UI can surface the error message.
  Future<void> submitEarlyReleaseRequest(String subscriptionId, {String? note}) async {
    _requestingEarlyRelease = true;
    notifyListeners();
    try {
      await _service.requestEarlyRelease(subscriptionId: subscriptionId, note: note);
      await Future.wait([loadWalletOverview(), loadEarlyReleaseRequests()]);
    } finally {
      _requestingEarlyRelease = false;
      notifyListeners();
    }
  }

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
