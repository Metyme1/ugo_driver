class DriverReview {
  final String id;
  final int rating;
  final String? comment;
  final String parentName;
  final DateTime createdAt;

  DriverReview({
    required this.id,
    required this.rating,
    this.comment,
    required this.parentName,
    required this.createdAt,
  });

  factory DriverReview.fromJson(Map<String, dynamic> json) {
    final parent = json['parent'];
    String parentName = 'A parent';
    if (parent is Map) {
      final first = (parent['firstName'] as String?)?.trim() ?? '';
      final last = (parent['lastName'] as String?)?.trim() ?? '';
      final full = '$first $last'.trim();
      if (full.isNotEmpty) parentName = full;
    }
    return DriverReview(
      id: json['_id'] ?? json['id'] ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: (json['comment'] as String?)?.trim().isNotEmpty == true
          ? json['comment'] as String
          : null,
      parentName: parentName,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class DriverReviewsPage {
  final double averageRating;
  final int totalRatings;
  final List<DriverReview> reviews;
  final int page;
  final int pages;

  DriverReviewsPage({
    required this.averageRating,
    required this.totalRatings,
    required this.reviews,
    required this.page,
    required this.pages,
  });

  bool get hasMore => page < pages;

  factory DriverReviewsPage.empty() =>
      DriverReviewsPage(averageRating: 0, totalRatings: 0, reviews: [], page: 1, pages: 1);

  factory DriverReviewsPage.fromJson(Map<String, dynamic> json) {
    final reviewsList = (json['reviews'] as List<dynamic>? ?? [])
        .map((e) => DriverReview.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};
    return DriverReviewsPage(
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      totalRatings: (json['totalRatings'] as num?)?.toInt() ?? 0,
      reviews: reviewsList,
      page: (pagination['current'] as num?)?.toInt() ?? 1,
      pages: (pagination['pages'] as num?)?.toInt() ?? 1,
    );
  }
}
