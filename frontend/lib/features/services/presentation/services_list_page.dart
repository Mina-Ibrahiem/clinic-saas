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
import 'controllers/services_list_controller.dart';
import 'service_details_page.dart';
import 'service_form_page.dart';

class ServicesListPage extends ConsumerStatefulWidget {
  const ServicesListPage({super.key});

  static const routePath = '/services';

  @override
  ConsumerState<ServicesListPage> createState() => _ServicesListPageState();
}

class _ServicesListPageState extends ConsumerState<ServicesListPage> {
  final _searchController = TextEditingController();
  final _branchController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  String? _status;

  @override
  void dispose() {
    _searchController.dispose();
    _branchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(int serviceId, String name) async {
    final controller = ref.read(servicesListControllerProvider);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete service?'),
        content: Text('Delete "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;
    final success = await controller.deleteService(serviceId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Service deleted.' : (controller.errorMessage ?? 'Delete failed.'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = ref.watch(servicesListControllerProvider);
    final isDesktop = MediaQuery.sizeOf(context).width >= 980;
    final currency = NumberFormat.currency(symbol: 'AED ');

    return AppShellScaffold(
      title: l10n.servicesTitle,
      activeSection: AppShellSection.services,
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
                    l10n.servicesTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => context.push(ServiceFormPage.createPath),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.servicesNew),
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
                      width: isDesktop ? 280 : 220,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: l10n.commonSearch,
                          hintText: 'Name, code, description',
                          prefixIcon: const Icon(Icons.search_rounded),
                        ),
                        onSubmitted: (_) => controller.applyFilters(search: _searchController.text.trim()),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: TextField(
                        controller: _branchController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Branch ID'),
                        onSubmitted: (_) => controller.applyFilters(branchId: int.tryParse(_branchController.text.trim())),
                      ),
                    ),
                    SizedBox(
                      width: 130,
                      child: TextField(
                        controller: _minPriceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Min price'),
                      ),
                    ),
                    SizedBox(
                      width: 130,
                      child: TextField(
                        controller: _maxPriceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Max price'),
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
                        branchId: int.tryParse(_branchController.text.trim()),
                        minPrice: double.tryParse(_minPriceController.text.trim()),
                        maxPrice: double.tryParse(_maxPriceController.text.trim()),
                        status: _status,
                      ),
                      icon: const Icon(Icons.filter_alt_outlined),
                      label: Text(l10n.commonApply),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        _branchController.clear();
                        _minPriceController.clear();
                        _maxPriceController.clear();
                        setState(() => _status = null);
                        controller.applyFilters(
                          search: '',
                          branchId: null,
                          minPrice: null,
                          maxPrice: null,
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
                                        ? _DesktopServicesTable(
                                            onView: (id) => context.push(ServiceDetailsPage.pathFor(id)),
                                            onEdit: (id) => context.push(ServiceFormPage.editPathFor(id)),
                                            onDelete: _confirmDelete,
                                            currency: currency,
                                          )
                                        : _MobileServicesList(
                                            onView: (id) => context.push(ServiceDetailsPage.pathFor(id)),
                                            onEdit: (id) => context.push(ServiceFormPage.editPathFor(id)),
                                            onDelete: _confirmDelete,
                                            currency: currency,
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

class _DesktopServicesTable extends ConsumerWidget {
  const _DesktopServicesTable({
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.currency,
  });

  final void Function(int id) onView;
  final void Function(int id) onEdit;
  final void Function(int id, String name) onDelete;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(servicesListControllerProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Code')),
          DataColumn(label: Text('Price')),
          DataColumn(label: Text('Duration')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final service in controller.items)
            DataRow(
              cells: [
                DataCell(Text(service.name)),
                DataCell(Text(service.code ?? '-')),
                DataCell(Text(currency.format(service.price))),
                DataCell(Text(service.durationMinutes?.toString() ?? '-')),
                DataCell(_StatusChip(status: service.status)),
                DataCell(
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.visibility_outlined), onPressed: () => onView(service.id)),
                      IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => onEdit(service.id)),
                      IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => onDelete(service.id, service.name)),
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

class _MobileServicesList extends ConsumerWidget {
  const _MobileServicesList({
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.currency,
  });

  final void Function(int id) onView;
  final void Function(int id) onEdit;
  final void Function(int id, String name) onDelete;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(servicesListControllerProvider);
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: controller.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final service = controller.items[index];
        return Card(
          child: ListTile(
            title: Text(service.name),
            subtitle: Text('${currency.format(service.price)} • ${service.durationMinutes ?? '-'} min'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    onView(service.id);
                    break;
                  case 'edit':
                    onEdit(service.id);
                    break;
                  case 'delete':
                    onDelete(service.id, service.name);
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
          Icon(Icons.widgets_outlined, size: 36, color: scheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text('No services found.', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Try changing filters or create a new service.',
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
