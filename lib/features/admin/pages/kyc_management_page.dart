import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kyc_models.dart';
import '../../../app/provider_registry.dart';
import '../widgets/bulk_actions_bar.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/error_banner.dart';

class KycManagementPage extends ConsumerStatefulWidget {
  const KycManagementPage({super.key});

  @override
  ConsumerState<KycManagementPage> createState() => _KycManagementPageState();
}

class _KycManagementPageState extends ConsumerState<KycManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  KycReviewStatus? _selectedStatus;
  bool? _showOverdue;
  bool? _showHighPriority;
  final String _sortBy = 'createdAt';
  final String _sortOrder = 'desc';
  int _currentPage = 1;
  final int _pageSize = 20;

  Set<String> _selectedReviews = {};
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Defer to next frame to avoid notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadKycReviews());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadKycReviews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final store =
          ProviderScope.containerOf(context).read(enhancedAdminStoreProvider);
      await store.loadKycReviews(
        page: _currentPage,
        limit: _pageSize,
        status: _selectedStatus,
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        overdue: _showOverdue,
        highPriority: _showHighPriority,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onFilterChanged() {
    _currentPage = 1;
    _selectedReviews.clear();
    _loadKycReviews();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadKycReviews();
  }

  void _onReviewSelected(String reviewId, bool selected) {
    setState(() {
      if (selected) {
        _selectedReviews.add(reviewId);
      } else {
        _selectedReviews.remove(reviewId);
      }
    });
  }

  void _onSelectAll() {
    final store =
        ProviderScope.containerOf(context).read(enhancedAdminStoreProvider);
    final reviews = store.kycReviews;
    setState(() {
      _selectedReviews = Set.from(reviews.map((r) => r.id));
    });
  }

  void _onDeselectAll() {
    setState(() {
      _selectedReviews.clear();
    });
  }

  Future<void> _onBulkAction(String action) async {
    if (_selectedReviews.isEmpty) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final store =
          ProviderScope.containerOf(context).read(enhancedAdminStoreProvider);
      await store.performBulkKycAction(
        reviewIds: _selectedReviews.toList(),
        action: action,
      );

      setState(() {
        _selectedReviews.clear();
      });

      _loadKycReviews();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bulk action completed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadKycReviews,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportAuditLogs,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Queue Statistics
              _buildQueueStats(),

              // Filters
              _buildFilters(),

              // Bulk Actions
              if (_selectedReviews.isNotEmpty)
                BulkActionsBar(
                  selectedCount: _selectedReviews.length,
                  totalCount: ProviderScope.containerOf(context)
                      .read(enhancedAdminStoreProvider)
                      .kycReviews
                      .length,
                  onSelectAll: _onSelectAll,
                  onDeselectAll: _onDeselectAll,
                  onBulkAction: _onBulkAction,
                ),

              // Reviews List
              Expanded(
                child: _buildReviewsList(),
              ),

              // Pagination
              Consumer(
                builder: (context, ref, child) {
                  final store = ref.watch(enhancedAdminStoreProvider);
                  return PaginationBar(
                    currentPage: _currentPage,
                    totalCount: store.kycReviewsTotalCount,
                    hasMore: store.hasMore,
                    onPageChanged: _onPageChanged,
                  );
                },
              ),
            ],
          ),

          // Loading Overlay
          if (_isLoading) const LoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildQueueStats() {
    return Consumer(
      builder: (context, ref, child) {
        final store = ref.watch(enhancedAdminStoreProvider);
        final stats = store.kycQueueStats;
        if (stats == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Queue Statistics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Pending',
                          stats.totalPending.toString(),
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'In Progress',
                          stats.totalInProgress.toString(),
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Overdue',
                          stats.overdueReviews.toString(),
                          Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'SLA Compliance',
                          '${(stats.slaCompliance * 100).toStringAsFixed(1)}%',
                          stats.slaCompliance >= 0.9
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by name, email, or ID...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _onFilterChanged(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _onFilterChanged,
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<KycReviewStatus?>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Statuses'),
                      ),
                      ...KycReviewStatus.values
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status.displayName),
                              )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                      _onFilterChanged();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<bool?>(
                    value: _showOverdue,
                    decoration: const InputDecoration(
                      labelText: 'Overdue',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(
                          value: true, child: Text('Overdue Only')),
                      DropdownMenuItem(
                          value: false, child: Text('Not Overdue')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _showOverdue = value;
                      });
                      _onFilterChanged();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<bool?>(
                    value: _showHighPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(
                          value: true, child: Text('High Priority')),
                      DropdownMenuItem(
                          value: false, child: Text('Normal Priority')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _showHighPriority = value;
                      });
                      _onFilterChanged();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList() {
    if (_error != null) {
      return ErrorBanner(
        message: _error!,
        onDismiss: () => setState(() => _error = null),
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final store = ref.watch(enhancedAdminStoreProvider);
        final reviews = store.kycReviews;

        if (reviews.isEmpty) {
          return const Center(
            child: Text('No KYC reviews found'),
          );
        }

        return ListView.builder(
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            final isSelected = _selectedReviews.contains(review.id);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: Checkbox(
                  value: isSelected,
                  onChanged: (selected) =>
                      _onReviewSelected(review.id, selected ?? false),
                ),
                title: Text(review.userName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userEmail),
                    Text('Status: ${review.status.displayName}'),
                    if (review.isOverdue)
                      const Text(
                        'OVERDUE',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${review.documents.length} docs',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (review.isHighPriority)
                      const Icon(Icons.priority_high,
                          color: Colors.red, size: 16),
                  ],
                ),
                onTap: () => _openReviewDetails(review),
              ),
            );
          },
        );
      },
    );
  }

  void _openReviewDetails(KycReview review) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KycReviewDetailsPage(reviewId: review.id),
      ),
    );
  }

  void _exportAuditLogs() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final store =
          ProviderScope.containerOf(context).read(enhancedAdminStoreProvider);
      await store.exportKycAuditLogs();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audit logs exported successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class KycReviewDetailsPage extends StatefulWidget {
  final String reviewId;

  const KycReviewDetailsPage({super.key, required this.reviewId});

  @override
  State<KycReviewDetailsPage> createState() => _KycReviewDetailsPageState();
}

