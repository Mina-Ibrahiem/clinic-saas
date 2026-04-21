import 'billing_pagination.dart';
import 'invoice.dart';

class InvoicesPage {
  const InvoicesPage({
    required this.items,
    required this.pagination,
  });

  final List<Invoice> items;
  final BillingPagination pagination;

  factory InvoicesPage.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    final pageRaw = json['pagination'];

    return InvoicesPage(
      items: itemsRaw is List
          ? itemsRaw.whereType<Map<String, dynamic>>().map(Invoice.fromJson).toList(growable: false)
          : const <Invoice>[],
      pagination: pageRaw is Map<String, dynamic>
          ? BillingPagination.fromJson(pageRaw)
          : const BillingPagination(
              currentPage: 1,
              perPage: 15,
              total: 0,
              lastPage: 1,
            ),
    );
  }
}
