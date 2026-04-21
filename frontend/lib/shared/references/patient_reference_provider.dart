import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/patients/data/patients_repository.dart';
import '../../features/patients/domain/models/patients_query.dart';
import 'reference_option.dart';

final patientReferenceOptionsProvider =
    FutureProvider.autoDispose.family<List<ReferenceOption>, String>((ref, search) async {
  final page = await ref.read(patientsRepositoryProvider).list(
        PatientsQuery(
          search: search.trim(),
          perPage: 30,
        ),
      );

  return page.items
      .map(
        (p) => ReferenceOption(
          id: p.id,
          label: p.fullName,
          subtitle: [p.patientCode, p.phone].where((s) => s.isNotEmpty).join(' · '),
        ),
      )
      .toList(growable: false);
});