class _KycReviewDetailsPageState extends State<KycReviewDetailsPage> {
  KycReview? _review;
  bool _isLoading = true;
  String? _error;
  final TextEditingController _commentsController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReview();
  }

  @override
  void dispose() {
    _commentsController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadReview() async {
    try {
      final store =
          ProviderScope.containerOf(context).read(enhancedAdminStoreProvider);
      _review = await store.getKycReview(widget.reviewId);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateReviewStatus(KycReviewStatus status) async {
    try {
      final store =
          ProviderScope.containerOf(context).read(enhancedAdminStoreProvider);
      await store.updateKycReview(
        widget.reviewId,
        UpdateKycReviewRequest(
          status: status,
          reviewComments: _commentsController.text.trim().isEmpty
              ? null
              : _commentsController.text.trim(),
          rejectionReason: status == KycReviewStatus.rejected &&
                  _reasonController.text.trim().isNotEmpty
              ? _reasonController.text.trim()
              : null,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Review ${status.displayName.toLowerCase()} successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Review Details'),
        actions: [
          if (_review != null && _review!.requiresAttention)
            PopupMenuButton<String>(
              onSelected: (action) {
                switch (action) {
                  case 'approve':
                    _updateReviewStatus(KycReviewStatus.approved);
                    break;
                  case 'reject':
                    _showRejectDialog();
                    break;
                  case 'request_info':
                    _updateReviewStatus(KycReviewStatus.requiresAdditionalInfo);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'approve',
                  child: Text('Approve'),
                ),
                const PopupMenuItem(
                  value: 'reject',
                  child: Text('Reject'),
                ),
                const PopupMenuItem(
                  value: 'request_info',
                  child: Text('Request Additional Info'),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorBanner(
                  message: _error!,
                  onDismiss: () => setState(() => _error = null),
                )
              : _review == null
                  ? const Center(child: Text('Review not found'))
                  : _buildReviewDetails(),
    );
  }

  Widget _buildReviewDetails() {
    final review = _review!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Review Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.userName,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(review.userEmail),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(review.status)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              review.status.displayName,
                              style: TextStyle(
                                color: _getStatusColor(review.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (review.isOverdue)
                            const Text(
                              'OVERDUE',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                            'Created', _formatDate(review.createdAt)),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                            'Updated', _formatDate(review.updatedAt)),
                      ),
                    ],
                  ),
                  if (review.slaDeadline != null)
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                              'SLA Deadline', _formatDate(review.slaDeadline!)),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                              'Priority', '${review.priority}/10'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Documents
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Documents',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...review.documents.map((doc) => _buildDocumentCard(doc)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Review Comments
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Review Comments',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _commentsController,
                    decoration: const InputDecoration(
                      hintText: 'Add review comments...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),

          if (review.rejectionReason != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rejection Reason',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(review.rejectionReason!),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Action Buttons
          if (review.requiresAttention)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _updateReviewStatus(KycReviewStatus.approved),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showRejectDialog,
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDocumentCard(KycDocument document) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getDocumentIcon(document.type),
          color: _getDocumentStatusColor(document.status),
        ),
        title: Text(document.fileName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${document.type.displayName}'),
            Text('Status: ${document.status.displayName}'),
            if (document.rejectionReason != null)
              Text(
                'Reason: ${document.rejectionReason}',
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${(document.fileSize / 1024).toStringAsFixed(1)} KB'),
            Text(_formatDate(document.uploadedAt)),
          ],
        ),
        onTap: () => _viewDocument(document),
      ),
    );
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject KYC Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                hintText: 'Rejection reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateReviewStatus(KycReviewStatus.rejected);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _viewDocument(KycDocument document) {
    // Pending: Implement document viewer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing document: ${document.fileName}')),
    );
  }

  Color _getStatusColor(KycReviewStatus status) {
    switch (status) {
      case KycReviewStatus.pending:
        return Colors.orange;
      case KycReviewStatus.inProgress:
        return Colors.blue;
      case KycReviewStatus.approved:
        return Colors.green;
      case KycReviewStatus.rejected:
        return Colors.red;
      case KycReviewStatus.requiresAdditionalInfo:
        return Colors.purple;
      case KycReviewStatus.onHold:
        return Colors.grey;
    }
  }

  Color _getDocumentStatusColor(KycDocumentStatus status) {
    switch (status) {
      case KycDocumentStatus.pending:
        return Colors.orange;
      case KycDocumentStatus.underReview:
        return Colors.blue;
      case KycDocumentStatus.approved:
        return Colors.green;
      case KycDocumentStatus.rejected:
        return Colors.red;
      case KycDocumentStatus.expired:
        return Colors.grey;
      case KycDocumentStatus.requiresResubmission:
        return Colors.purple;
    }
  }

  IconData _getDocumentIcon(KycDocumentType type) {
    switch (type) {
      case KycDocumentType.panCard:
      case KycDocumentType.aadharCard:
      case KycDocumentType.passport:
      case KycDocumentType.drivingLicense:
      case KycDocumentType.voterId:
        return Icons.credit_card;
      case KycDocumentType.bankStatement:
        return Icons.account_balance;
      case KycDocumentType.utilityBill:
        return Icons.receipt;
      case KycDocumentType.businessLicense:
      case KycDocumentType.gstCertificate:
      case KycDocumentType.companyIncorporation:
        return Icons.business;
      case KycDocumentType.other:
        return Icons.description;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
