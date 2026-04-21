import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/networking/api_exception.dart';
import '../../data/appointments_repository.dart';
import '../../domain/models/appointment.dart';

final appointmentDetailsProvider = FutureProvider.autoDispose.family<Appointment, int>((ref, id) async {
  try {
    return await ref.read(appointmentsRepositoryProvider).getById(id);
  } on ApiException {
    rethrow;
  }
});
