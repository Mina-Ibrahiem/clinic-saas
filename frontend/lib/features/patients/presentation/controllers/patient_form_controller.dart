import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/networking/api_exception.dart';
import '../../data/patients_repository.dart';
import '../../domain/models/patient.dart';
import '../../domain/models/patient_upsert_payload.dart';

final patientFormControllerProvider = ChangeNotifierProvider.autoDispose<PatientFormController>((ref) {
  return PatientFormController(ref);
});

class PatientFormController extends ChangeNotifier {
  PatientFormController(this._ref);

  final Ref _ref;

  bool submitting = false;
  String? errorMessage;

  Future<Patient?> create(PatientUpsertPayload payload) async {
    submitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      return await _ref.read(patientsRepositoryProvider).create(payload);
    } on ApiException catch (error) {
      errorMessage = error.message;
      return null;
    } catch (_) {
      errorMessage = 'Failed to create patient.';
      return null;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  Future<Patient?> update({
    required int patientId,
    required PatientUpsertPayload payload,
  }) async {
    submitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      return await _ref.read(patientsRepositoryProvider).update(
            id: patientId,
            payload: payload,
          );
    } on ApiException catch (error) {
      errorMessage = error.message;
      return null;
    } catch (_) {
      errorMessage = 'Failed to update patient.';
      return null;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }
}
