import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/rating_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/rating_provider.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/loading_widget.dart';

const _monthNames = [
  '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _fmtDate(DateTime d) => '${_monthNames[d.month]} ${d.day}, ${d.year}';

class MyRatingsScreen extends StatefulWidget {
  const MyRatingsScreen({super.key});

  @override
  State<MyRatingsScreen> createState() => _MyRatingsScreenState();
}

class _MyRatingsScreenState extends State<MyRatingsScreen> {
  final _scrollController = ScrollController();

  String? get _driverId => context.read<AuthProvider>().user?.id;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = _driverId;
      if (id != null) context.read<RatingProvider>().loadReviews(id);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final id = _driverId;
      if (id != null) context.read<RatingProvider>().loadMore(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final provider = context.watch<RatingProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.ratingsAndReviews,
            style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: AppColors.textPrimary, fontSize: 18)),
      ),
      body: provider.loading
          ? const LoadingWidget()
          : provider.error != null
              ? AppErrorWidget(
                  message: provider.error!,
                  onRetry: () {
                    final id = _driverId;
                    if (id != null) context.read<RatingProvider>().loadReviews(id);
                  },
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    final id = _driverId;
                    if (id != null) await context.read<RatingProvider>().loadReviews(id);
                  },
                  child: ListView(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(context.hPad, context.vPad, context.hPad, 24),
                    children: [
                      _SummaryCard(
                        average: provider.averageRating,
                        total: provider.totalRatings,
                        l: l,
                      ),
                      SizedBox(height: context.gap * 1.5),
                      if (provider.reviews.isEmpty)
                        _EmptyState(l: l)
                      else ...[
                        for (final review in provider.reviews) ...[
                          _ReviewCard(review: review),
                          SizedBox(height: context.gap),
                        ],
                        if (provider.loadingMore)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
    );
  }
}

// ─── Summary card ────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final double average;
  final int total;
  final AppLocalizations l;
  const _SummaryCard({required this.average, required this.total, required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Text(average.toStringAsFixed(1),
              style: GoogleFonts.outfit(fontSize: 44, fontWeight: FontWeight.w600, color: Colors.white, height: 1)),
          const SizedBox(height: 10),
          _StarRow(rating: average, size: 22),
          const SizedBox(height: 10),
          Text(
            total == 0 ? l.noReviewsYet : l.reviewsCount(total),
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final double rating;
  final double size;
  const _StarRow({required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = rating >= i + 1;
        final half = !filled && rating > i && rating < i + 1;
        return Icon(
          half ? Icons.star_half_rounded : (filled ? Icons.star_rounded : Icons.star_border_rounded),
          size: size,
          color: const Color(0xFFFFC107),
        );
      }),
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final AppLocalizations l;
  const _EmptyState({required this.l});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: const Icon(Icons.star_border_rounded, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(l.noReviewsYet,
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(l.noReviewsYetMsg,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}

// ─── Review card ─────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final DriverReview review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                child: Text(
                  review.parentName.isNotEmpty ? review.parentName[0].toUpperCase() : '?',
                  style: GoogleFonts.outfit(color: AppColors.accentDark, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.parentName,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(_fmtDate(review.createdAt),
                        style: GoogleFonts.outfit(color: AppColors.textHint, fontSize: 11)),
                  ],
                ),
              ),
              _StarRow(rating: review.rating.toDouble(), size: 14),
            ],
          ),
          if (review.comment != null) ...[
            const SizedBox(height: 12),
            Text(review.comment!,
                style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
          ],
        ],
      ),
    );
  }
}
