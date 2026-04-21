import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../settings_routes.dart';

class SettingsTopNav extends StatelessWidget {
  const SettingsTopNav({
    super.key,
    required this.active,
  });

  final SettingsSection active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    Widget chip(String label, SettingsSection section, String path) {
      final selected = active == section;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => context.go(path),
          selectedColor: scheme.primaryContainer,
          checkmarkColor: scheme.onPrimaryContainer,
        ),
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        chip(l10n.settingsNavOverview, SettingsSection.overview, SettingsRoutes.overview),
        chip(l10n.settingsNavGeneral, SettingsSection.general, SettingsRoutes.general),
        chip(l10n.settingsNavClinicProfile, SettingsSection.clinicProfile, SettingsRoutes.clinicProfile),
        chip(l10n.settingsNavInvoice, SettingsSection.invoice, SettingsRoutes.invoice),
      ],
    );
  }
}
