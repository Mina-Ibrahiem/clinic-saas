import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/smart_reference_field.dart';
import '../domain/models/report_models.dart';
import 'controllers/reports_providers.dart';
import 'report_routes.dart';
import 'widgets/report_common_widgets.dart';
import 'widgets/reports_page_scaffold.dart';

class RevenueReportPage extends ConsumerStatefulWidget {
  const RevenueReportPage({super.key});

  static const routePath = ReportRoutes.revenue;

  @override
  ConsumerState<RevenueReportPage> createState() => _RevenueReportPageState();
}

class _RevenueReportPageState extends ConsumerState<RevenueReportPage> {
  Future<void> _pickRange() async {
    final query = ref.read(revenueReportQueryProvider);
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: query.dateFrom != null && query.dateTo != null
          ? DateTimeRange(start: query.dateFrom!, end: query.dateTo!)
          : null,
    );
    if (range == null) return;
    ref.read(revenueReportQueryProvider.notifier).state = query.copyWith(
          dateFrom: range.start,
          dateTo: range.end,
          page: 1,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = ref.watch(revenueReportQueryProvider);
    final reportState = ref.watch(revenueReportProvider);
    final currency = NumberFormat.currency(symbol: 'AED ');

    return ReportsPageScaffold(
      title: l10n.reportTitleRevenue,
      activeType: ReportType.revenue,
      onExport: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('CSV export will connect to the API in a future release.'),
          ),
        );
      },
      child: Column(
        children: [
          GlassPanel(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SmartReferenceField(
                    entity: ReferenceEntity.branch,
                    label: l10n.commonBranch,
                    value: query.branchId,
                    hint: l10n.dashboardAllBranches,
                    width: 220,
                    dense: true,
                    onChanged: (id) {
                      ref.read(revenueReportQueryProvider.notifier).state = query.copyWith(branchId: id, page: 1);
                    },
                  ),
                  SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<String?>(
                      initialValue: query.status,
                      decoration: InputDecoration(labelText: l10n.commonStatus),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('All')),
                        DropdownMenuItem(value: 'paid', child: Text('Paid')),
                        DropdownMenuItem(value: 'unpaid', child: Text('Unpaid')),
                        DropdownMenuItem(value: 'partially_paid', child: Text('Partially paid')),
                        DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                        DropdownMenuItem(value: 'draft', child: Text('Draft')),
                      ],
                      onChanged: (value) {
                        ref.read(revenueReportQueryProvider.notifier).state = query.copyWith(status: value, page: 1);
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
                    onPressed: () => ref.invalidate(revenueReportProvider),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: reportState.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(8),
                child: AppListSkeleton(rows: 10),
              ),
              error: (error, _) => ReportErrorState(
                message: '${l10n.commonError}: $error',
                onRetry: () => ref.invalidate(revenueReportProvider),
              ),
              data: (report) => _RevenueReportBody(report: report, currency: currency),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueReportBody extends ConsumerWidget {
  const _RevenueReportBody({
    required this.report,
    required this.currency,
  });

  final RevenueReportResponse report;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = report.summary;
    if (report.items.isEmpty) {
      return const ReportEmptyState(icon: Icons.bar_chart_rounded, message: 'No revenue report data.');
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
                _summaryCard('Total Invoiced', currency.format(double.tryParse(summary['total_invoiced']?.toString() ?? '0') ?? 0)),
                _summaryCard('Paid', currency.format(double.tryParse(summary['paid_total']?.toString() ?? '0') ?? 0)),
                _summaryCard('Remaining', currency.format(double.tryParse(summary['remaining_total']?.toString() ?? '0') ?? 0)),
                _summaryCard('Invoices', (summary['invoices_count'] ?? 0).toString()),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Invoice #')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Patient')),
                  DataColumn(label: Text('Issued')),
                  DataColumn(label: Text('Total')),
                  DataColumn(label: Text('Paid')),
                  DataColumn(label: Text('Remaining')),
                ],
                columnSpacing: 20,
                rows: [
                  for (final item in report.items)
                    DataRow(
                      cells: [
                        DataCell(Text(item.invoiceNumber)),
                        DataCell(Text(item.status)),
                        DataCell(Text(item.patient?.label ?? '-')),
                        DataCell(Text(item.issuedAt != null ? DateFormat('yyyy-MM-dd').format(item.issuedAt!) : '-')),
                        DataCell(Text(currency.format(item.total))),
                        DataCell(Text(currency.format(item.paidAmount))),
                        DataCell(Text(currency.format(item.remainingAmount))),
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
              final query = ref.read(revenueReportQueryProvider);
              ref.read(revenueReportQueryProvider.notifier).state = query.copyWith(page: page);
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
      width: 190,
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
