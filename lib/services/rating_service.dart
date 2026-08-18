import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/rating_model.dart';

class RatingService {
  final ApiService _api;
  RatingService(this._api);

  Future<DriverReviewsPage> getMyReviews({required String driverId, int page = 1}) async {
    try {
      final response = await _api.get(
        '/drivers/$driverId/reviews',
        queryParameters: {'page': page, 'limit': 10},
      );
      final data = response.data;
      if (data['success'] == true) {
        return DriverReviewsPage.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception(data['error']?['message'] ?? 'Failed to fetch reviews');
    } on DioException catch (e) {
      throw Exception(_api.handleError(e));
    }
  }
}
