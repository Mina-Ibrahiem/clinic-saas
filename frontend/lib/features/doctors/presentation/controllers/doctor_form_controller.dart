import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/networking/api_exception.dart';
import '../../data/doctors_repository.dart';
import '../../domain/models/doctor.dart';
import '../../domain/models/doctor_upsert_payload.dart';

final doctorFormControllerProvider = ChangeNotifierProvider.autoDispose<DoctorFormController>((ref) {
  return DoctorFormController(ref);
});

class DoctorFormController extends ChangeNotifier {
  DoctorFormController(this._ref);

  final Ref _ref;
  bool submitting = false;
  String? errorMessage;

  Future<Doctor?> create(DoctorUpsertPayload payload) async {
    return _run(() => _ref.read(doctorsRepositoryProvider).create(payload));
  }

  Future<Doctor?> update({
    required int doctorId,
    required DoctorUpsertPayload payload,
  }) async {
    return _run(() => _ref.read(doctorsRepositoryProvider).update(id: doctorId, payload: payload));
  }

  Future<Doctor?> _run(Future<Doctor> Function() action) async {
    submitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      return await action();
    } on ApiException catch (error) {
      errorMessage = error.message;
      return null;
    } catch (_) {
      errorMessage = 'Failed to save doctor.';
      return null;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }
}
