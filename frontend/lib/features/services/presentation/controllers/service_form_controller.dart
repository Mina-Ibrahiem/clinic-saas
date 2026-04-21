import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/networking/api_exception.dart';
import '../../data/services_repository.dart';
import '../../domain/models/service.dart';
import '../../domain/models/service_upsert_payload.dart';

final serviceFormControllerProvider = ChangeNotifierProvider.autoDispose<ServiceFormController>((ref) {
  return ServiceFormController(ref);
});

class ServiceFormController extends ChangeNotifier {
  ServiceFormController(this._ref);

  final Ref _ref;
  bool submitting = false;
  String? errorMessage;

  Future<Service?> create(ServiceUpsertPayload payload) async {
    return _run(() => _ref.read(servicesRepositoryProvider).create(payload));
  }

  Future<Service?> update({
    required int serviceId,
    required ServiceUpsertPayload payload,
  }) async {
    return _run(() => _ref.read(servicesRepositoryProvider).update(id: serviceId, payload: payload));
  }

  Future<Service?> _run(Future<Service> Function() action) async {
    submitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      return await action();
    } on ApiException catch (error) {
      errorMessage = error.message;
      return null;
    } catch (_) {
      errorMessage = 'Failed to save service.';
      return null;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }
}
