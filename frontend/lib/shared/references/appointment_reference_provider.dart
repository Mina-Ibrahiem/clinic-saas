import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../features/appointments/data/appointments_repository.dart';
import '../../features/appointments/domain/models/appointments_query.dart';
import 'reference_option.dart';

final appointmentReferenceOptionsProvider =
    FutureProvider.autoDispose.family<List<ReferenceOption>, String>((ref, search) async {
  final page = await ref.read(appointmentsRepositoryProvider).list(
        AppointmentsQuery(
          search: search.trim(),
          perPage: 25,
        ),
      );

  final df = DateFormat('yyyy-MM-dd');

  return page.items
      .map(
        (a) => ReferenceOption(
          id: a.id,
          label: '#${a.id} · ${df.format(a.appointmentDate)}',
          subtitle: a.patient?.label ?? a.doctor?.label ?? a.status,
        ),
      )
      .toList(growable: false);
});
