class BranchTenantRef {
  const BranchTenantRef({
    required this.id,
    this.uuid,
    this.name,
    this.slug,
  });

  final int id;
  final String? uuid;
  final String? name;
  final String? slug;

  factory BranchTenantRef.fromJson(Map<String, dynamic> json) {
    return BranchTenantRef(
      id: (json['id'] as num?)?.toInt() ?? 0,
      uuid: json['uuid'] as String?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
    );
  }
}
