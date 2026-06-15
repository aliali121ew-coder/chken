import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/review.dart';
import '../../l10n/app_localizations.dart';
import '../providers/review_providers.dart';

/// A read-only row of 5 stars reflecting [rating] (0–5).
class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.rating, this.size = 16});

  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: size,
          color: Colors.amber,
        ),
      ),
    );
  }
}

/// The reviews block shown on the product detail screen: a header with a
/// "write review" action plus the list of approved reviews.
class ReviewsSection extends ConsumerWidget {
  const ReviewsSection({super.key, required this.productId, required this.storeId});

  final String productId;
  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final reviewsAsync = ref.watch(productReviewsProvider(productId));
    final hasReviewed = ref.watch(hasReviewedProvider(productId)).value ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.reviews_title, style: theme.textTheme.titleMedium),
            if (!hasReviewed)
              TextButton.icon(
                onPressed: () => _showReviewSheet(context, ref),
                icon: const Icon(Icons.rate_review_outlined, size: 18),
                label: Text(l10n.reviews_writeReview),
              ),
          ],
        ),
        const SizedBox(height: 8),
        reviewsAsync.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
          error: (error, stackTrace) => Text(l10n.common_error),
          data: (reviews) {
            if (reviews.isEmpty) {
              return Text(l10n.reviews_empty, style: theme.textTheme.bodyMedium);
            }
            return Column(
              children: [for (final review in reviews) _ReviewTile(review: review)],
            );
          },
        ),
      ],
    );
  }

  Future<void> _showReviewSheet(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final commentController = TextEditingController();
    var rating = 5;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isLoading = ref.watch(reviewControllerProvider).isLoading;
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.reviews_writeReview, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Text(l10n.reviews_yourRating),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => IconButton(
                        onPressed: () => setState(() => rating = index + 1),
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          size: 36,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(labelText: l10n.reviews_comment, border: const OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final ok = await ref.read(reviewControllerProvider.notifier).submit(
                                  productId: productId,
                                  storeId: storeId,
                                  rating: rating,
                                  comment: commentController.text.trim().isEmpty ? null : commentController.text.trim(),
                                );
                            if (ok && context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.reviews_submitted)),
                              );
                            }
                          },
                    child: isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(l10n.reviews_submit),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.customerName?.isNotEmpty ?? false ? review.customerName! : l10n.profile_guest,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              StarRating(rating: review.productRating),
            ],
          ),
          if (review.comment?.isNotEmpty ?? false) ...[
            const SizedBox(height: 4),
            Text(review.comment!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
