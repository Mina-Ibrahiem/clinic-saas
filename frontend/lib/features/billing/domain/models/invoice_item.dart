import 'billing_reference.dart';

class InvoiceItem {
  const InvoiceItem({
    required this.id,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.serviceId,
    this.description,
    this.service,
  });

  final int id;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final int? serviceId;
  final String? description;
  final BillingReference? service;

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    final serviceRaw = json['service'];
    return InvoiceItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      serviceId: (json['service_id'] as num?)?.toInt(),
      description: json['description'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: _toDouble(json['unit_price']),
      totalPrice: _toDouble(json['total_price']),
      service: serviceRaw is Map<String, dynamic> ? BillingReference.fromServiceJson(serviceRaw) : null,
    );
  }
}

double _toDouble(Object? raw) {
  if (raw == null) return 0;
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw.toString()) ?? 0;
}
