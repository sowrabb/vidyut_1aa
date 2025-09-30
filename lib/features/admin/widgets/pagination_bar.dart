import 'package:flutter/material.dart';

/// Pagination bar for users list
class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalCount;
  final bool hasMore;
  final Function(int) onPageChanged;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalCount,
    required this.hasMore,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Results count
          Text(
            'Showing ${_getStartIndex()}-${_getEndIndex()} of $totalCount users',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),

          // Page info
          Text(
            'Page $currentPage',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  int _getStartIndex() {
    return (currentPage - 1) * 20 + 1;
  }

  int _getEndIndex() {
    final end = currentPage * 20;
    return end > totalCount ? totalCount : end;
  }
}
