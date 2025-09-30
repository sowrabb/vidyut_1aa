import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/layout/app_shell_scaffold.dart';
import '../../app/tokens.dart';
import '../../../app/provider_registry.dart';

class ReviewsPage extends ConsumerStatefulWidget {
  final String productId;
  const ReviewsPage({super.key, required this.productId});

  @override
  ConsumerState<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends ConsumerState<ReviewsPage> {
  final Set<int> _stars = {};
  bool _withPhotos = false;
  ReviewSort _sort = ReviewSort.mostRecent;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(analyticsServiceProvider).logEvent(
            type: 'reviews_card_viewed',
            entityType: 'product',
            entityId: widget.productId,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(reviewsRepositoryProvider);
    final t = Theme.of(context).textTheme;
    final summary = repo.getSummary(widget.productId);
    final list = repo.listReviews(
      widget.productId,
      query: ReviewListQuery(
        page: _page,
        pageSize: 20,
        starFilters: _stars,
        withPhotosOnly: _withPhotos,
        sort: _sort,
      ),
    );

    return AppShellScaffold(
      appBar: AppBar(title: const Text('All Reviews')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
                'Average ${summary.average.toStringAsFixed(1)} (${summary.totalCount})',
                style: t.titleMedium),
            const SizedBox(height: 12),
            _FiltersBar(
              stars: _stars,
              withPhotos: _withPhotos,
              sort: _sort,
              onChanged: (stars, withPhotos, sort) {
                setState(() {
                  _stars
                    ..clear()
                    ..addAll(stars);
                  _withPhotos = withPhotos;
                  _sort = sort;
                  _page = 1;
                });
              },
            ),
            const SizedBox(height: 12),
            if (list.isEmpty)
              const Center(child: Text('No reviews match your filters'))
            else
              ...list.map((r) => _ReviewRow(review: r)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed:
                      _page > 1 ? () => setState(() => _page -= 1) : null,
                  child: const Text('Previous'),
                ),
                OutlinedButton(
                  onPressed: list.length == 20
                      ? () => setState(() => _page += 1)
                      : null,
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltersBar extends StatelessWidget {
  final Set<int> stars;
  final bool withPhotos;
  final ReviewSort sort;
  final void Function(Set<int>, bool, ReviewSort) onChanged;
  const _FiltersBar({
    required this.stars,
    required this.withPhotos,
    required this.sort,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: [
      for (int s = 5; s >= 1; s--)
        FilterChip(
          label: Text('$s★'),
          selected: stars.contains(s),
          onSelected: (val) {
            final next = {...stars};
            if (val) {
              next.add(s);
            } else {
              next.remove(s);
            }
            onChanged(next, withPhotos, sort);
          },
        ),
      FilterChip(
        label: const Text('With photos'),
        selected: withPhotos,
        onSelected: (val) => onChanged(stars, val, sort),
      ),
      const SizedBox(width: 8),
      DropdownButton<ReviewSort>(
        value: sort,
        items: const [
          DropdownMenuItem(
              value: ReviewSort.mostRecent, child: Text('Most recent')),
          DropdownMenuItem(
              value: ReviewSort.mostHelpful, child: Text('Most helpful')),
          DropdownMenuItem(
              value: ReviewSort.highestRating, child: Text('Highest rating')),
          DropdownMenuItem(
              value: ReviewSort.lowestRating, child: Text('Lowest rating')),
        ],
        onChanged: (v) => onChanged(stars, withPhotos, v ?? sort),
      ),
      TextButton(
        onPressed:
            stars.isNotEmpty || withPhotos || sort != ReviewSort.mostRecent
                ? () => onChanged({}, false, ReviewSort.mostRecent)
                : null,
        child: const Text('Clear all'),
      )
    ]);
  }
}

class _ReviewRow extends ConsumerWidget {
  final Review review;
  const _ReviewRow({required this.review});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(reviewsRepositoryProvider);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.outlineSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                child: Text(review.authorDisplay,
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
            Text(
                '${review.createdAt.year}-${review.createdAt.month.toString().padLeft(2, '0')}-${review.createdAt.day.toString().padLeft(2, '0')}'),
          ]),
          if ((review.title ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(review.title!,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          const SizedBox(height: 4),
          Text(review.body),
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: review.images
                  .map((img) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(img.url,
                            width: 88, height: 88, fit: BoxFit.cover),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 8),
          Row(children: [
            IconButton(
              tooltip: 'Helpful',
              onPressed: () async {
                const userId = 'demo-user';
                await repo.voteReviewHelpful(
                  productId: review.productId,
                  reviewId: review.id,
                  userId: userId,
                  helpful: !(review.helpfulVotesByUser[userId] ?? false),
                );
              },
              icon: const Icon(Icons.thumb_up_alt_outlined),
            ),
            Text('${review.helpfulCount} found this helpful'),
            const Spacer(),
            TextButton(
                onPressed: () async {
                  await repo.reportReview(
                      productId: review.productId, reviewId: review.id);
                  ref.read(analyticsServiceProvider).logEvent(
                        type: 'review_reported',
                        entityType: 'product',
                        entityId: review.productId,
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Thanks for reporting.')));
                  }
                },
                child: const Text('Report')),
          ]),
        ]),
      ),
    );
  }
}
