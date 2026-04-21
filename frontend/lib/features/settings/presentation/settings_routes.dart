abstract final class SettingsRoutes {
  static const overview = '/settings';
  static const general = '/settings/general';
  static const clinicProfile = '/settings/clinic-profile';
  static const invoice = '/settings/invoice';
}

enum SettingsSection {
  overview,
  general,
  clinicProfile,
  invoice,
}

SettingsSection settingsSectionFromLocation(String location) {
  if (location.startsWith(SettingsRoutes.general)) return SettingsSection.general;
  if (location.startsWith(SettingsRoutes.clinicProfile)) return SettingsSection.clinicProfile;
  if (location.startsWith(SettingsRoutes.invoice)) return SettingsSection.invoice;
  return SettingsSection.overview;
}
