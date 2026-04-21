import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../reports/presentation/report_routes.dart';
import '../../settings/presentation/settings_routes.dart';
import 'app_shell_scaffold.dart';

/// Central navigation for the main app rail (string paths avoid circular imports).
void goAppShellSection(BuildContext context, AppShellSection section) {
  switch (section) {
    case AppShellSection.dashboard:
      context.go('/dashboard');
      return;
    case AppShellSection.reports:
      context.go(ReportRoutes.revenue);
      return;
    case AppShellSection.patients:
      context.go('/patients');
      return;
    case AppShellSection.appointments:
      context.go('/appointments');
      return;
    case AppShellSection.billing:
      context.go('/invoices');
      return;
    case AppShellSection.doctors:
      context.go('/doctors');
      return;
    case AppShellSection.services:
      context.go('/services');
      return;
    case AppShellSection.branches:
      context.go('/branches');
      return;
    case AppShellSection.settings:
      context.go(SettingsRoutes.overview);
      return;
  }
}
