import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/layout/app_shell_scaffold.dart';
import '../../../app/provider_registry.dart';

class ReviewComposer extends ConsumerStatefulWidget {
  final String productId;
  const ReviewComposer({super.key, required this.productId});

  @override
  ConsumerState<ReviewComposer> createState() => _ReviewComposerState();
}

class _ReviewComposerState extends ConsumerState<ReviewComposer> {
  int _rating = 0;
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final List<XFile> _picked = [];
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(reviewsRepositoryProvider);
    final maxImgs = repo.maxImagesPerReview;
    return AppShellScaffold(
      appBar: AppBar(title: const Text('Write a review')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Rating'),
            const SizedBox(height: 6),
            Row(
                children: List.generate(5, (i) {
              final idx = i + 1;
              return IconButton(
                tooltip: 'Rate $idx',
                onPressed: () => setState(() => _rating = idx),
                icon: Icon(idx <= _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber),
              );
            })),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title (optional)'),
              maxLength: 80,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bodyCtrl,
              decoration: const InputDecoration(
                labelText: 'Your review',
                border: OutlineInputBorder(),
              ),
              minLines: 5,
              maxLines: 8,
              maxLength: 2000,
            ),
            const SizedBox(height: 12),
            Row(children: [
              FilledButton.icon(
                onPressed: _picked.length >= maxImgs
                    ? null
                    : () async {
                        final picker = ImagePicker();
                        final files = await picker.pickMultiImage();
                        if (files.isNotEmpty) {
                          setState(() {
                            final remaining = maxImgs - _picked.length;
                            _picked.addAll(files.take(remaining));
                          });
                        }
                      },
                icon: const Icon(Icons.photo_library_outlined),
                label: Text('Add images (${_picked.length}/$maxImgs)'),
              ),
            ]),
            const SizedBox(height: 8),
            if (_picked.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _picked
                    .map((x) => Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              // Demo placeholder; in production, display local preview
                              'https://picsum.photos/seed/${x.name.hashCode}/160/160',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () => setState(() => _picked.remove(x)),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(2),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          )
                        ]))
                    .toList(),
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submitting
                  ? null
                  : () async {
                      if (_rating < 1 || _rating > 5) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please select a star rating')));
                        return;
                      }
                      if (_bodyCtrl.text.trim().length < 10) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Please write at least 10 characters')));
                        return;
                      }
                      setState(() => _submitting = true);
                      try {
                        // Get current user info from session
                        final session = ref.read(sessionControllerProvider);
                        final userId = session.userId ?? 'guest-${DateTime.now().millisecondsSinceEpoch}';
                        final userName = session.displayName ?? session.email ?? 'Guest User';
                        
                        final id =
                            'rev_${DateTime.now().microsecondsSinceEpoch}';
                        final images = _picked
                            .map((x) => ReviewImage(
                                url:
                                    'https://picsum.photos/seed/${x.name.hashCode}/800/600'))
                            .toList();
                        final review = Review(
                          id: id,
                          productId: widget.productId,
                          userId: userId,
                          authorDisplay: userName,
                          rating: _rating,
                          title: _titleCtrl.text.trim().isEmpty
                              ? null
                              : _titleCtrl.text.trim(),
                          body: _bodyCtrl.text.trim(),
                          images: images,
                          createdAt: DateTime.now(),
                        );
                        await ref
                            .read(reviewsRepositoryProvider)
                            .createReview(review);
                        ref.read(analyticsServiceProvider).logEvent(
                              type: 'review_submitted',
                              entityType: 'product',
                              entityId: widget.productId,
                            );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Review submitted')));
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed: $e')));
                        }
                      } finally {
                        if (mounted) setState(() => _submitting = false);
                      }
                    },
              child: Text(_submitting ? 'Submitting...' : 'Submit review'),
            )
          ],
        ),
      ),
    );
  }
}
