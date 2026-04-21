class PaymentCreatePayload {
  const PaymentCreatePayload({
    required this.invoiceId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    this.referenceNumber,
    this.notes,
  });

  final int invoiceId;
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;
  final String? referenceNumber;
  final String? notes;

  Map<String, dynamic> toJson() {
    String formatDate(DateTime value) => value.toIso8601String().split('T').first;

    return {
      'invoice_id': invoiceId,
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_date': formatDate(paymentDate),
      'reference_number': referenceNumber?.trim().isEmpty == true ? null : referenceNumber?.trim(),
      'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
    }..removeWhere((key, value) => value == null);
  }
}
