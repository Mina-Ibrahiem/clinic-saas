import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/glass_panel.dart';
import '../domain/models/appointment.dart';
import '../domain/models/appointment_reference.dart';
import 'appointment_form_page.dart';
import 'controllers/appointment_details_provider.dart';

class AppointmentDetailsPage extends ConsumerWidget {
  const AppointmentDetailsPage({
    super.key,
    required this.appointmentId,
  });

  final int appointmentId;

  static String pathFor(int id) => '/appointments/$id';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentState = ref.watch(appointmentDetailsProvider(appointmentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit',
            onPressed: () => context.push(AppointmentFormPage.editPathFor(appointmentId)),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: appointmentState.when(
          data: (appointment) => _DetailsCard(appointment: appointment),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Failed to load appointment.\n$error'),
          ),
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('yyyy-MM-dd');
    final rows = <({String title, String value})>[
      (title: 'Appointment Date', value: format.format(appointment.appointmentDate)),
      (title: 'Start Time', value: appointment.startTime),
      (title: 'End Time', value: appointment.endTime),
      (title: 'Status', value: _prettyStatus(appointment.status)),
      (title: 'Patient', value: _labelOrId(appointment.patient, appointment.patientId, 'Patient')),
      (title: 'Doctor', value: _labelOrId(appointment.doctor, appointment.doctorId, 'Doctor')),
      (title: 'Service', value: _labelOrId(appointment.service, appointment.serviceId, 'Service')),
      (title: 'Branch', value: _labelOrId(appointment.branch, appointment.branchId, 'Branch')),
      (title: 'Notes', value: appointment.notes?.trim().isNotEmpty == true ? appointment.notes!.trim() : '-'),
    ];

    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 860;
            if (!wide) {
              return Column(
                children: [
                  for (final row in rows)
                    _DetailRow(
                      title: row.title,
                      value: row.value,
                    ),
                ],
              );
            }

            final mid = (rows.length / 2).ceil();
            final left = rows.take(mid).toList();
            final right = rows.skip(mid).toList();

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      for (final row in left)
                        _DetailRow(
                          title: row.title,
                          value: row.value,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      for (final row in right)
                        _DetailRow(
                          title: row.title,
                          value: row.value,
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

String _labelOrId(AppointmentReference? reference, int? id, String entity) {
  if (reference != null) {
    if (reference.code != null && reference.code!.isNotEmpty) {
      return '${reference.label} (${reference.code})';
    }
    return reference.label;
  }
  if (id != null) {
    return '$entity #$id';
  }
  return '-';
}

String _prettyStatus(String value) {
  return value
      .split('_')
      .map((part) => part.isEmpty ? part : part[0].toUpperCase() + part.substring(1))
      .join(' ');
}
