import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../domain/models/report_models.dart';
import 'controllers/reports_providers.dart';
import 'report_routes.dart';
import 'widgets/report_common_widgets.dart';
import 'widgets/reports_page_scaffold.dart';

class PatientsReportPage extends ConsumerStatefulWidget {
  const PatientsReportPage({super.key});

  static const routePath = ReportRoutes.patients;

  @override
  ConsumerState<PatientsReportPage> createState() => _PatientsReportPageState();
}

class _PatientsReportPageState extends ConsumerState<PatientsReportPage> {
  Future<void> _pickRange() async {
    final query = ref.read(patientsReportQueryProvider);
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: query.dateFrom != null && query.dateTo != null
          ? DateTimeRange(start: query.dateFrom!, end: query.dateTo!)
          : null,
    );
    if (range == null) return;
    ref.read(patientsReportQueryProvider.notifier).state = query.copyWith(
          dateFrom: range.start,
          dateTo: range.end,
          page: 1,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(patientsReportProvider);
    return ReportsPageScaffold(
      title: l10n.reportTitlePatients,
      activeType: ReportType.patients,
      child: Column(
        children: [
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _pickRange,
                icon: const Icon(Icons.date_range_outlined),
                label: Text(l10n.commonDateRange),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: l10n.commonRefresh,
                onPressed: () => ref.invalidate(patientsReportProvider),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ReportErrorState(
                message: '${l10n.commonError}: $error',
                onRetry: () => ref.invalidate(patientsReportProvider),
              ),
              data: (report) => _PatientsBody(report: report),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientsBody extends ConsumerWidget {
  const _PatientsBody({required this.report});
  final PatientsReportResponse report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (report.items.isEmpty) {
      return const ReportEmptyState(icon: Icons.people_alt_outlined, message: 'No patients report data.');
    }
    final summary = report.summary;
    final genders = (summary['gender_breakdown'] as Map<String, dynamic>?) ?? const {};

    return GlassPanel(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _summaryCard('New Patients', (summary['new_patients_count'] ?? 0).toString()),
                _summaryCard('Active', (summary['active_count'] ?? 0).toString()),
                _summaryCard('Inactive', (summary['inactive_count'] ?? 0).toString()),
                _summaryCard(
                  'Gender Breakdown',
                  genders.entries.map((entry) => '${entry.key}:${entry.value}').join('  '),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Patient Code')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Gender')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Created')),
                ],
                rows: [
                  for (final item in report.items)
                    DataRow(
                      cells: [
                        DataCell(Text(item.patientCode ?? '-')),
                        DataCell(Text(item.fullName)),
                        DataCell(Text(item.gender ?? '-')),
                        DataCell(Text(item.phone ?? '-')),
                        DataCell(Text(item.status)),
                        DataCell(Text(item.createdAt != null ? DateFormat('yyyy-MM-dd').format(item.createdAt!) : '-')),
                      ],
                    ),
                ],
              ),
            ),
          ),
          ReportPaginationBar(
            currentPage: report.pagination.currentPage,
            lastPage: report.pagination.lastPage,
            total: report.pagination.total,
            onPageChanged: (page) {
              final query = ref.read(patientsReportQueryProvider);
              ref.read(patientsReportQueryProvider.notifier).state = query.copyWith(page: page);
            },
          ),
        ],
      ),
    );
  }
}

Widget _summaryCard(String title, String value) {
  return Builder(
    builder: (context) => Container(
      width: 220,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 3),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    ),
  );
}
