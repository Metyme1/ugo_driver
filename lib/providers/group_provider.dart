import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../services/group_service.dart';

class GroupProvider extends ChangeNotifier {
  final GroupService _service = GroupService();

  List<GroupModel> _groups = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<GroupModel> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMyGroups() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.getMyGroups();
    _isLoading = false;
    if (response.success) {
      _groups = response.data ?? [];
    } else {
      _errorMessage = response.error?.message;
    }
    notifyListeners();
  }

  void clearError() { _errorMessage = null; notifyListeners(); }
}
