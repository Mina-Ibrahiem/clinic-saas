import 'billing_pagination.dart';
import 'payment.dart';

class PaymentsPage {
  const PaymentsPage({
    required this.items,
    required this.pagination,
  });

  final List<Payment> items;
  final BillingPagination pagination;

  factory PaymentsPage.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    final pageRaw = json['pagination'];

    return PaymentsPage(
      items: itemsRaw is List
          ? itemsRaw.whereType<Map<String, dynamic>>().map(Payment.fromJson).toList(growable: false)
          : const <Payment>[],
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
