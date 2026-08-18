import 'package:flutter/material.dart';
import '../models/rating_model.dart';
import '../services/rating_service.dart';
import '../services/api_service.dart';

class RatingProvider extends ChangeNotifier {
  final RatingService _service = RatingService(ApiService());

  double _averageRating = 0;
  int _totalRatings = 0;
  final List<DriverReview> _reviews = [];

  int _page = 1;
  bool _hasMore = true;

  bool _loading = false;
  bool _loadingMore = false;
  String? _error;

  double get averageRating => _averageRating;
  int get totalRatings => _totalRatings;
  List<DriverReview> get reviews => _reviews;
  bool get hasMore => _hasMore;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  String? get error => _error;

  Future<void> loadReviews(String driverId) async {
    _loading = true;
    _error = null;
    _page = 1;
    notifyListeners();
    try {
      final result = await _service.getMyReviews(driverId: driverId, page: _page);
      _averageRating = result.averageRating;
      _totalRatings = result.totalRatings;
      _reviews
        ..clear()
        ..addAll(result.reviews);
      _hasMore = result.hasMore;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore(String driverId) async {
    if (_loadingMore || !_hasMore) return;
    _loadingMore = true;
    notifyListeners();
    try {
      final nextPage = _page + 1;
      final result = await _service.getMyReviews(driverId: driverId, page: nextPage);
      _reviews.addAll(result.reviews);
      _page = nextPage;
      _hasMore = result.hasMore;
    } catch (_) {
      // Keep already-loaded reviews; the user can retry via the load-more tap.
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }
}
