import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/glass_panel.dart';
import '../domain/models/patient.dart';
import 'controllers/patient_details_provider.dart';
import 'patient_form_page.dart';

class PatientDetailsPage extends ConsumerWidget {
  const PatientDetailsPage({
    super.key,
    required this.patientId,
  });

  final int patientId;

  static String pathFor(int id) => '/patients/$id';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientState = ref.watch(patientDetailsProvider(patientId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit',
            onPressed: () => context.push(PatientFormPage.editPathFor(patientId)),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: patientState.when(
          data: (patient) => _DetailsCard(patient: patient),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Failed to load patient.\n$error'),
          ),
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('yyyy-MM-dd');
    final rows = <({String title, String value})>[
      (title: 'Patient Code', value: patient.patientCode),
      (title: 'Full Name', value: patient.fullName),
      (title: 'Phone', value: patient.phone),
      (title: 'Email', value: patient.email ?? '-'),
      (title: 'Gender', value: _capitalize(patient.gender)),
      (title: 'Date of Birth', value: patient.dateOfBirth != null ? format.format(patient.dateOfBirth!) : '-'),
      (title: 'Status', value: _capitalize(patient.status)),
      (title: 'Branch', value: patient.branchName ?? (patient.branchId?.toString() ?? '-')),
      (title: 'Tenant', value: patient.tenantName ?? (patient.tenantId?.toString() ?? '-')),
      (title: 'Address', value: patient.address ?? '-'),
      (title: 'Emergency Contact', value: patient.emergencyContactName ?? '-'),
      (title: 'Emergency Phone', value: patient.emergencyContactPhone ?? '-'),
      (title: 'Blood Group', value: patient.bloodGroup ?? '-'),
      (title: 'Allergies', value: patient.allergies ?? '-'),
      (title: 'Medical Notes', value: patient.medicalNotes ?? '-'),
      (title: 'Appointments', value: (patient.appointmentsCount ?? 0).toString()),
      (title: 'Invoices', value: (patient.invoicesCount ?? 0).toString()),
      (title: 'Notes', value: (patient.notesCount ?? 0).toString()),
    ];

    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 900;
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

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}
