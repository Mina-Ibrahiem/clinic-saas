import 'billing_reference.dart';
import 'invoice_item.dart';
import 'payment.dart';

class Invoice {
  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.status,
    required this.issuedAt,
    this.tenantId,
    this.branchId,
    this.patientId,
    this.appointmentId,
    this.dueAt,
    this.createdBy,
    this.paidAmount,
    this.remainingAmount,
    this.itemsCount,
    this.paymentsCount,
    this.patient,
    this.appointment,
    this.branch,
    this.items = const [],
    this.payments = const [],
  });

  final int id;
  final String invoiceNumber;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String status;
  final DateTime issuedAt;
  final int? tenantId;
  final int? branchId;
  final int? patientId;
  final int? appointmentId;
  final DateTime? dueAt;
  final int? createdBy;
  final double? paidAmount;
  final double? remainingAmount;
  final int? itemsCount;
  final int? paymentsCount;
  final BillingReference? patient;
  final BillingReference? appointment;
  final BillingReference? branch;
  final List<InvoiceItem> items;
  final List<Payment> payments;

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final patientRaw = json['patient'];
    final appointmentRaw = json['appointment'];
    final branchRaw = json['branch'];
    final summaryRaw = json['summary'];
    final itemsRaw = json['items'];
    final paymentsRaw = json['payments'];

    final summary = summaryRaw is Map<String, dynamic> ? summaryRaw : const <String, dynamic>{};

    return Invoice(
      id: (json['id'] as num?)?.toInt() ?? 0,
      tenantId: (json['tenant_id'] as num?)?.toInt(),
      branchId: (json['branch_id'] as num?)?.toInt(),
      patientId: (json['patient_id'] as num?)?.toInt(),
      appointmentId: (json['appointment_id'] as num?)?.toInt(),
      invoiceNumber: (json['invoice_number'] as String?) ?? '',
      subtotal: _toDouble(json['subtotal']),
      discount: _toDouble(json['discount']),
      tax: _toDouble(json['tax']),
      total: _toDouble(json['total']),
      status: (json['status'] as String?) ?? 'unpaid',
      issuedAt: DateTime.tryParse(json['issued_at']?.toString() ?? '') ?? DateTime.now(),
      dueAt: DateTime.tryParse(json['due_at']?.toString() ?? ''),
      createdBy: (json['created_by'] as num?)?.toInt(),
      paidAmount: summaryRaw is Map<String, dynamic> ? _toDouble(summary['paid_amount']) : null,
      remainingAmount: summaryRaw is Map<String, dynamic> ? _toDouble(summary['remaining_amount']) : null,
      itemsCount: summaryRaw is Map<String, dynamic> ? (summary['items_count'] as num?)?.toInt() : null,
      paymentsCount: summaryRaw is Map<String, dynamic> ? (summary['payments_count'] as num?)?.toInt() : null,
      patient: patientRaw is Map<String, dynamic> ? BillingReference.fromPatientJson(patientRaw) : null,
      appointment: appointmentRaw is Map<String, dynamic> ? BillingReference.fromAppointmentJson(appointmentRaw) : null,
      branch: branchRaw is Map<String, dynamic> ? BillingReference.fromBranchJson(branchRaw) : null,
      items: itemsRaw is List
          ? itemsRaw.whereType<Map<String, dynamic>>().map(InvoiceItem.fromJson).toList(growable: false)
          : const <InvoiceItem>[],
      payments: paymentsRaw is List
          ? paymentsRaw.whereType<Map<String, dynamic>>().map(Payment.fromJson).toList(growable: false)
          : const <Payment>[],
    );
  }
}

double _toDouble(Object? raw) {
  if (raw == null) return 0;
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw.toString()) ?? 0;
}
