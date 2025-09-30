/// Shared ProductStatus enum for both admin and sell domains
/// Centralized to avoid duplicate/conflicting definitions.
enum ProductStatus {
  draft('draft', 'Draft'),
  pending('pending', 'Pending'),
  active('active', 'Active'),
  inactive('inactive', 'Inactive'),
  archived('archived', 'Archived');

  const ProductStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static ProductStatus fromString(String value) {
    return ProductStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ProductStatus.draft,
    );
  }
}


