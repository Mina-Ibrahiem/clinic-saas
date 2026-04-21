import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/branches_repository.dart';
import '../../domain/models/branch.dart';

final branchDetailsProvider = FutureProvider.autoDispose.family<Branch, int>((ref, id) async {
  return ref.read(branchesRepositoryProvider).getById(id);
});
