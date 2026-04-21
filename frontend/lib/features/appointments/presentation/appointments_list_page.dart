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
import 'appointment_details_page.dart';
import 'appointment_form_page.dart';
import 'controllers/appointments_list_controller.dart';

class AppointmentsListPage extends ConsumerStatefulWidget {
  const AppointmentsListPage({super.key});

  static const routePath = '/appointments';

  @override
  ConsumerState<AppointmentsListPage> createState() => _AppointmentsListPageState();
}

class _AppointmentsListPageState extends ConsumerState<AppointmentsListPage> {
  final _searchController = TextEditingController();
  final _doctorController = TextEditingController();
  final _patientController = TextEditingController();
  final _serviceController = TextEditingController();
  final _branchController = TextEditingController();

  String? _status;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void dispose() {
    _searchController.dispose();
    _doctorController.dispose();
    _patientController.dispose();
    _serviceController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _dateFrom != null && _dateTo != null ? DateTimeRange(start: _dateFrom!, end: _dateTo!) : null,
    );

    if (picked == null) return;
    setState(() {
      _dateFrom = picked.start;
      _dateTo = picked.end;
    });
    await ref.read(appointmentsListControllerProvider).applyFilters(
          dateFrom: picked.start,
          dateTo: picked.end,
        );
  }

  Future<void> _confirmDelete(int appointmentId) async {
    final controller = ref.read(appointmentsListControllerProvider);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.commonDelete),
          content: Text(context.l10n.appointmentsTitle),
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
    final success = await controller.deleteAppointment(appointmentId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? context.l10n.commonDelete : (controller.errorMessage ?? context.l10n.commonError)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = ref.watch(appointmentsListControllerProvider);
    final isDesktop = MediaQuery.sizeOf(context).width >= 980;
    final dateFormat = DateFormat('yyyy-MM-dd');
    final rangeLabel = _dateFrom == null || _dateTo == null
        ? l10n.commonDateRange
        : '${dateFormat.format(_dateFrom!)} - ${dateFormat.format(_dateTo!)}';

    return AppShellScaffold(
      title: l10n.appointmentsTitle,
      activeSection: AppShellSection.appointments,
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
                    l10n.appointmentsTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => context.push(AppointmentFormPage.createPath),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.appointmentsNew),
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
                      width: isDesktop ? 280 : 220,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: l10n.commonSearch,
                          hintText: l10n.commonSearch,
                          prefixIcon: const Icon(Icons.search_rounded),
                        ),
                        onSubmitted: (_) => controller.applyFilters(search: _searchController.text.trim()),
                      ),
                    ),
                    _idFilterField(controller: _doctorController, label: 'Doctor ID'),
                    _idFilterField(controller: _patientController, label: 'Patient ID'),
                    _idFilterField(controller: _serviceController, label: 'Service ID'),
                    _idFilterField(controller: _branchController, label: 'Branch ID'),
                    SizedBox(
                      width: 170,
                      child: DropdownButtonFormField<String?>(
                        initialValue: _status,
                        decoration: InputDecoration(labelText: l10n.commonStatus),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All')),
                          DropdownMenuItem(value: 'booked', child: Text('Booked')),
                          DropdownMenuItem(value: 'completed', child: Text('Completed')),
                          DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                          DropdownMenuItem(value: 'no_show', child: Text('No show')),
                        ],
                        onChanged: (value) {
                          setState(() => _status = value);
                          controller.applyFilters(status: value);
                        },
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _pickDateRange,
                      icon: const Icon(Icons.date_range_rounded),
                      label: Text(rangeLabel),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => controller.applyFilters(
                        search: _searchController.text.trim(),
                        doctorId: int.tryParse(_doctorController.text.trim()),
                        patientId: int.tryParse(_patientController.text.trim()),
                        serviceId: int.tryParse(_serviceController.text.trim()),
                        branchId: int.tryParse(_branchController.text.trim()),
                        status: _status,
                        dateFrom: _dateFrom,
                        dateTo: _dateTo,
                      ),
                      icon: const Icon(Icons.filter_alt_outlined),
                      label: Text(l10n.commonApply),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        _doctorController.clear();
                        _patientController.clear();
                        _serviceController.clear();
                        _branchController.clear();
                        setState(() {
                          _status = null;
                          _dateFrom = null;
                          _dateTo = null;
                        });
                        controller.applyFilters(
                          search: '',
                          doctorId: null,
                          patientId: null,
                          serviceId: null,
                          branchId: null,
                          status: null,
                          dateFrom: null,
                          dateTo: null,
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
                                        ? _DesktopAppointmentsTable(
                                            onView: (id) => context.push(AppointmentDetailsPage.pathFor(id)),
                                            onEdit: (id) => context.push(AppointmentFormPage.editPathFor(id)),
                                            onDelete: _confirmDelete,
                                          )
                                        : _MobileAppointmentsList(
                                            onView: (id) => context.push(AppointmentDetailsPage.pathFor(id)),
                                            onEdit: (id) => context.push(AppointmentFormPage.editPathFor(id)),
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

class _DesktopAppointmentsTable extends ConsumerWidget {
  const _DesktopAppointmentsTable({
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final void Function(int id) onView;
  final void Function(int id) onEdit;
  final void Function(int id) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appointmentsListControllerProvider);
    final dateFormat = DateFormat('yyyy-MM-dd');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Time')),
          DataColumn(label: Text('Patient')),
          DataColumn(label: Text('Doctor')),
          DataColumn(label: Text('Service')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final appointment in controller.items)
            DataRow(
              cells: [
                DataCell(Text(dateFormat.format(appointment.appointmentDate))),
                DataCell(Text('${appointment.startTime} - ${appointment.endTime}')),
                DataCell(Text(appointment.patient?.label ?? 'Patient #${appointment.patientId ?? '-'}')),
                DataCell(Text(appointment.doctor?.label ?? 'Doctor #${appointment.doctorId ?? '-'}')),
                DataCell(Text(appointment.service?.label ?? '-')),
                DataCell(_StatusChip(status: appointment.status)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined),
                        onPressed: () => onView(appointment.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => onEdit(appointment.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => onDelete(appointment.id),
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

class _MobileAppointmentsList extends ConsumerWidget {
  const _MobileAppointmentsList({
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final void Function(int id) onView;
  final void Function(int id) onEdit;
  final void Function(int id) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appointmentsListControllerProvider);
    final dateFormat = DateFormat('yyyy-MM-dd');

    return ListView.separated(
      itemCount: controller.items.length,
      padding: const EdgeInsets.all(12),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final appointment = controller.items[index];

        return Card(
          child: ListTile(
            title: Text(appointment.patient?.label ?? 'Patient #${appointment.patientId ?? '-'}'),
            subtitle: Text(
              '${dateFormat.format(appointment.appointmentDate)} • ${appointment.startTime}-${appointment.endTime}\n${appointment.doctor?.label ?? 'Doctor #${appointment.doctorId ?? '-'}'}',
            ),
            isThreeLine: true,
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    onView(appointment.id);
                    break;
                  case 'edit':
                    onEdit(appointment.id);
                    break;
                  case 'delete':
                    onDelete(appointment.id);
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
    final normalized = status.toLowerCase();
    final background = switch (normalized) {
      'completed' => scheme.primaryContainer,
      'cancelled' => scheme.errorContainer,
      'no_show' => scheme.secondaryContainer,
      _ => scheme.surfaceContainerHighest,
    };

    return Chip(
      label: Text(_prettyStatus(status)),
      visualDensity: VisualDensity.compact,
      backgroundColor: background,
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
          Icon(Icons.event_busy_outlined, size: 36, color: scheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            'No appointments found.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Try changing filters or create a new appointment.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

Widget _idFilterField({
  required TextEditingController controller,
  required String label,
}) {
  return SizedBox(
    width: 120,
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
    ),
  );
}

String _prettyStatus(String value) {
  return value
      .split('_')
      .map((part) => part.isEmpty ? part : part[0].toUpperCase() + part.substring(1))
      .join(' ');
}
