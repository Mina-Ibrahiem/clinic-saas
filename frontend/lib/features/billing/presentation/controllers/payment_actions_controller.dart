import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/networking/api_exception.dart';
import '../../data/payments_repository.dart';
import '../../domain/models/payment.dart';
import '../../domain/models/payment_create_payload.dart';

final paymentActionsControllerProvider = ChangeNotifierProvider.autoDispose<PaymentActionsController>((ref) {
  return PaymentActionsController(ref);
});

class PaymentActionsController extends ChangeNotifier {
  PaymentActionsController(this._ref);

  final Ref _ref;

  bool submitting = false;
  String? errorMessage;

  Future<Payment?> createPayment(PaymentCreatePayload payload) async {
    submitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      return await _ref.read(paymentsRepositoryProvider).create(payload);
    } on ApiException catch (error) {
      errorMessage = error.message;
      return null;
    } catch (_) {
      errorMessage = 'Failed to create payment.';
      return null;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  Future<bool> deletePayment(int paymentId) async {
    submitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _ref.read(paymentsRepositoryProvider).delete(paymentId);
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Failed to delete payment.';
      return false;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }
}
