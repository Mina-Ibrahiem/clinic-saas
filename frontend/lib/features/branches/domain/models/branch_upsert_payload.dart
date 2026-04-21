class BranchUpsertPayload {
  const BranchUpsertPayload({
    this.tenantId,
    required this.name,
    this.code,
    this.phone,
    this.email,
    this.address,
    this.status,
  });

  final int? tenantId;
  final String name;
  final String? code;
  final String? phone;
  final String? email;
  final String? address;
  final String? status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
    };
    if (tenantId != null) map['tenant_id'] = tenantId;
    if (code != null) map['code'] = code;
    if (phone != null) map['phone'] = phone;
    if (email != null) map['email'] = email;
    if (address != null) map['address'] = address;
    if (status != null) map['status'] = status;
    return map;
  }
}
