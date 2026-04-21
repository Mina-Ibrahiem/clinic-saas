class AuthUser {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.roles,
    required this.permissions,
    this.tenantId,
    this.branchId,
    this.tenantName,
    this.branchName,
  });

  final int id;
  final String fullName;
  final String email;
  final List<String> roles;
  final List<String> permissions;
  final int? tenantId;
  final int? branchId;
  final String? tenantName;
  final String? branchName;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(Object? raw) {
      if (raw is List) {
        return raw.map((item) => item.toString()).toList(growable: false);
      }
      return const [];
    }

    return AuthUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fullName: (json['full_name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      roles: parseStringList(json['roles']),
      permissions: parseStringList(json['permissions']),
      tenantId: (json['tenant'] as Map?)?['id'] is num ? ((json['tenant'] as Map)['id'] as num).toInt() : null,
      branchId: (json['branch'] as Map?)?['id'] is num ? ((json['branch'] as Map)['id'] as num).toInt() : null,
      tenantName: (json['tenant'] as Map?)?['name']?.toString(),
      branchName: (json['branch'] as Map?)?['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'roles': roles,
      'permissions': permissions,
      'tenant': {
        'id': tenantId,
        'name': tenantName,
      },
      'branch': {
        'id': branchId,
        'name': branchName,
      },
    };
  }
}
