import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/doctors/data/doctors_repository.dart';
import '../../features/doctors/domain/models/doctors_query.dart';
import 'reference_option.dart';

final doctorReferenceOptionsProvider =
    FutureProvider.autoDispose.family<List<ReferenceOption>, String>((ref, search) async {
  final page = await ref.read(doctorsRepositoryProvider).list(
        DoctorsQuery(
          search: search.trim(),
          status: 'active',
          perPage: 30,
        ),
      );

  return page.items
      .map(
        (doctor) => ReferenceOption(
          id: doctor.id,
          label: doctor.fullName,
          subtitle: [doctor.specialization, doctor.doctorCode]
              .whereType<String>()
              .where((value) => value.isNotEmpty)
              .join(' • '),
        ),
      )
      .toList(growable: false);
});
