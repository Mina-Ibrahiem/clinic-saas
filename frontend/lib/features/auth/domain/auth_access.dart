import 'models/auth_user.dart';

extension AuthUserAccess on AuthUser? {
  bool get isSuperAdmin => this?.roles.contains('super_admin') ?? false;

  bool can(String permission) => isSuperAdmin || (this?.permissions.contains(permission) ?? false);

  bool get canManageBranches => can('branches.manage');
  bool get canViewBranches => can('branches.view') || canManageBranches;

  bool get canManageSettings => can('settings.manage');
  bool get canViewSettings => can('settings.view') || canManageSettings;
}
