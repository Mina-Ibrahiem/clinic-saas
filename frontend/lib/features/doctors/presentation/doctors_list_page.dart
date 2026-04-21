import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../app_shell/presentation/app_shell_navigation.dart';
import '../../app_shell/presentation/app_shell_scaffold.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import 'controllers/doctors_list_controller.dart';
import 'doctor_details_page.dart';
import 'doctor_form_page.dart';

class DoctorsListPage extends ConsumerStatefulWidget {
  const DoctorsListPage({super.key});

  static const routePath = '/doctors';

  @override
  ConsumerState<DoctorsListPage> createState() => _DoctorsListPageState();
}

class _DoctorsListPageState extends ConsumerState<DoctorsListPage> {
  final _searchController = TextEditingController();
  final _specializationController = TextEditingController();
  final _branchController = TextEditingController();
  String? _status;

  @override
  void dispose() {
    _searchController.dispose();
    _specializationController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(int doctorId, String name) async {
    final controller = ref.read(doctorsListControllerProvider);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete doctor?'),
        content: Text('This will soft-delete "$name".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;
    final success = await controller.deleteDoctor(doctorId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Doctor deleted.' : (controller.errorMessage ?? 'Delete failed.'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = ref.watch(doctorsListControllerProvider);
    final isDesktop = MediaQuery.sizeOf(context).width >= 980;

    return AppShellScaffold(
      title: l10n.doctorsTitle,
      activeSection: AppShellSection.doctors,
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
                    l10n.doctorsTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => context.push(DoctorFormPage.createPath),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.doctorsNew),
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
                  children: [
                    SizedBox(
                      width: isDesktop ? 300 : 220,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: l10n.commonSearch,
                          hintText: 'Name, code, specialization, email',
                          prefixIcon: const Icon(Icons.search_rounded),
                        ),
                        onSubmitted: (_) => controller.applyFilters(search: _searchController.text.trim()),
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: TextField(
                        controller: _specializationController,
                        decoration: const InputDecoration(labelText: 'Specialization'),
                        onSubmitted: (_) => controller.applyFilters(
                          specialization: _specializationController.text.trim(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: TextField(
                        controller: _branchController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Branch ID'),
                        onSubmitted: (_) => controller.applyFilters(
                          branchId: int.tryParse(_branchController.text.trim()),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      child: DropdownButtonFormField<String?>(
                        initialValue: _status,
                        decoration: InputDecoration(labelText: l10n.commonStatus),
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
                    OutlinedButton.icon(
                      onPressed: () => controller.applyFilters(
                        search: _searchController.text.trim(),
                        specialization: _specializationController.text.trim(),
                        branchId: int.tryParse(_branchController.text.trim()),
                        status: _status,
                      ),
                      icon: const Icon(Icons.filter_alt_outlined),
                      label: Text(l10n.commonApply),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        _specializationController.clear();
                        _branchController.clear();
                        setState(() => _status = null);
                        controller.applyFilters(
                          search: '',
                          specialization: null,
                          branchId: null,
                          status: null,
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
                    ? const Center(child: CircularProgressIndicator())
                    : controller.errorMessage != null
                        ? _ErrorState(message: controller.errorMessage!, onRetry: controller.refresh)
                        : controller.items.isEmpty
                            ? const _EmptyState()
                            : Column(
                                children: [
                                  Expanded(
                                    child: isDesktop
                                        ? _DesktopDoctorsTable(
                                            onView: (id) => context.push(DoctorDetailsPage.pathFor(id)),
                                            onEdit: (id) => context.push(DoctorFormPage.editPathFor(id)),
                                            onDelete: _confirmDelete,
                                          )
                                        : _MobileDoctorsList(
                                            onView: (id) => context.push(DoctorDetailsPage.pathFor(id)),
                                            onEdit: (id) => context.push(DoctorFormPage.editPathFor(id)),
                                            onDelete: _confirmDelete,
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

class _DesktopDoctorsTable extends ConsumerWidget {
  const _DesktopDoctorsTable({
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final void Function(int id) onView;
  final void Function(int id) onEdit;
  final void Function(int id, String name) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(doctorsListControllerProvider);
    final currency = NumberFormat.currency(symbol: 'AED ');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Doctor Code')),
          DataColumn(label: Text('Specialization')),
          DataColumn(label: Text('License')),
          DataColumn(label: Text('Fee')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final doctor in controller.items)
            DataRow(
              cells: [
                DataCell(Text(doctor.fullName)),
                DataCell(Text(doctor.doctorCode ?? '-')),
                DataCell(Text(doctor.specialization)),
                DataCell(Text(doctor.licenseNumber ?? '-')),
                DataCell(Text(doctor.consultationFee != null ? currency.format(doctor.consultationFee) : '-')),
                DataCell(_StatusChip(status: doctor.status)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined),
                        onPressed: () => onView(doctor.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => onEdit(doctor.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => onDelete(doctor.id, doctor.fullName),
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

class _MobileDoctorsList extends ConsumerWidget {
  const _MobileDoctorsList({
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final void Function(int id) onView;
  final void Function(int id) onEdit;
  final void Function(int id, String name) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(doctorsListControllerProvider);

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: controller.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final doctor = controller.items[index];
        return Card(
          child: ListTile(
            title: Text(doctor.fullName),
            subtitle: Text('${doctor.specialization}\n${doctor.doctorCode ?? '-'}'),
            isThreeLine: true,
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    onView(doctor.id);
                    break;
                  case 'edit':
                    onEdit(doctor.id);
                    break;
                  case 'delete':
                    onDelete(doctor.id, doctor.fullName);
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
    return Chip(
      label: Text(_capitalize(status)),
      visualDensity: VisualDensity.compact,
      backgroundColor: status == 'active' ? scheme.primaryContainer : scheme.surfaceContainerHighest,
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
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
          Icon(Icons.medical_services_outlined, size: 36, color: scheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text('No doctors found.', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Try changing filters or create a new doctor.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
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
