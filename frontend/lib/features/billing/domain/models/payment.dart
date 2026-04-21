import 'billing_reference.dart';

class Payment {
  const Payment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    this.tenantId,
    this.branchId,
    this.referenceNumber,
    this.notes,
    this.receivedBy,
    this.invoice,
    this.patient,
    this.branch,
  });

  final int id;
  final int invoiceId;
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;
  final int? tenantId;
  final int? branchId;
  final String? referenceNumber;
  final String? notes;
  final int? receivedBy;
  final BillingReference? invoice;
  final BillingReference? patient;
  final BillingReference? branch;

  factory Payment.fromJson(Map<String, dynamic> json) {
    final invoiceRaw = json['invoice'];
    final patientRaw = json['patient'];
    final branchRaw = json['branch'];

    return Payment(
      id: (json['id'] as num?)?.toInt() ?? 0,
      tenantId: (json['tenant_id'] as num?)?.toInt(),
      branchId: (json['branch_id'] as num?)?.toInt(),
      invoiceId: (json['invoice_id'] as num?)?.toInt() ?? 0,
      paymentMethod: (json['payment_method'] as String?) ?? 'cash',
      amount: _toDouble(json['amount']),
      paymentDate: DateTime.tryParse(json['payment_date']?.toString() ?? '') ?? DateTime.now(),
      referenceNumber: json['reference_number'] as String?,
      notes: json['notes'] as String?,
      receivedBy: (json['received_by'] as num?)?.toInt(),
      invoice: invoiceRaw is Map<String, dynamic> ? BillingReference.fromInvoiceJson(invoiceRaw) : null,
      patient: patientRaw is Map<String, dynamic> ? BillingReference.fromPatientJson(patientRaw) : null,
      branch: branchRaw is Map<String, dynamic> ? BillingReference.fromBranchJson(branchRaw) : null,
    );
  }
}

double _toDouble(Object? raw) {
  if (raw == null) return 0;
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw.toString()) ?? 0;
}
