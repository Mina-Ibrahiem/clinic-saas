import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/branches/data/branches_repository.dart';
import '../../features/branches/domain/models/branches_query.dart';
import 'reference_option.dart';

final branchReferenceOptionsProvider =
    FutureProvider.autoDispose.family<List<ReferenceOption>, String>((ref, search) async {
  final page = await ref.read(branchesRepositoryProvider).list(
        BranchesQuery(
          search: search.trim(),
          perPage: 30,
        ),
      );

  return page.items
      .map(
        (b) => ReferenceOption(
          id: b.id,
          label: b.name,
          subtitle: [b.code, b.status].whereType<String>().where((s) => s.isNotEmpty).join(' · '),
        ),
      )
      .toList(growable: false);
});
