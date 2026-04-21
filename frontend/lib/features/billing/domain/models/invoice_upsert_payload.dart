class InvoiceUpsertPayload {
  const InvoiceUpsertPayload({
    required this.patientId,
    required this.issuedAt,
    required this.items,
    this.appointmentId,
    this.branchId,
    this.dueAt,
    this.discount,
    this.tax,
    this.status,
  });

  final int patientId;
  final DateTime issuedAt;
  final List<InvoiceUpsertItemPayload> items;
  final int? appointmentId;
  final int? branchId;
  final DateTime? dueAt;
  final double? discount;
  final double? tax;
  final String? status;

  Map<String, dynamic> toJson() {
    String formatDate(DateTime value) => value.toIso8601String().split('T').first;

    return {
      'patient_id': patientId,
      'appointment_id': appointmentId,
      'branch_id': branchId,
      'issued_at': formatDate(issuedAt),
      'due_at': dueAt != null ? formatDate(dueAt!) : null,
      'discount': discount,
      'tax': tax,
      'status': status?.trim().isEmpty == true ? null : status,
      'items': items.map((item) => item.toJson()).toList(growable: false),
    }..removeWhere((key, value) => value == null);
  }
}

class InvoiceUpsertItemPayload {
  const InvoiceUpsertItemPayload({
    required this.quantity,
    required this.unitPrice,
    this.serviceId,
    this.description,
  });

  final int quantity;
  final double unitPrice;
  final int? serviceId;
  final String? description;

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'description': description?.trim().isEmpty == true ? null : description?.trim(),
      'quantity': quantity,
      'unit_price': unitPrice,
    }..removeWhere((key, value) => value == null);
  }
}
