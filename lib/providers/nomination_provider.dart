import 'package:flutter/material.dart';
import '../models/nomination_model.dart';
import '../services/nomination_service.dart';

class NominationProvider extends ChangeNotifier {
  final NominationService _service = NominationService();

  List<DriverNomination> _nominations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<DriverNomination> get nominations => _nominations;
  List<DriverNomination> get pending => _nominations.where((n) => n.isPending).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get pendingCount => pending.length;

  Future<void> loadNominations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.getMyNominations();
    _isLoading = false;
    if (response.success) {
      _nominations = response.data ?? [];
    } else {
      _errorMessage = response.error?.message;
    }
    notifyListeners();
  }

  Future<bool> respond(String groupId, String response, {required VoidCallback onSuccess}) async {
    final res = await _service.respondToNomination(groupId, response);
    if (res.success) {
      await loadNominations();
      onSuccess();
      return true;
    }
    _errorMessage = res.error?.message;
    notifyListeners();
    return false;
  }

  void clearError() { _errorMessage = null; notifyListeners(); }
}
