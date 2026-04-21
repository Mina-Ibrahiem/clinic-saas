import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/services/data/services_repository.dart';
import '../../features/services/domain/models/services_query.dart';
import 'reference_option.dart';

final serviceReferenceOptionsProvider =
    FutureProvider.autoDispose.family<List<ReferenceOption>, String>((ref, search) async {
  final page = await ref.read(servicesRepositoryProvider).list(
        ServicesQuery(
          search: search.trim(),
          status: 'active',
          perPage: 30,
        ),
      );

  return page.items
      .map(
        (service) => ReferenceOption(
          id: service.id,
          label: service.name,
          subtitle: [service.code, 'AED ${service.price.toStringAsFixed(2)}']
              .whereType<String>()
              .where((value) => value.isNotEmpty)
              .join(' • '),
        ),
      )
      .toList(growable: false);
});
