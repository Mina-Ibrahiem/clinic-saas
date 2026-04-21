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

class PaymentsReportPage extends ConsumerStatefulWidget {
  const PaymentsReportPage({super.key});

  static const routePath = ReportRoutes.payments;

  @override
  ConsumerState<PaymentsReportPage> createState() => _PaymentsReportPageState();
}

class _PaymentsReportPageState extends ConsumerState<PaymentsReportPage> {
  final _branchController = TextEditingController();
  final _invoiceController = TextEditingController();
  String? _method;

  @override
  void dispose() {
    _branchController.dispose();
    _invoiceController.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final query = ref.read(paymentsReportQueryProvider);
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: query.dateFrom != null && query.dateTo != null
          ? DateTimeRange(start: query.dateFrom!, end: query.dateTo!)
          : null,
    );
    if (range == null) return;
    ref.read(paymentsReportQueryProvider.notifier).state = query.copyWith(
          dateFrom: range.start,
          dateTo: range.end,
          page: 1,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(paymentsReportProvider);
    final currency = NumberFormat.currency(symbol: 'AED ');

    return ReportsPageScaffold(
      title: l10n.reportTitlePayments,
      activeType: ReportType.payments,
      child: Column(
        children: [
          GlassPanel(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: 130,
                    child: TextField(
                      controller: _branchController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: '${l10n.commonBranch} ID'),
                      onSubmitted: (value) {
                        final query = ref.read(paymentsReportQueryProvider);
                        ref.read(paymentsReportQueryProvider.notifier).state = query.copyWith(
                              branchId: int.tryParse(value.trim()),
                              page: 1,
                            );
                      },
                    ),
                  ),
                  SizedBox(
                    width: 130,
                    child: TextField(
                      controller: _invoiceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Invoice ID'),
                      onSubmitted: (value) {
                        final query = ref.read(paymentsReportQueryProvider);
                        ref.read(paymentsReportQueryProvider.notifier).state = query.copyWith(
                              invoiceId: int.tryParse(value.trim()),
                              page: 1,
                            );
                      },
                    ),
                  ),
                  SizedBox(
                    width: 170,
                    child: DropdownButtonFormField<String?>(
                      initialValue: _method,
                      decoration: const InputDecoration(labelText: 'Payment method'),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('All')),
                        DropdownMenuItem(value: 'cash', child: Text('Cash')),
                        DropdownMenuItem(value: 'card', child: Text('Card')),
                        DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
                      ],
                      onChanged: (value) {
                        setState(() => _method = value);
                        final query = ref.read(paymentsReportQueryProvider);
                        ref.read(paymentsReportQueryProvider.notifier).state = query.copyWith(
                              paymentMethod: value,
                              page: 1,
                            );
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
                    onPressed: () => ref.invalidate(paymentsReportProvider),
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
                message: '${l10n.commonError}: $error',
                onRetry: () => ref.invalidate(paymentsReportProvider),
              ),
              data: (report) => _PaymentsBody(report: report, currency: currency),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentsBody extends ConsumerWidget {
  const _PaymentsBody({required this.report, required this.currency});
  final PaymentsReportResponse report;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (report.items.isEmpty) {
      return const ReportEmptyState(icon: Icons.payments_outlined, message: 'No payments data.');
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
                _summaryCard('Payments', (report.summary['payments_count'] ?? 0).toString()),
                _summaryCard('Total Amount', currency.format(double.tryParse(report.summary['total_amount']?.toString() ?? '0') ?? 0)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Method')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Invoice')),
                  DataColumn(label: Text('Patient')),
                  DataColumn(label: Text('Reference')),
                ],
                rows: [
                  for (final item in report.items)
                    DataRow(
                      cells: [
                        DataCell(Text(item.paymentDate != null ? DateFormat('yyyy-MM-dd').format(item.paymentDate!) : '-')),
                        DataCell(Text(item.paymentMethod)),
                        DataCell(Text(currency.format(item.amount))),
                        DataCell(Text(item.invoice?.label ?? '-')),
                        DataCell(Text(item.patient?.label ?? '-')),
                        DataCell(Text(item.referenceNumber ?? '-')),
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
              final query = ref.read(paymentsReportQueryProvider);
              ref.read(paymentsReportQueryProvider.notifier).state = query.copyWith(page: page);
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
