import 'branch_stats.dart';
import 'branch_tenant_ref.dart';

class Branch {
  const Branch({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.status,
    this.code,
    this.phone,
    this.email,
    this.address,
    this.stats,
    this.tenant,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int tenantId;
  final String name;
  final String status;
  final String? code;
  final String? phone;
  final String? email;
  final String? address;
  final BranchStats? stats;
  final BranchTenantRef? tenant;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Branch.fromJson(Map<String, dynamic> json) {
    final statsRaw = json['stats'];
    final tenantRaw = json['tenant'];

    return Branch(
      id: (json['id'] as num?)?.toInt() ?? 0,
      tenantId: (json['tenant_id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      code: json['code'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      status: (json['status'] as String?) ?? 'active',
      stats: statsRaw is Map<String, dynamic> ? BranchStats.fromJson(statsRaw) : null,
      tenant: tenantRaw is Map<String, dynamic> ? BranchTenantRef.fromJson(tenantRaw) : null,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }
}

DateTime? _parseDate(Object? raw) {
  if (raw == null) return null;
  if (raw is String) return DateTime.tryParse(raw);
  return null;
}
