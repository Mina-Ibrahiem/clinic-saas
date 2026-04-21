import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/networking/api_exception.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../data/invoices_repository.dart';
import '../domain/models/invoice.dart';
import '../domain/models/payment_create_payload.dart';
import 'controllers/invoice_details_provider.dart';
import 'controllers/payment_actions_controller.dart';
import 'invoice_form_page.dart';
import 'invoices_list_page.dart';

class InvoiceDetailsPage extends ConsumerStatefulWidget {
  const InvoiceDetailsPage({
    super.key,
    required this.invoiceId,
  });

  final int invoiceId;

  static String pathFor(int id) => '/invoices/$id';

  @override
  ConsumerState<InvoiceDetailsPage> createState() => _InvoiceDetailsPageState();
}

class _InvoiceDetailsPageState extends ConsumerState<InvoiceDetailsPage> {
  Future<void> _refreshInvoice() async {
    final notifier = ref.read(invoiceDetailsVersionProvider(widget.invoiceId).notifier);
    notifier.state = notifier.state + 1;
  }

  Future<void> _deletePayment(int paymentId) async {
    final actions = ref.read(paymentActionsControllerProvider);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete payment?'),
        content: const Text('This will recalculate invoice status and remaining amount.'),
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
      ),
    );

    if (shouldDelete != true || !mounted) return;
    final ok = await actions.deletePayment(paymentId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Payment deleted.' : (actions.errorMessage ?? 'Delete payment failed.'))),
    );
    if (ok) {
      await _refreshInvoice();
    }
  }

  Future<void> _openAddPaymentDialog(Invoice invoice) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _AddPaymentDialog(invoice: invoice),
    );
    if (result == true) {
      await _refreshInvoice();
    }
  }

  Future<void> _deleteInvoice(Invoice invoice) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete invoice?'),
        content: Text('Delete "${invoice.invoiceNumber}"? This is blocked when payments exist.'),
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
      ),
    );

    if (shouldDelete != true || !mounted) return;
    try {
      await ref.read(invoicesRepositoryProvider).delete(invoice.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice deleted successfully.')),
      );
      context.go(InvoicesListPage.routePath);
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete invoice.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoiceState = ref.watch(invoiceDetailsProvider(widget.invoiceId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: invoiceState.maybeWhen(
          data: (invoice) => [
            IconButton(
              tooltip: 'Edit',
              onPressed: () => context.push(InvoiceFormPage.editPathFor(widget.invoiceId)),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: () => _deleteInvoice(invoice),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
          orElse: () => [
            IconButton(
              tooltip: 'Edit',
              onPressed: () => context.push(InvoiceFormPage.editPathFor(widget.invoiceId)),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: invoiceState.when(
          data: (invoice) => _DetailsLayout(
            invoice: invoice,
            onDeletePayment: _deletePayment,
            onAddPayment: () => _openAddPaymentDialog(invoice),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Failed to load invoice.\n$error')),
        ),
      ),
    );
  }
}

class _DetailsLayout extends StatelessWidget {
  const _DetailsLayout({
    required this.invoice,
    required this.onDeletePayment,
    required this.onAddPayment,
  });

  final Invoice invoice;
  final Future<void> Function(int paymentId) onDeletePayment;
  final VoidCallback onAddPayment;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'AED ');
    final dateFormat = DateFormat('yyyy-MM-dd');

    final rows = <({String title, String value})>[
      (title: 'Invoice #', value: invoice.invoiceNumber),
      (title: 'Status', value: _prettyStatus(invoice.status)),
      (title: 'Issued at', value: dateFormat.format(invoice.issuedAt)),
      (title: 'Due at', value: invoice.dueAt != null ? dateFormat.format(invoice.dueAt!) : '-'),
      (title: 'Patient', value: invoice.patient?.label ?? 'Patient #${invoice.patientId ?? '-'}'),
      (title: 'Appointment', value: invoice.appointment?.id.toString() ?? (invoice.appointmentId?.toString() ?? '-')),
      (title: 'Branch', value: invoice.branch?.label ?? 'Branch #${invoice.branchId ?? '-'}'),
    ];

    return ListView(
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _summaryCard('Subtotal', currency.format(invoice.subtotal)),
            _summaryCard('Discount', currency.format(invoice.discount)),
            _summaryCard('Tax', currency.format(invoice.tax)),
            _summaryCard('Total', currency.format(invoice.total), highlighted: true),
            _summaryCard('Paid', currency.format(invoice.paidAmount ?? 0)),
            _summaryCard('Remaining', currency.format(invoice.remainingAmount ?? invoice.total)),
          ],
        ),
        const SizedBox(height: 16),
        GlassPanel(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final row in rows)
                  SizedBox(
                    width: 320,
                    child: _MetaRow(title: row.title, value: row.value),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invoice Items',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Description')),
                      DataColumn(label: Text('Qty')),
                      DataColumn(label: Text('Unit Price')),
                      DataColumn(label: Text('Total')),
                    ],
                    rows: [
                      for (final item in invoice.items)
                        DataRow(
                          cells: [
                            DataCell(Text(item.description ?? item.service?.label ?? 'Item')),
                            DataCell(Text(item.quantity.toString())),
                            DataCell(Text(currency.format(item.unitPrice))),
                            DataCell(Text(currency.format(item.totalPrice))),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Payments',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: onAddPayment,
                      icon: const Icon(Icons.add_card_rounded),
                      label: const Text('Add payment'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (invoice.payments.isEmpty)
                  const Text('No payments yet.')
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Method')),
                        DataColumn(label: Text('Amount')),
                        DataColumn(label: Text('Reference')),
                        DataColumn(label: Text('Notes')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: [
                        for (final payment in invoice.payments)
                          DataRow(
                            cells: [
                              DataCell(Text(dateFormat.format(payment.paymentDate))),
                              DataCell(Text(_prettyStatus(payment.paymentMethod))),
                              DataCell(Text(currency.format(payment.amount))),
                              DataCell(Text(payment.referenceNumber?.isNotEmpty == true ? payment.referenceNumber! : '-')),
                              DataCell(Text(payment.notes?.isNotEmpty == true ? payment.notes! : '-')),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => onDeletePayment(payment.id),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String value, {bool highlighted = false}) {
    return Builder(
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return SizedBox(
          width: 190,
          child: GlassPanel(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: highlighted ? scheme.primary : null,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _AddPaymentDialog extends ConsumerStatefulWidget {
  const _AddPaymentDialog({required this.invoice});

  final Invoice invoice;

  @override
  ConsumerState<_AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends ConsumerState<_AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  String _method = 'cash';
  DateTime _paymentDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (picked == null) return;
    setState(() => _paymentDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount must be greater than zero.')),
      );
      return;
    }

    final controller = ref.read(paymentActionsControllerProvider);
    final payment = await controller.createPayment(
      PaymentCreatePayload(
        invoiceId: widget.invoice.id,
        amount: amount,
        paymentMethod: _method,
        paymentDate: _paymentDate,
        referenceNumber: _referenceController.text,
        notes: _notesController.text,
      ),
    );

    if (!mounted) return;
    if (payment == null) {
      final backendMessage = controller.errorMessage ?? 'Payment creation failed.';
      final message = backendMessage.toLowerCase().contains('exceeds')
          ? 'Overpayment blocked: amount is higher than remaining balance.'
          : backendMessage;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(paymentActionsControllerProvider);
    final dateFormat = DateFormat('yyyy-MM-dd');

    return AlertDialog(
      title: const Text('Add payment'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: widget.invoice.invoiceNumber,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Invoice'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (value) {
                  final raw = (value ?? '').trim();
                  if (raw.isEmpty) return 'Amount is required.';
                  if (double.tryParse(raw) == null) return 'Amount must be numeric.';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _method,
                decoration: const InputDecoration(labelText: 'Payment method'),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'card', child: Text('Card')),
                  DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
                ],
                onChanged: controller.submitting ? null : (value) => setState(() => _method = value ?? 'cash'),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: controller.submitting ? null : _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Payment date',
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(dateFormat.format(_paymentDate)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(labelText: 'Reference number'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: controller.submitting ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: controller.submitting ? null : _submit,
          child: controller.submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add payment'),
        ),
      ],
    );
  }
}

String _prettyStatus(String value) {
  return value
      .split('_')
      .map((part) => part.isEmpty ? part : part[0].toUpperCase() + part.substring(1))
      .join(' ');
}
