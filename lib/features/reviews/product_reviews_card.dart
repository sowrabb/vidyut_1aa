import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/tokens.dart';
import '../../../app/provider_registry.dart';
import '../sell/models.dart';

class ProductReviewsCard extends ConsumerWidget {
  final Product product;
  const ProductReviewsCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(reviewsRepositoryProvider);
    final t = Theme.of(context).textTheme;
    final summary = repo.getSummary(product.id);
    final recent = repo.listReviews(
      product.id,
      query: const ReviewListQuery(
          page: 1, pageSize: 3, sort: ReviewSort.mostRecent),
    );

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.outlineSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Expanded(
                child: Text('Ratings & Reviews', style: t.titleLarge),
              ),
              TextButton(
                onPressed: () {
                  ref.read(analyticsServiceProvider).logEvent(
                        type: 'reviews_view_all_clicked',
                        entityType: 'product',
                        entityId: product.id,
                      );
                  Navigator.of(context, rootNavigator: true).pushNamed(
                    '/reviews',
                    arguments: product.id,
                  );
                },
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _SummaryHeader(summary: summary),
          const SizedBox(height: 12),
          if (recent.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outlineSoft),
              ),
              child: const Text('No reviews yet. Be the first to review!'),
            )
          else
            Column(
              children: [
                for (final r in recent) _ReviewTile(review: r),
              ],
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () {
                ref.read(analyticsServiceProvider).logEvent(
                      type: 'review_composer_opened',
                      entityType: 'product',
                      entityId: product.id,
                    );
                Navigator.of(context, rootNavigator: true).pushNamed(
                  '/write-review',
                  arguments: product.id,
                );
              },
              icon: const Icon(Icons.rate_review_outlined),
              label: const Text('Write a review'),
            ),
          ),
        ]),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final ReviewSummary summary;
  const _SummaryHeader({required this.summary});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(summary.average.toStringAsFixed(1), style: t.headlineSmall),
        const SizedBox(width: 6),
        const Icon(Icons.star, color: Colors.amber),
        const SizedBox(width: 8),
        Text('(${summary.totalCount})'),
        const Spacer(),
        SizedBox(
          width: 160,
          child: Column(
            children: [
              for (int s = 5; s >= 1; s--)
                _bar(s, summary.countsByStar[s] ?? 0, summary.totalCount),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bar(int star, int count, int total) {
    final fraction = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        SizedBox(width: 18, child: Text('$star★')),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: Colors.amber,
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(width: 28, child: Text('$count')),
      ]),
    );
  }
}

class _ReviewTile extends ConsumerWidget {
  final Review review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(reviewsRepositoryProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Row(
            children: List.generate(
          5,
          (i) => Icon(
            i < review.rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 18,
          ),
        )),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            review.authorDisplay,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(_formatDate(review.createdAt)),
      ]),
      if ((review.title ?? '').isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(review.title!,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      const SizedBox(height: 4),
      Text(
        review.body,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
      if (review.images.isNotEmpty) ...[
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: review.images.take(3).map((img) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                img.url,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            );
          }).toList(),
        ),
      ],
      const SizedBox(height: 8),
      Row(children: [
        IconButton(
          tooltip: 'Helpful',
          onPressed: () async {
            // For demo, use a fixed user id
            const userId = 'demo-user';
            await repo.voteReviewHelpful(
              productId: review.productId,
              reviewId: review.id,
              userId: userId,
              helpful: true,
            );
          },
          icon: const Icon(Icons.thumb_up_alt_outlined),
        ),
        Text('${review.helpfulCount}')
      ]),
      const Divider(height: 24),
    ]);
  }

  String _formatDate(DateTime dt) {
    final d = dt;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
