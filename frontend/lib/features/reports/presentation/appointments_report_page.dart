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

class AppointmentsReportPage extends ConsumerStatefulWidget {
  const AppointmentsReportPage({super.key});

  static const routePath = ReportRoutes.appointments;

  @override
  ConsumerState<AppointmentsReportPage> createState() => _AppointmentsReportPageState();
}

class _AppointmentsReportPageState extends ConsumerState<AppointmentsReportPage> {
  final _doctorController = TextEditingController();
  final _patientController = TextEditingController();
  final _serviceController = TextEditingController();
  String? _status;

  @override
  void dispose() {
    _doctorController.dispose();
    _patientController.dispose();
    _serviceController.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final query = ref.read(appointmentsReportQueryProvider);
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: query.dateFrom != null && query.dateTo != null
          ? DateTimeRange(start: query.dateFrom!, end: query.dateTo!)
          : null,
    );
    if (range == null) return;
    ref.read(appointmentsReportQueryProvider.notifier).state = query.copyWith(
          dateFrom: range.start,
          dateTo: range.end,
          page: 1,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(appointmentsReportProvider);

    return ReportsPageScaffold(
      title: l10n.reportTitleAppointments,
      activeType: ReportType.appointments,
      child: Column(
        children: [
          GlassPanel(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _idField(_doctorController, 'Doctor ID', (value) {
                    final query = ref.read(appointmentsReportQueryProvider);
                    ref.read(appointmentsReportQueryProvider.notifier).state =
                        query.copyWith(doctorId: int.tryParse(value.trim()), page: 1);
                  }),
                  _idField(_patientController, 'Patient ID', (value) {
                    final query = ref.read(appointmentsReportQueryProvider);
                    ref.read(appointmentsReportQueryProvider.notifier).state =
                        query.copyWith(patientId: int.tryParse(value.trim()), page: 1);
                  }),
                  _idField(_serviceController, 'Service ID', (value) {
                    final query = ref.read(appointmentsReportQueryProvider);
                    ref.read(appointmentsReportQueryProvider.notifier).state =
                        query.copyWith(serviceId: int.tryParse(value.trim()), page: 1);
                  }),
                  SizedBox(
                    width: 170,
                    child: DropdownButtonFormField<String?>(
                      initialValue: _status,
                      decoration: InputDecoration(labelText: l10n.commonStatus),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('All')),
                        DropdownMenuItem(value: 'booked', child: Text('Booked')),
                        DropdownMenuItem(value: 'completed', child: Text('Completed')),
                        DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                        DropdownMenuItem(value: 'no_show', child: Text('No show')),
                      ],
                      onChanged: (value) {
                        setState(() => _status = value);
                        final query = ref.read(appointmentsReportQueryProvider);
                        ref.read(appointmentsReportQueryProvider.notifier).state = query.copyWith(status: value, page: 1);
                      },
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickRange,
                    icon: const Icon(Icons.date_range_outlined),
                    label: Text(l10n.commonDateRange),
                  ),
                  IconButton(
                    tooltip: l10n.commonRefresh,
                    onPressed: () => ref.invalidate(appointmentsReportProvider),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ReportErrorState(
                message: 'Failed to load appointments report: $error',
                onRetry: () => ref.invalidate(appointmentsReportProvider),
              ),
              data: (report) => _AppointmentsBody(report: report),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _idField(TextEditingController controller, String label, void Function(String value) onSubmitted) {
  return SizedBox(
    width: 130,
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      onSubmitted: onSubmitted,
    ),
  );
}

class _AppointmentsBody extends ConsumerWidget {
  const _AppointmentsBody({required this.report});
  final AppointmentsReportResponse report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (report.items.isEmpty) {
      return const ReportEmptyState(icon: Icons.event_busy_outlined, message: 'No appointments report data.');
    }

    return GlassPanel(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _summaryCard('Total', (report.summary['total_count'] ?? 0).toString()),
                _summaryCard('Booked', (report.summary['booked_count'] ?? 0).toString()),
                _summaryCard('Completed', (report.summary['completed_count'] ?? 0).toString()),
                _summaryCard('Cancelled', (report.summary['cancelled_count'] ?? 0).toString()),
                _summaryCard('No Show', (report.summary['no_show_count'] ?? 0).toString()),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Time')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Patient')),
                  DataColumn(label: Text('Doctor')),
                  DataColumn(label: Text('Service')),
                ],
                rows: [
                  for (final item in report.items)
                    DataRow(
                      cells: [
                        DataCell(Text(item.appointmentDate != null ? DateFormat('yyyy-MM-dd').format(item.appointmentDate!) : '-')),
                        DataCell(Text('${item.startTime ?? '-'} - ${item.endTime ?? '-'}')),
                        DataCell(Text(item.status)),
                        DataCell(Text(item.patient?.label ?? '-')),
                        DataCell(Text(item.doctor?.label ?? '-')),
                        DataCell(Text(item.service?.label ?? '-')),
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
              final query = ref.read(appointmentsReportQueryProvider);
              ref.read(appointmentsReportQueryProvider.notifier).state = query.copyWith(page: page);
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
      width: 140,
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
