import 'branch.dart';
import 'branch_pagination.dart';

class BranchesPage {
  const BranchesPage({
    required this.items,
    required this.pagination,
  });

  final List<Branch> items;
  final BranchPagination pagination;

  factory BranchesPage.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    final paginationRaw = json['pagination'];

    final items = <Branch>[];
    if (itemsRaw is List) {
      for (final item in itemsRaw) {
        if (item is Map<String, dynamic>) {
          items.add(Branch.fromJson(item));
        }
      }
    }

    return BranchesPage(
      items: items,
      pagination: paginationRaw is Map<String, dynamic>
          ? BranchPagination.fromJson(paginationRaw)
          : const BranchPagination(
              currentPage: 1,
              perPage: 15,
              total: 0,
              lastPage: 1,
            ),
    );
  }
}
