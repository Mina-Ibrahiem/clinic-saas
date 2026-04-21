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

class DoctorsReportPage extends ConsumerStatefulWidget {
  const DoctorsReportPage({super.key});

  static const routePath = ReportRoutes.doctors;

  @override
  ConsumerState<DoctorsReportPage> createState() => _DoctorsReportPageState();
}

class _DoctorsReportPageState extends ConsumerState<DoctorsReportPage> {
  String? _status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(doctorsReportProvider);
    final currency = NumberFormat.currency(symbol: 'AED ');

    return ReportsPageScaffold(
      title: l10n.reportTitleDoctors,
      activeType: ReportType.doctors,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 170,
                child: DropdownButtonFormField<String?>(
                  initialValue: _status,
                  decoration: InputDecoration(labelText: l10n.commonStatus),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                    DropdownMenuItem(value: 'on_leave', child: Text('On leave')),
                  ],
                  onChanged: (value) {
                    setState(() => _status = value);
                    final query = ref.read(doctorsReportQueryProvider);
                    ref.read(doctorsReportQueryProvider.notifier).state = query.copyWith(status: value, page: 1);
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: l10n.commonRefresh,
                onPressed: () => ref.invalidate(doctorsReportProvider),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ReportErrorState(
                message: '${l10n.commonError}: $error',
                onRetry: () => ref.invalidate(doctorsReportProvider),
              ),
              data: (report) => _DoctorsBody(report: report, currency: currency),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorsBody extends ConsumerWidget {
  const _DoctorsBody({required this.report, required this.currency});
  final DoctorsReportResponse report;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (report.items.isEmpty) {
      return const ReportEmptyState(icon: Icons.local_hospital_outlined, message: 'No doctors report data.');
    }
    final summary = report.summary;
    return GlassPanel(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _summaryCard('Total', (summary['total_doctors'] ?? 0).toString()),
                _summaryCard('Active', (summary['active_count'] ?? 0).toString()),
                _summaryCard('Inactive', (summary['inactive_count'] ?? 0).toString()),
                _summaryCard('On Leave', (summary['on_leave_count'] ?? 0).toString()),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Code')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Specialization')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Appointments')),
                  DataColumn(label: Text('Revenue Contribution')),
                ],
                rows: [
                  for (final item in report.items)
                    DataRow(
                      cells: [
                        DataCell(Text(item.doctorCode ?? '-')),
                        DataCell(Text(item.fullName)),
                        DataCell(Text(item.specialization)),
                        DataCell(Text(item.status)),
                        DataCell(Text(item.appointmentsCount.toString())),
                        DataCell(Text(currency.format(item.revenueContribution))),
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
              final query = ref.read(doctorsReportQueryProvider);
              ref.read(doctorsReportQueryProvider.notifier).state = query.copyWith(page: page);
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
      width: 150,
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
