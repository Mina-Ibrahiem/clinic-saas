import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/networking/api_exception.dart';
import '../../data/appointments_repository.dart';
import '../../domain/models/appointment.dart';
import '../../domain/models/appointment_upsert_payload.dart';

final appointmentFormControllerProvider = ChangeNotifierProvider.autoDispose<AppointmentFormController>((ref) {
  return AppointmentFormController(ref);
});

class AppointmentFormController extends ChangeNotifier {
  AppointmentFormController(this._ref);

  final Ref _ref;

  bool submitting = false;
  String? errorMessage;

  Future<Appointment?> create(AppointmentUpsertPayload payload) async {
    return _run(() => _ref.read(appointmentsRepositoryProvider).create(payload));
  }

  Future<Appointment?> update({
    required int appointmentId,
    required AppointmentUpsertPayload payload,
  }) async {
    return _run(() {
      return _ref.read(appointmentsRepositoryProvider).update(
            id: appointmentId,
            payload: payload,
          );
    });
  }

  Future<Appointment?> _run(Future<Appointment> Function() action) async {
    submitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      return await action();
    } on ApiException catch (error) {
      errorMessage = error.message;
      return null;
    } catch (_) {
      errorMessage = 'Failed to save appointment.';
      return null;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }
}
