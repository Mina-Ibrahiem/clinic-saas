/// Query/body scope for tenant-level vs branch-level settings (matches backend `SettingsService`).
class SettingsScope {
  const SettingsScope({
    this.tenantId,
    this.branchId,
  });

  /// Super-admin may target another tenant; others ignore this on the backend.
  final int? tenantId;

  /// `null` = tenant-wide defaults; non-null = branch overrides / resolved view.
  final int? branchId;

  Map<String, dynamic> toQueryParameters() {
    final map = <String, dynamic>{};
    if (tenantId != null) map['tenant_id'] = tenantId;
    if (branchId != null) map['branch_id'] = branchId;
    return map;
  }

  Map<String, dynamic> toBodyFields() => toQueryParameters();
}
