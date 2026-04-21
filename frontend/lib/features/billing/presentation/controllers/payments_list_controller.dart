import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/networking/api_exception.dart';
import '../../data/payments_repository.dart';
import '../../domain/models/billing_pagination.dart';
import '../../domain/models/payment.dart';
import '../../domain/models/payment_query.dart';

final paymentsListControllerProvider = ChangeNotifierProvider.autoDispose<PaymentsListController>((ref) {
  final controller = PaymentsListController(ref);
  controller.load();
  return controller;
});

class PaymentsListController extends ChangeNotifier {
  PaymentsListController(this._ref);

  final Ref _ref;

  final List<Payment> items = [];
  BillingPagination pagination = const BillingPagination(
    currentPage: 1,
    perPage: 15,
    total: 0,
    lastPage: 1,
  );
  PaymentQuery query = const PaymentQuery();
  bool loading = false;
  String? errorMessage;

  Future<void> load({PaymentQuery? nextQuery}) async {
    if (nextQuery != null) {
      query = nextQuery;
    }

    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final page = await _ref.read(paymentsRepositoryProvider).list(query);
      items
        ..clear()
        ..addAll(page.items);
      pagination = page.pagination;
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Failed to load payments.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
