import 'service_reference.dart';

class Service {
  const Service({
    required this.id,
    required this.name,
    required this.price,
    required this.status,
    this.tenantId,
    this.branchId,
    this.code,
    this.description,
    this.durationMinutes,
    this.appointmentsCount,
    this.invoiceItemsCount,
    this.branch,
    this.tenant,
  });

  final int id;
  final String name;
  final double price;
  final String status;
  final int? tenantId;
  final int? branchId;
  final String? code;
  final String? description;
  final int? durationMinutes;
  final int? appointmentsCount;
  final int? invoiceItemsCount;
  final ServiceReference? branch;
  final ServiceReference? tenant;

  factory Service.fromJson(Map<String, dynamic> json) {
    final statsRaw = json['stats'];
    final branchRaw = json['branch'];
    final tenantRaw = json['tenant'];
    final stats = statsRaw is Map<String, dynamic> ? statsRaw : const <String, dynamic>{};

    return Service(
      id: (json['id'] as num?)?.toInt() ?? 0,
      tenantId: (json['tenant_id'] as num?)?.toInt(),
      branchId: (json['branch_id'] as num?)?.toInt(),
      name: (json['name'] as String?) ?? '',
      code: json['code'] as String?,
      description: json['description'] as String?,
      price: _toDouble(json['price']),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      status: (json['status'] as String?) ?? 'active',
      appointmentsCount: (stats['appointments_count'] as num?)?.toInt(),
      invoiceItemsCount: (stats['invoice_items_count'] as num?)?.toInt(),
      branch: branchRaw is Map<String, dynamic> ? ServiceReference.fromBranchJson(branchRaw) : null,
      tenant: tenantRaw is Map<String, dynamic> ? ServiceReference.fromTenantJson(tenantRaw) : null,
    );
  }
}

double _toDouble(Object? raw) {
  if (raw == null) return 0;
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw.toString()) ?? 0;
}
