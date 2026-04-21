import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/doctors_repository.dart';
import '../../domain/models/doctor.dart';

final doctorDetailsProvider = FutureProvider.autoDispose.family<Doctor, int>((ref, doctorId) async {
  return ref.read(doctorsRepositoryProvider).getById(doctorId);
});
