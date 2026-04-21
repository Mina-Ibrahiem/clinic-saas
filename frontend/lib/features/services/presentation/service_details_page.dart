import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/glass_panel.dart';
import '../domain/models/service.dart';
import 'controllers/service_details_provider.dart';
import 'service_form_page.dart';

class ServiceDetailsPage extends ConsumerWidget {
  const ServiceDetailsPage({
    super.key,
    required this.serviceId,
  });

  final int serviceId;

  static String pathFor(int id) => '/services/$id';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(serviceDetailsProvider(serviceId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit',
            onPressed: () => context.push(ServiceFormPage.editPathFor(serviceId)),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: state.when(
          data: (service) => _DetailsCard(service: service),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Failed to load service.\n$error')),
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.service});
  final Service service;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'AED ');
    final rows = <({String title, String value})>[
      (title: 'Name', value: service.name),
      (title: 'Code', value: service.code ?? '-'),
      (title: 'Description', value: service.description ?? '-'),
      (title: 'Price', value: currency.format(service.price)),
      (title: 'Duration Minutes', value: service.durationMinutes?.toString() ?? '-'),
      (title: 'Status', value: _capitalize(service.status)),
      (title: 'Branch', value: service.branch?.label ?? (service.branchId?.toString() ?? '-')),
      (title: 'Tenant', value: service.tenant?.label ?? (service.tenantId?.toString() ?? '-')),
      (title: 'Appointments Count', value: (service.appointmentsCount ?? 0).toString()),
      (title: 'Invoice Items Count', value: (service.invoiceItemsCount ?? 0).toString()),
    ];

    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 900;
            if (!wide) {
              return Column(children: [for (final row in rows) _DetailRow(title: row.title, value: row.value)]);
            }

            final mid = (rows.length / 2).ceil();
            final left = rows.take(mid).toList();
            final right = rows.skip(mid).toList();

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Column(children: [for (final row in left) _DetailRow(title: row.title, value: row.value)])),
                const SizedBox(width: 20),
                Expanded(child: Column(children: [for (final row in right) _DetailRow(title: row.title, value: row.value)])),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
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
