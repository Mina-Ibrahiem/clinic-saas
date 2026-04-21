import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/networking/api_exception.dart';
import '../../data/invoices_repository.dart';
import '../../domain/models/invoice.dart';
import '../../domain/models/invoice_upsert_payload.dart';

final invoiceFormControllerProvider = ChangeNotifierProvider.autoDispose<InvoiceFormController>((ref) {
  return InvoiceFormController(ref);
});

class InvoiceFormController extends ChangeNotifier {
  InvoiceFormController(this._ref);

  final Ref _ref;

  bool submitting = false;
  String? errorMessage;

  Future<Invoice?> create(InvoiceUpsertPayload payload) async {
    return _run(() => _ref.read(invoicesRepositoryProvider).create(payload));
  }

  Future<Invoice?> update({
    required int invoiceId,
    required InvoiceUpsertPayload payload,
  }) async {
    return _run(() {
      return _ref.read(invoicesRepositoryProvider).update(
            id: invoiceId,
            payload: payload,
          );
    });
  }

  Future<Invoice?> _run(Future<Invoice> Function() action) async {
    submitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      return await action();
    } on ApiException catch (error) {
      errorMessage = error.message;
      return null;
    } catch (_) {
      errorMessage = 'Failed to save invoice.';
      return null;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }
}
