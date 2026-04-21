import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../app_shell/presentation/app_shell_navigation.dart';
import '../../app_shell/presentation/app_shell_scaffold.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import 'controllers/invoices_list_controller.dart';
import 'invoice_details_page.dart';
import 'invoice_form_page.dart';

class InvoicesListPage extends ConsumerStatefulWidget {
  const InvoicesListPage({super.key});

  static const routePath = '/invoices';

  @override
  ConsumerState<InvoicesListPage> createState() => _InvoicesListPageState();
}

class _InvoicesListPageState extends ConsumerState<InvoicesListPage> {
  final _searchController = TextEditingController();
  final _patientController = TextEditingController();
  final _appointmentController = TextEditingController();
  final _branchController = TextEditingController();

  String? _status;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void dispose() {
    _searchController.dispose();
    _patientController.dispose();
    _appointmentController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _dateFrom != null && _dateTo != null ? DateTimeRange(start: _dateFrom!, end: _dateTo!) : null,
    );

    if (picked == null) return;
    setState(() {
      _dateFrom = picked.start;
      _dateTo = picked.end;
    });
    await ref.read(invoicesListControllerProvider).applyFilters(
          dateFrom: picked.start,
          dateTo: picked.end,
        );
  }

  Future<void> _confirmDelete(int invoiceId, String invoiceNumber) async {
    final controller = ref.read(invoicesListControllerProvider);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete invoice?'),
          content: Text('Delete "$invoiceNumber"? This is blocked when payments exist.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;
    final success = await controller.deleteInvoice(invoiceId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Invoice deleted successfully.' : (controller.errorMessage ?? 'Delete failed.')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = ref.watch(invoicesListControllerProvider);
    final isDesktop = MediaQuery.sizeOf(context).width >= 980;
    final dateFormat = DateFormat('yyyy-MM-dd');
    final rangeLabel = _dateFrom == null || _dateTo == null
        ? l10n.commonDateRange
        : '${dateFormat.format(_dateFrom!)} - ${dateFormat.format(_dateTo!)}';

    return AppShellScaffold(
      title: l10n.billingTitle,
      activeSection: AppShellSection.billing,
      onSectionSelected: (section) => goAppShellSection(context, section),
      onLogout: () => ref.read(authControllerProvider).logout(),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.billingInvoices,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => context.push(InvoiceFormPage.createPath),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.billingNewInvoice),
                ),
              ],
            ).animate().fadeIn().slideY(begin: 0.02),
            const SizedBox(height: 16),
            GlassPanel(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: isDesktop ? 300 : 230,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: l10n.commonSearch,
                          hintText: 'Invoice no, patient name',
                          prefixIcon: const Icon(Icons.search_rounded),
                        ),
                        onSubmitted: (_) => controller.applyFilters(search: _searchController.text.trim()),
                      ),
                    ),
                    _idFilterField(controller: _patientController, label: 'Patient ID'),
                    _idFilterField(controller: _appointmentController, label: 'Appointment ID'),
                    _idFilterField(controller: _branchController, label: 'Branch ID'),
                    SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<String?>(
                        initialValue: _status,
                        decoration: InputDecoration(labelText: l10n.commonStatus),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All')),
                          DropdownMenuItem(value: 'draft', child: Text('Draft')),
                          DropdownMenuItem(value: 'unpaid', child: Text('Unpaid')),
                          DropdownMenuItem(value: 'partially_paid', child: Text('Partially paid')),
                          DropdownMenuItem(value: 'paid', child: Text('Paid')),
                          DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                        ],
                        onChanged: (value) {
                          setState(() => _status = value);
                          controller.applyFilters(status: value);
                        },
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _pickDateRange,
                      icon: const Icon(Icons.date_range_rounded),
                      label: Text(rangeLabel),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => controller.applyFilters(
                        search: _searchController.text.trim(),
                        patientId: int.tryParse(_patientController.text.trim()),
                        appointmentId: int.tryParse(_appointmentController.text.trim()),
                        branchId: int.tryParse(_branchController.text.trim()),
                        status: _status,
                        dateFrom: _dateFrom,
                        dateTo: _dateTo,
                      ),
                      icon: const Icon(Icons.filter_alt_outlined),
                      label: Text(l10n.commonApply),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        _patientController.clear();
                        _appointmentController.clear();
                        _branchController.clear();
                        setState(() {
                          _status = null;
                          _dateFrom = null;
                          _dateTo = null;
                        });
                        controller.applyFilters(
                          search: '',
                          patientId: null,
                          appointmentId: null,
                          branchId: null,
                          status: null,
                          dateFrom: null,
                          dateTo: null,
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.commonReset),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GlassPanel(
                child: controller.loading
                    ? const Center(child: CircularProgressIndicator())
                    : controller.errorMessage != null
                        ? _ErrorState(
                            message: controller.errorMessage!,
                            onRetry: controller.refresh,
                          )
                        : controller.items.isEmpty
                            ? const _EmptyState()
                            : Column(
                                children: [
                                  Expanded(
                                    child: isDesktop
                                        ? _DesktopInvoicesTable(
                                            onView: (id) => context.push(InvoiceDetailsPage.pathFor(id)),
                                            onEdit: (id) => context.push(InvoiceFormPage.editPathFor(id)),
                                            onDelete: _confirmDelete,
                                          )
                                        : _MobileInvoicesList(
                                            onView: (id) => context.push(InvoiceDetailsPage.pathFor(id)),
                                            onEdit: (id) => context.push(InvoiceFormPage.editPathFor(id)),
                                            onDelete: _confirmDelete,
                                          ),
                                  ),
                                  _PaginationBar(
                                    currentPage: controller.pagination.currentPage,
                                    lastPage: controller.pagination.lastPage,
                                    total: controller.pagination.total,
                                    onPageChanged: controller.goToPage,
                                  ),
                                ],
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopInvoicesTable extends ConsumerWidget {
  const _DesktopInvoicesTable({
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final void Function(int id) onView;
  final void Function(int id) onEdit;
  final void Function(int id, String invoiceNumber) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(invoicesListControllerProvider);
    final currency = NumberFormat.currency(symbol: 'AED ');
    final dateFormat = DateFormat('yyyy-MM-dd');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Invoice #')),
          DataColumn(label: Text('Issued')),
          DataColumn(label: Text('Patient')),
          DataColumn(label: Text('Total')),
          DataColumn(label: Text('Paid')),
          DataColumn(label: Text('Remaining')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final invoice in controller.items)
            DataRow(
              cells: [
                DataCell(Text(invoice.invoiceNumber)),
                DataCell(Text(dateFormat.format(invoice.issuedAt))),
                DataCell(Text(invoice.patient?.label ?? 'Patient #${invoice.patientId ?? '-'}')),
                DataCell(Text(currency.format(invoice.total))),
                DataCell(Text(currency.format(invoice.paidAmount ?? 0))),
                DataCell(Text(currency.format(invoice.remainingAmount ?? invoice.total))),
                DataCell(_StatusChip(status: invoice.status)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined),
                        onPressed: () => onView(invoice.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => onEdit(invoice.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => onDelete(invoice.id, invoice.invoiceNumber),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MobileInvoicesList extends ConsumerWidget {
  const _MobileInvoicesList({
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final void Function(int id) onView;
  final void Function(int id) onEdit;
  final void Function(int id, String invoiceNumber) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(invoicesListControllerProvider);
    final currency = NumberFormat.currency(symbol: 'AED ');

    return ListView.separated(
      itemCount: controller.items.length,
      padding: const EdgeInsets.all(12),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final invoice = controller.items[index];

        return Card(
          child: ListTile(
            title: Text(invoice.invoiceNumber),
            subtitle: Text(
              '${invoice.patient?.label ?? 'Patient #${invoice.patientId ?? '-'}'}\n${currency.format(invoice.total)} • ${_prettyStatus(invoice.status)}',
            ),
            isThreeLine: true,
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    onView(invoice.id);
                    break;
                  case 'edit':
                    onEdit(invoice.id);
                    break;
                  case 'delete':
                    onDelete(invoice.id, invoice.invoiceNumber);
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'view', child: Text('View')),
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.onPageChanged,
  });

  final int currentPage;
  final int lastPage;
  final int total;
  final void Function(int page) onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Row(
        children: [
          Text('Total: $total'),
          const Spacer(),
          IconButton(
            onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Text('Page $currentPage / $lastPage'),
          IconButton(
            onPressed: currentPage < lastPage ? () => onPageChanged(currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final normalized = status.toLowerCase();
    final background = switch (normalized) {
      'paid' => scheme.primaryContainer,
      'partially_paid' => scheme.secondaryContainer,
      'cancelled' => scheme.errorContainer,
      'draft' => scheme.tertiaryContainer,
      _ => scheme.surfaceContainerHighest,
    };

    return Chip(
      label: Text(_prettyStatus(status)),
      visualDensity: VisualDensity.compact,
      backgroundColor: background,
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => onRetry(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 36, color: scheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            'No invoices found.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Try changing filters or create a new invoice.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

Widget _idFilterField({
  required TextEditingController controller,
  required String label,
}) {
  return SizedBox(
    width: 130,
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
    ),
  );
}

String _prettyStatus(String value) {
  return value
      .split('_')
      .map((part) => part.isEmpty ? part : part[0].toUpperCase() + part.substring(1))
      .join(' ');
}
