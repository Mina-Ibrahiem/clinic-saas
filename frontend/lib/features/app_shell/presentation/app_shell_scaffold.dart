import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/theme/theme_controller.dart';
import '../../auth/presentation/controllers/auth_controller.dart';

enum AppShellSection {
  dashboard,
  reports,
  patients,
  appointments,
  billing,
  doctors,
  services,
  branches,
  settings,
}

class AppShellScaffold extends ConsumerWidget {
  const AppShellScaffold({
    super.key,
    required this.title,
    required this.child,
    required this.activeSection,
    required this.onSectionSelected,
    this.onLogout,
  });

  final String title;
  final Widget child;
  final AppShellSection activeSection;
  final void Function(AppShellSection section) onSectionSelected;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 980;
    final scheme = Theme.of(context).colorScheme;
    final user = ref.watch(authControllerProvider).user;

    final side = NavigationRail(
      selectedIndex: activeSection.index,
      minWidth: 80,
      onDestinationSelected: (index) => onSectionSelected(AppShellSection.values[index]),
      destinations: [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: Text(l10n.navDashboard),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.insights_outlined),
          selectedIcon: Icon(Icons.insights_rounded),
          label: Text(l10n.navReports),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people_outline_rounded),
          selectedIcon: Icon(Icons.people_rounded),
          label: Text(l10n.navPatients),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.event_note_outlined),
          selectedIcon: Icon(Icons.event_note_rounded),
          label: Text(l10n.navAppointments),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long_rounded),
          label: Text(l10n.navBilling),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.local_hospital_outlined),
          selectedIcon: Icon(Icons.local_hospital_rounded),
          label: Text(l10n.navDoctors),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.widgets_outlined),
          selectedIcon: Icon(Icons.widgets_rounded),
          label: Text(l10n.navServices),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.account_tree_outlined),
          selectedIcon: Icon(Icons.account_tree_rounded),
          label: Text(l10n.navBranches),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.tune_outlined),
          selectedIcon: Icon(Icons.tune_rounded),
          label: Text(l10n.navSettings),
        ),
      ],
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              l10n.appTitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop) ...[
            side,
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ],
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    border: Border(
                      bottom: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (!isDesktop)
                        Builder(
                          builder: (context) => IconButton(
                            onPressed: () => Scaffold.of(context).openDrawer(),
                            icon: const Icon(Icons.menu_rounded),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        offset: const Offset(0, 44),
                        tooltip: l10n.commonAccount,
                        onSelected: (value) {
                          if (value == 'logout') {
                            onLogout?.call();
                          } else if (value == 'theme') {
                            ref.read(themeModeProvider.notifier).toggle();
                          } else if (value == 'lang_en') {
                            ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                          } else if (value == 'lang_ar') {
                            ref.read(localeProvider.notifier).setLocale(const Locale('ar'));
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            enabled: false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.fullName ?? l10n.commonSignedIn,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  user?.email ?? '',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'theme',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.brightness_6_outlined, size: 22),
                              title: Text(l10n.commonToggleTheme),
                            ),
                          ),
                          PopupMenuItem(
                            enabled: false,
                            child: Text(
                              l10n.commonLanguage,
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'lang_en',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.language_rounded, size: 22),
                              title: Text(l10n.commonLanguageEnglish),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'lang_ar',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.translate_rounded, size: 22),
                              title: Text(l10n.commonLanguageArabic),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'logout',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.logout_rounded, size: 22, color: Theme.of(context).colorScheme.error),
                              title: Text(
                                l10n.commonLogout,
                                style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: scheme.primaryContainer,
                                foregroundColor: scheme.onPrimaryContainer,
                                child: Text(
                                  _userInitials(user?.fullName ?? user?.email ?? '?'),
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                              ),
                              if (isDesktop) ...[
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      user?.fullName ?? l10n.commonUser,
                                      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      user?.email ?? '',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                                Icon(Icons.expand_more_rounded, color: scheme.onSurfaceVariant, size: 20),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
      drawer: isDesktop ? null : Drawer(child: SafeArea(child: side)),
    );
  }
}

String _userInitials(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '?';
  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  if (trimmed.length >= 2) {
    return trimmed.substring(0, 2).toUpperCase();
  }
  return trimmed[0].toUpperCase();
}
