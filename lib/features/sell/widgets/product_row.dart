import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/tokens.dart';
import '../../../app/provider_registry.dart';
import '../models.dart';

class ProductRow extends ConsumerWidget {
  final Product product;
  final VoidCallback? onEdit;
  final VoidCallback? onView;
  final VoidCallback? onDelete;
  final bool selectable;
  final bool selected;
  final ValueChanged<bool?>? onSelectedChanged;

  const ProductRow({
    super.key,
    required this.product,
    this.onEdit,
    this.onView,
    this.onDelete,
    this.selectable = false,
    this.selected = false,
    this.onSelectedChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: AppElevation.level1,
      shadowColor: AppColors.shadowSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.outlineSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (selectable)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Checkbox(
                  value: selected,
                  onChanged: onSelectedChanged,
                ),
              ),
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.images.isNotEmpty ? product.images.first : '',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 60,
                  height: 60,
                  color: AppColors.thumbBg,
                  child: const Icon(Icons.broken_image_outlined,
                      color: AppColors.textSecondary),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(status: product.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.brand,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${product.price.toStringAsFixed(0)} • MOQ: ${product.moq}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),

            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onView,
                  icon: const Icon(Ionicons.eye_outline, size: 20),
                  tooltip: 'View',
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Ionicons.create_outline, size: 20),
                  tooltip: 'Edit',
                ),
                PopupMenuButton<_RowAction>(
                  tooltip: 'More',
                  onSelected: (action) async {
                    final store = ref.read(sellerStoreProvider);
                    switch (action) {
                      case _RowAction.duplicate:
                        final dup = store.duplicateProduct(product.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(dup != null
                                  ? 'Product duplicated'
                                  : 'Failed to duplicate')),
                        );
                        break;
                      case _RowAction.setActive:
                        store.updateProduct(
                            product.copyWith(status: ProductStatus.active));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Status set to Active')),
                        );
                        break;
                      case _RowAction.setInactive:
                        store.updateProduct(
                            product.copyWith(status: ProductStatus.inactive));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Status set to Inactive')),
                        );
                        break;
                      case _RowAction.setPending:
                        store.updateProduct(
                            product.copyWith(status: ProductStatus.pending));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Status set to Pending Approval')),
                        );
                        break;
                      case _RowAction.setDraft:
                        store.updateProduct(
                            product.copyWith(status: ProductStatus.draft));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Status set to Draft')),
                        );
                        break;
                      case _RowAction.setArchived:
                        store.updateProduct(
                            product.copyWith(status: ProductStatus.archived));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Status set to Archived')),
                        );
                        break;
                      case _RowAction.softDelete:
                        store.softDeleteProduct(product.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Product archived')),
                        );
                        break;
                      case _RowAction.hardDelete:
                        onDelete?.call();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Product deleted')),
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                        value: _RowAction.duplicate, child: Text('Duplicate')),
                    PopupMenuDivider(),
                    PopupMenuItem(
                        value: _RowAction.setActive, child: Text('Set Active')),
                    PopupMenuItem(
                        value: _RowAction.setInactive,
                        child: Text('Set Inactive')),
                    PopupMenuItem(
                        value: _RowAction.setPending,
                        child: Text('Set Pending')),
                    PopupMenuItem(
                        value: _RowAction.setDraft, child: Text('Set Draft')),
                    PopupMenuItem(
                        value: _RowAction.setArchived,
                        child: Text('Set Archived')),
                    PopupMenuDivider(),
                    PopupMenuItem(
                        value: _RowAction.softDelete, child: Text('Archive')),
                    PopupMenuItem(
                        value: _RowAction.hardDelete,
                        child: Text('Delete Permanently')),
                  ],
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _RowAction {
  duplicate,
  setActive,
  setInactive,
  setPending,
  setDraft,
  setArchived,
  softDelete,
  hardDelete,
}

class _StatusChip extends StatelessWidget {
  final ProductStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ProductStatus.active => ('Active', Colors.green.shade600),
      ProductStatus.inactive => ('Inactive', Colors.orange.shade700),
      ProductStatus.pending => ('Pending', Colors.blue.shade700),
      ProductStatus.draft => ('Draft', Colors.grey.shade700),
      ProductStatus.archived => ('Archived', Colors.red.shade700),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
