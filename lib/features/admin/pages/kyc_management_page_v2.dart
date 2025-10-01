import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kyc_models.dart';
import '../../../app/provider_registry.dart';
import '../../../state/admin/kyc_providers.dart';
import '../../../state/core/repository_providers.dart';

/// KYC Management Page - Repository-backed version
/// 
/// Replaces legacy EnhancedAdminStore with direct Firestore providers.
class KycManagementPageV2 extends ConsumerStatefulWidget {
  const KycManagementPageV2({super.key});

  @override
  ConsumerState<KycManagementPageV2> createState() => _KycManagementPageV2State();
}

class _KycManagementPageV2State extends ConsumerState<KycManagementPageV2> {
  String _statusFilter = 'pending';
  String _searchQuery = '';
  Set<String> _selectedSubmissions = {};

  @override
  Widget build(BuildContext context) {
    // Check admin permissions
    final rbac = ref.watch(rbacProvider);
    if (!rbac.can('admin:kyc:view')) {
      return const Scaffold(
        body: Center(
          child: Text('Insufficient permissions to view KYC submissions'),
        ),
      );
    }

    // Watch KYC submissions stream
    final submissionsAsync = ref.watch(kycSubmissionsByStatusProvider(
      _statusFilter == 'all' ? null : _statusFilter,
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Management'),
        actions: [
          // Pending count badge
          Consumer(
            builder: (context, ref, child) {
              final pendingCountAsync = ref.watch(kycPendingCountProvider);
              return pendingCountAsync.when(
                data: (count) => count > 0
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Chip(
                          label: Text('$count pending'),
                          backgroundColor: Colors.orange,
                        ),
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(kycSubmissionsByStatusProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          _buildFilters(),
          
          // Bulk actions
          if (_selectedSubmissions.isNotEmpty) _buildBulkActions(),

          // Submissions list
          Expanded(
            child: submissionsAsync.when(
              data: (submissions) => _buildSubmissionsList(submissions),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error loading KYC submissions: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(kycSubmissionsByStatusProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Status filter
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _statusFilter,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                DropdownMenuItem(value: 'approved', child: Text('Approved')),
                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _statusFilter = value;
                    _selectedSubmissions.clear();
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          // Search
          Expanded(
            flex: 2,
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActions() {
    final rbac = ref.watch(rbacProvider);
    final canApprove = rbac.can('admin:kyc:approve');
    final canReject = rbac.can('admin:kyc:reject');

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          Text('${_selectedSubmissions.length} selected'),
          const Spacer(),
          if (canApprove)
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Approve Selected'),
              onPressed: () => _performBulkAction('approve'),
            ),
          const SizedBox(width: 8),
          if (canReject)
            ElevatedButton.icon(
              icon: const Icon(Icons.close),
              label: const Text('Reject Selected'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => _performBulkAction('reject'),
            ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedSubmissions.clear();
              });
            },
            child: const Text('Clear Selection'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionsList(List<KycSubmission> submissions) {
    // Filter by search query
    final filteredSubmissions = _searchQuery.isEmpty
        ? submissions
        : submissions.where((s) =>
            s.userId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (s.businessName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)).toList();

    if (filteredSubmissions.isEmpty) {
      return const Center(
        child: Text('No KYC submissions found'),
      );
    }

    return ListView.builder(
      itemCount: filteredSubmissions.length,
      itemBuilder: (context, index) {
        final submission = filteredSubmissions[index];
        final isSelected = _selectedSubmissions.contains(submission.id);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Checkbox(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedSubmissions.add(submission.id);
                  } else {
                    _selectedSubmissions.remove(submission.id);
                  }
                });
              },
            ),
            title: Text(submission.businessName ?? submission.userId),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User: ${submission.userId}'),
                Text('Status: ${submission.status.value}'),
                Text('Submitted: ${_formatDate(submission.createdAt)}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusBadge(submission.status),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () => _viewSubmissionDetail(submission),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(KycDocumentStatus status) {
    Color color;
    switch (status) {
      case KycDocumentStatus.pending:
        color = Colors.orange;
        break;
      case KycDocumentStatus.underReview:
        color = Colors.blue;
        break;
      case KycDocumentStatus.approved:
        color = Colors.green;
        break;
      case KycDocumentStatus.rejected:
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  void _viewSubmissionDetail(KycSubmission submission) {
    // Navigate to detail page or show dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('KYC Submission: ${submission.businessName ?? submission.userId}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('User ID: ${submission.userId}'),
              Text('Business Name: ${submission.businessName ?? 'N/A'}'),
              Text('Status: ${submission.status.displayName}'),
              Text('Submitted: ${_formatDate(submission.createdAt)}'),
              if (submission.reviewedAt != null)
                Text('Reviewed: ${_formatDate(submission.reviewedAt!)}'),
              if (submission.reviewedBy != null)
                Text('Reviewed by: ${submission.reviewedBy}'),
              if (submission.notes != null)
                Text('Notes: ${submission.notes}'),
            ],
          ),
        ),
        actions: [
          if (ref.read(rbacProvider).can('admin:kyc:approve'))
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _approveSubmission(submission.id);
              },
              child: const Text('Approve'),
            ),
          if (ref.read(rbacProvider).can('admin:kyc:reject'))
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _rejectSubmission(submission.id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Reject'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _approveSubmission(String submissionId) async {
    try {
      final repo = ref.read(firestoreRepositoryServiceProvider);
      await repo.updateDocument('kyc_submissions/$submissionId', {
        'status': 'approved',
        'reviewed_at': DateTime.now(),
        'reviewed_by': ref.read(firebaseCurrentUserIdProvider),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('KYC submission approved')),
        );
      }
      
      // Refresh the list
      ref.invalidate(kycSubmissionsByStatusProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving submission: $e')),
        );
      }
    }
  }

  Future<void> _rejectSubmission(String submissionId) async {
    try {
      final repo = ref.read(firestoreRepositoryServiceProvider);
      await repo.updateDocument('kyc_submissions/$submissionId', {
        'status': 'rejected',
        'reviewed_at': DateTime.now(),
        'reviewed_by': ref.read(firebaseCurrentUserIdProvider),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('KYC submission rejected')),
        );
      }
      
      // Refresh the list
      ref.invalidate(kycSubmissionsByStatusProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting submission: $e')),
        );
      }
    }
  }

  Future<void> _performBulkAction(String action) async {
    try {
      final repo = ref.read(firestoreRepositoryServiceProvider);
      final currentUserId = ref.read(firebaseCurrentUserIdProvider);
      
      for (final submissionId in _selectedSubmissions) {
        await repo.updateDocument('kyc_submissions/$submissionId', {
          'status': action == 'approve' ? 'approved' : 'rejected',
          'reviewed_at': DateTime.now(),
          'reviewed_by': currentUserId,
        });
      }
      
      setState(() {
        _selectedSubmissions.clear();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bulk $action completed successfully')),
        );
      }
      
      // Refresh the list
      ref.invalidate(kycSubmissionsByStatusProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error performing bulk action: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}




