class BillingReference {
  const BillingReference({
    required this.id,
    required this.label,
    this.code,
    this.extra,
  });

  final int id;
  final String label;
  final String? code;
  final String? extra;

  factory BillingReference.fromPatientJson(Map<String, dynamic> json) {
    return BillingReference(
      id: (json['id'] as num?)?.toInt() ?? 0,
      label: (json['full_name'] as String?) ?? '',
      code: (json['patient_code'] as String?),
      extra: (json['phone'] as String?),
    );
  }

  factory BillingReference.fromAppointmentJson(Map<String, dynamic> json) {
    return BillingReference(
      id: (json['id'] as num?)?.toInt() ?? 0,
      label: (json['appointment_date'] as String?) ?? '',
      code: (json['status'] as String?),
      extra: null,
    );
  }

  factory BillingReference.fromBranchJson(Map<String, dynamic> json) {
    return BillingReference(
      id: (json['id'] as num?)?.toInt() ?? 0,
      label: (json['name'] as String?) ?? '',
      code: (json['code'] as String?),
      extra: null,
    );
  }

  factory BillingReference.fromServiceJson(Map<String, dynamic> json) {
    return BillingReference(
      id: (json['id'] as num?)?.toInt() ?? 0,
      label: (json['name'] as String?) ?? '',
      code: (json['code'] as String?),
      extra: null,
    );
  }

  factory BillingReference.fromInvoiceJson(Map<String, dynamic> json) {
    return BillingReference(
      id: (json['id'] as num?)?.toInt() ?? 0,
      label: (json['invoice_number'] as String?) ?? '',
      code: (json['status'] as String?),
      extra: json['total']?.toString(),
    );
  }
}
