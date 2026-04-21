import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../app_shell/presentation/app_shell_navigation.dart';
import '../../app_shell/presentation/app_shell_scaffold.dart';
import '../../auth/domain/auth_access.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../domain/models/branch.dart';
import '../domain/models/branch_pagination.dart';
import 'branch_details_page.dart';
import 'branch_form_page.dart';
import 'branch_routes.dart';
import 'controllers/branches_list_controller.dart';

class BranchesListPage extends ConsumerStatefulWidget {
  const BranchesListPage({super.key});

  static const routePath = BranchRoutes.list;

  @override
  ConsumerState<BranchesListPage> createState() => _BranchesListPageState();
}

class _BranchesListPageState extends ConsumerState<BranchesListPage> {
  final _searchController = TextEditingController();
  String? _status;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(int branchId, String name) async {
    final controller = ref.read(branchesListControllerProvider);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete branch?'),
        content: Text('This will remove "$name" if no operational data is linked.'),
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
    final success = await controller.deleteBranch(branchId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Branch deleted.' : (controller.errorMessage ?? 'Delete failed.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = ref.watch(branchesListControllerProvider);
    final user = ref.watch(authControllerProvider).user;
    final isDesktop = MediaQuery.sizeOf(context).width >= 980;
    final canManage = user.canManageBranches;

    return AppShellScaffold(
      title: l10n.branchesTitle,
      activeSection: AppShellSection.branches,
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
                    l10n.branchesTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (canManage)
                  FilledButton.icon(
                    onPressed: () => context.push(BranchFormPage.createPath),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.branchesNew),
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
                          hintText: 'Name, code, phone, email',
                          prefixIcon: const Icon(Icons.search_rounded),
                        ),
                        onSubmitted: (_) => controller.applyFilters(search: _searchController.text.trim()),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<String>(
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
                    FilledButton.tonalIcon(
                      onPressed: () => controller.applyFilters(
                        search: _searchController.text.trim(),
                        status: _status,
                      ),
                      icon: const Icon(Icons.filter_alt_outlined),
                      label: Text(l10n.commonApply),
                    ),
                    IconButton.filledTonal(
                      tooltip: l10n.commonRefresh,
                      onPressed: () => controller.refresh(),
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GlassPanel(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: controller.loading
                      ? const Center(child: CircularProgressIndicator())
                      : controller.errorMessage != null
                          ? _ErrorState(
                              message: controller.errorMessage!,
                              onRetry: () => controller.refresh(),
                            )
                          : controller.items.isEmpty
                              ? const _EmptyState()
                              : isDesktop
                                  ? _DesktopTable(
                                      branches: controller.items,
                                      canManage: canManage,
                                      onView: (id) => context.push(BranchDetailsPage.pathFor(id)),
                                      onEdit: (id) => context.push(BranchFormPage.editPathFor(id)),
                                      onDelete: canManage ? _confirmDelete : null,
                                    )
                                  : _MobileList(
                                      branches: controller.items,
                                      canManage: canManage,
                                      onView: (id) => context.push(BranchDetailsPage.pathFor(id)),
                                      onEdit: (id) => context.push(BranchFormPage.editPathFor(id)),
                                      onDelete: canManage ? _confirmDelete : null,
                                    ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _PaginationBar(
              pagination: controller.pagination,
              onPage: (p) => controller.goToPage(p),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopTable extends StatelessWidget {
  const _DesktopTable({
    required this.branches,
    required this.canManage,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Branch> branches;
  final bool canManage;
  final void Function(int id) onView;
  final void Function(int id) onEdit;
  final Future<void> Function(int id, String name)? onDelete;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Code')),
          DataColumn(label: Text('Phone')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Linked')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final b in branches)
            DataRow(
              cells: [
                DataCell(Text(b.name)),
                DataCell(Text(b.code ?? '—')),
                DataCell(Text(b.phone ?? '—')),
                DataCell(Text(b.email ?? '—')),
                DataCell(_StatusChip(status: b.status)),
                DataCell(Text(b.stats?.totalLinked.toString() ?? '0')),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined),
                        onPressed: () => onView(b.id),
                      ),
                      if (canManage) ...[
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => onEdit(b.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: onDelete == null ? null : () => onDelete!(b.id, b.name),
                        ),
                      ],
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

class _MobileList extends StatelessWidget {
  const _MobileList({
    required this.branches,
    required this.canManage,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Branch> branches;
  final bool canManage;
  final void Function(int id) onView;
  final void Function(int id) onEdit;
  final Future<void> Function(int id, String name)? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: branches.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final b = branches[index];
        return ListTile(
          title: Text(b.name),
          subtitle: Text('${b.code ?? '—'} · ${_capitalize(b.status)}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () => onView(b.id),
              ),
            ],
          ),
          onTap: () => onView(b.id),
        );
      },
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.pagination,
    required this.onPage,
  });

  final BranchPagination pagination;
  final void Function(int page) onPage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          'Page ${pagination.currentPage} of ${pagination.lastPage} · ${pagination.total} total',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const Spacer(),
        FilledButton.tonal(
          onPressed: pagination.currentPage > 1 ? () => onPage(pagination.currentPage - 1) : null,
          child: const Text('Prev'),
        ),
        const SizedBox(width: 8),
        FilledButton.tonal(
          onPressed: pagination.currentPage < pagination.lastPage
              ? () => onPage(pagination.currentPage + 1)
              : null,
          child: const Text('Next'),
        ),
      ],
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
          Icon(Icons.account_tree_outlined, size: 36, color: scheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text('No branches found.', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}
