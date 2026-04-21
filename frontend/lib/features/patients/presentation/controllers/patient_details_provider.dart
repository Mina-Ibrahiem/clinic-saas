import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/networking/api_exception.dart';
import '../../data/patients_repository.dart';
import '../../domain/models/patient.dart';

final patientDetailsProvider = FutureProvider.family.autoDispose<Patient, int>((ref, patientId) async {
  try {
    return await ref.read(patientsRepositoryProvider).getById(patientId);
  } on ApiException catch (error) {
    throw Exception(error.message);
  }
});
