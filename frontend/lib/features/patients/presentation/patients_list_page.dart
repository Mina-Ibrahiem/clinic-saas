import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../app_shell/presentation/app_shell_navigation.dart';
import '../../app_shell/presentation/app_shell_scaffold.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../../../shared/widgets/glass_panel.dart';
import 'controllers/patients_list_controller.dart';
import 'patient_details_page.dart';
import 'patient_form_page.dart';

class PatientsListPage extends ConsumerStatefulWidget {
  const PatientsListPage({super.key});

  static const routePath = '/patients';

  @override
  ConsumerState<PatientsListPage> createState() => _PatientsListPageState();
}

class _PatientsListPageState extends ConsumerState<PatientsListPage> {
  final _searchController = TextEditingController();
  final _branchController = TextEditingController();
  String? _gender;
  String? _status;

  @override
  void dispose() {
    _searchController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(int patientId, String name) async {
    final controller = ref.read(patientsListControllerProvider);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.patientsDeleteTitle),
          content: Text(context.l10n.patientsDeleteBody(name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.commonDelete),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;
    final success = await controller.deletePatient(patientId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? context.l10n.patientsDeleted : (controller.errorMessage ?? context.l10n.patientsDeleteFailed)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = ref.watch(patientsListControllerProvider);
    final isDesktop = MediaQuery.sizeOf(context).width >= 980;

    return AppShellScaffold(
      title: l10n.patientsTitle,
      activeSection: AppShellSection.patients,
      onSectionSelected: (section) => goAppShellSection(context, section),
      onLogout: () => ref.read(authControllerProvider).logout(),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.patientsTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => context.push(PatientFormPage.createPath),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.patientsNew),
                ),
              ],
            ).animate().fadeIn().slideY(begin: 0.02),
            const SizedBox(height: 16),
            GlassPanel(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: isDesktop ? 320 : 240,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: l10n.commonSearch,
                          hintText: l10n.patientsSearchHint,
                          prefixIcon: const Icon(Icons.search_rounded),
                        ),
                        onSubmitted: (_) => controller.applyFilters(search: _searchController.text.trim()),
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      child: DropdownButtonFormField<String?>(
                        initialValue: _gender,
                        decoration: InputDecoration(labelText: l10n.patientsGender),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All')),
                          DropdownMenuItem(value: 'male', child: Text('Male')),
                          DropdownMenuItem(value: 'female', child: Text('Female')),
                          DropdownMenuItem(value: 'other', child: Text('Other')),
                          DropdownMenuItem(value: 'unknown', child: Text('Unknown')),
                        ],
                        onChanged: (value) {
                          setState(() => _gender = value);
                          controller.applyFilters(gender: value);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      child: DropdownButtonFormField<String?>(
                        initialValue: _status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All')),
                          DropdownMenuItem(value: 'active', child: Text('Active')),
                          DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                        ],
                        onChanged: (value) {
                          setState(() => _status = value);
                          controller.applyFilters(status: value);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: TextField(
                        controller: _branchController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Branch ID',
                        ),
                        onSubmitted: (_) {
                          final parsed = int.tryParse(_branchController.text.trim());
                          controller.applyFilters(branchId: parsed);
                        },
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => controller.applyFilters(
                        search: _searchController.text.trim(),
                        gender: _gender,
                        status: _status,
                        branchId: int.tryParse(_branchController.text.trim()),
                      ),
                      icon: const Icon(Icons.filter_alt_outlined),
                      label: Text(l10n.commonApply),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        _branchController.clear();
                        setState(() {
                          _gender = null;
                          _status = null;
                        });
                        controller.applyFilters(
                          search: '',
                          gender: null,
                          status: null,
                          branchId: null,
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.commonReset),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GlassPanel(
                child: controller.loading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: AppListSkeleton(rows: 9),
                      )
                    : controller.errorMessage != null
                        ? _ErrorState(
                            message: controller.errorMessage!,
                            onRetry: controller.refresh,
                          )
                        : controller.items.isEmpty
                            ? const _EmptyState()
                            : Column(
                                children: [
                                  Expanded(
                                    child: isDesktop
                                        ? _DesktopPatientsTable(
                                            onView: (id) => context.push(PatientDetailsPage.pathFor(id)),
                                            onEdit: (id) => context.push(PatientFormPage.editPathFor(id)),
                                            onDelete: (id, name) => _confirmDelete(id, name),
                                          )
                                        : _MobilePatientsList(
                                            onView: (id) => context.push(PatientDetailsPage.pathFor(id)),
                                            onEdit: (id) => context.push(PatientFormPage.editPathFor(id)),
                                            onDelete: (id, name) => _confirmDelete(id, name),
                                          ),
                                  ),
                                  _PaginationBar(
                                    currentPage: controller.pagination.currentPage,
                                    lastPage: controller.pagination.lastPage,
                                    total: controller.pagination.total,
                                    onPageChanged: controller.goToPage,
                                  ),
                                ],
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopPatientsTable extends ConsumerWidget {
  const _DesktopPatientsTable({
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final void Function(int id) onView;
  final void Function(int id) onEdit;
  final void Function(int id, String name) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(patientsListControllerProvider);
    final dateFormat = DateFormat('yyyy-MM-dd');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Code')),
          DataColumn(label: Text('Full Name')),
          DataColumn(label: Text('Phone')),
          DataColumn(label: Text('Gender')),
          DataColumn(label: Text('DOB')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final patient in controller.items)
            DataRow(
              cells: [
                DataCell(Text(patient.patientCode)),
                DataCell(Text(patient.fullName)),
                DataCell(Text(patient.phone)),
                DataCell(Text(_capitalize(patient.gender))),
                DataCell(Text(patient.dateOfBirth != null ? dateFormat.format(patient.dateOfBirth!) : '-')),
                DataCell(_StatusChip(status: patient.status)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined),
                        onPressed: () => onView(patient.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => onEdit(patient.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => onDelete(patient.id, patient.fullName),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MobilePatientsList extends ConsumerWidget {
  const _MobilePatientsList({
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final void Function(int id) onView;
  final void Function(int id) onEdit;
  final void Function(int id, String name) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(patientsListControllerProvider);
    final dateFormat = DateFormat('yyyy-MM-dd');

    return ListView.separated(
      itemCount: controller.items.length,
      padding: const EdgeInsets.all(12),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final patient = controller.items[index];

        return Card(
          child: ListTile(
            title: Text(patient.fullName),
            subtitle: Text(
              '${patient.patientCode} • ${patient.phone}\nDOB: ${patient.dateOfBirth != null ? dateFormat.format(patient.dateOfBirth!) : '-'}',
            ),
            isThreeLine: true,
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    onView(patient.id);
                    break;
                  case 'edit':
                    onEdit(patient.id);
                    break;
                  case 'delete':
                    onDelete(patient.id, patient.fullName);
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'view', child: Text('View')),
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.onPageChanged,
  });

  final int currentPage;
  final int lastPage;
  final int total;
  final void Function(int page) onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Row(
        children: [
          Text('Total: $total'),
          const Spacer(),
          IconButton(
            onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Text('Page $currentPage / $lastPage'),
          IconButton(
            onPressed: currentPage < lastPage ? () => onPageChanged(currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = status == 'active';

    return Chip(
      label: Text(active ? 'Active' : _capitalize(status)),
      visualDensity: VisualDensity.compact,
      backgroundColor: active ? scheme.primaryContainer : scheme.surfaceContainerHighest,
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => onRetry(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline_rounded, size: 36, color: scheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            'No patients found.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Try changing filters or add a new patient.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}
