import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/networking/api_exception.dart';
import '../../data/invoices_repository.dart';
import '../../domain/models/billing_pagination.dart';
import '../../domain/models/invoice.dart';
import '../../domain/models/invoice_query.dart';

final invoicesListControllerProvider = ChangeNotifierProvider.autoDispose<InvoicesListController>((ref) {
  final controller = InvoicesListController(ref);
  controller.load();
  return controller;
});

class InvoicesListController extends ChangeNotifier {
  InvoicesListController(this._ref);

  final Ref _ref;

  final List<Invoice> items = [];
  BillingPagination pagination = const BillingPagination(
    currentPage: 1,
    perPage: 12,
    total: 0,
    lastPage: 1,
  );
  InvoiceQuery query = const InvoiceQuery();
  bool loading = false;
  String? errorMessage;

  Future<void> load({InvoiceQuery? nextQuery}) async {
    if (nextQuery != null) {
      query = nextQuery;
    }

    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final page = await _ref.read(invoicesRepositoryProvider).list(query);
      items
        ..clear()
        ..addAll(page.items);
      pagination = page.pagination;
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Failed to load invoices.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(nextQuery: query.copyWith(page: 1));

  Future<void> goToPage(int page) => load(nextQuery: query.copyWith(page: page));

  Future<void> applyFilters({
    String? search,
    Object? status = _sentinel,
    Object? patientId = _sentinel,
    Object? appointmentId = _sentinel,
    Object? branchId = _sentinel,
    Object? dateFrom = _sentinel,
    Object? dateTo = _sentinel,
    String? sort,
  }) {
    return load(
      nextQuery: query.copyWith(
        search: search,
        status: status,
        patientId: patientId,
        appointmentId: appointmentId,
        branchId: branchId,
        dateFrom: dateFrom,
        dateTo: dateTo,
        sort: sort,
        page: 1,
      ),
    );
  }

  Future<bool> deleteInvoice(int id) async {
    try {
      await _ref.read(invoicesRepositoryProvider).delete(id);
      await load(nextQuery: query.copyWith(page: 1));
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = 'Failed to delete invoice.';
      notifyListeners();
      return false;
    }
  }
}

const _sentinel = Object();
