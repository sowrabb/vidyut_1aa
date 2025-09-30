import 'package:flutter/material.dart';
import '../models/hero_section.dart';

/// Hero section card widget for displaying hero section information and actions
class HeroSectionCard extends StatelessWidget {
  final HeroSection heroSection;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleActive;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  const HeroSectionCard({
    super.key,
    required this.heroSection,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleActive,
    this.onMoveUp,
    this.onMoveDown,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Hero section image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 80,
                      height: 60,
                      color: Colors.grey[300],
                      child: _buildImagePreview(),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Hero section info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                heroSection.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            _buildStatusChip(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          heroSection.subtitle,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildPriorityChip(),
                            const SizedBox(width: 8),
                            if (heroSection.ctaText != null) ...[
                              Chip(
                                label: Text(
                                  'CTA: ${heroSection.ctaText}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                                backgroundColor: Colors.blue[100],
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              'Updated: ${_formatDate(heroSection.updatedAt)}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  Column(
                    children: [
                      PopupMenuButton<String>(
                        onSelected: (action) => _handleAction(context, action),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Edit'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'preview',
                            child: ListTile(
                              leading: Icon(Icons.photo_library_outlined),
                              title: Text('Preview'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'toggle',
                            child: ListTile(
                              leading: Icon(
                                heroSection.isActive
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              title: Text(heroSection.isActive
                                  ? 'Deactivate'
                                  : 'Activate'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),

                      // Move buttons
                      if (onMoveUp != null || onMoveDown != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (onMoveUp != null)
                              IconButton(
                                icon: const Icon(Icons.keyboard_arrow_up,
                                    size: 20),
                                onPressed: onMoveUp,
                                tooltip: 'Move up',
                              ),
                            if (onMoveDown != null)
                              IconButton(
                                icon: const Icon(Icons.keyboard_arrow_down,
                                    size: 20),
                                onPressed: onMoveDown,
                                tooltip: 'Move down',
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Chip(
      label: Text(
        heroSection.isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: heroSection.isActive ? Colors.white : Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: heroSection.isActive ? Colors.green : Colors.grey,
    );
  }

  Widget _buildPriorityChip() {
    return Chip(
      label: Text(
        'Priority: ${heroSection.priority}',
        style: const TextStyle(fontSize: 10),
      ),
      backgroundColor: Colors.orange[100],
    );
  }

  Widget _buildImagePreview() {
    final url = heroSection.imageUrl;
    final path = heroSection.imagePath;
    if (path != null && path.isNotEmpty) {
      return Image.asset(path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.image, color: Colors.grey));
    }
    if (url != null && url.isNotEmpty) {
      return Image.network(url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.image_not_supported, color: Colors.grey));
    }
    return const Icon(Icons.image, color: Colors.grey);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        onEdit?.call();
        break;
      case 'preview':
        _openPreview(context);
        break;
      case 'toggle':
        onToggleActive?.call();
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }

  void _openPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Stack(children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildImagePreview(),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ]),
      ),
    );
  }
}
