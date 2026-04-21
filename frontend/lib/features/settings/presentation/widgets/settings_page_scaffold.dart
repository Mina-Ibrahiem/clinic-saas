import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../app_shell/presentation/app_shell_navigation.dart';
import '../../../app_shell/presentation/app_shell_scaffold.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../settings_routes.dart';
import 'settings_scope_bar.dart';
import 'settings_top_nav.dart';

class SettingsPageScaffold extends ConsumerWidget {
  const SettingsPageScaffold({
    super.key,
    required this.title,
    required this.activeSection,
    required this.child,
  });

  final String title;
  final SettingsSection activeSection;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AppShellScaffold(
      title: l10n.settingsShellTitle,
      activeSection: AppShellSection.settings,
      onSectionSelected: (section) => goAppShellSection(context, section),
      onLogout: () => ref.read(authControllerProvider).logout(),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            GlassPanel(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SettingsTopNav(active: activeSection),
              ),
            ),
            const SizedBox(height: 12),
            GlassPanel(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SettingsScopeBar(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
