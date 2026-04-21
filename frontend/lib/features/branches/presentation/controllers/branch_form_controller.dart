import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/networking/api_exception.dart';
import '../../data/branches_repository.dart';
import '../../domain/models/branch.dart';
import '../../domain/models/branch_upsert_payload.dart';

final branchFormControllerProvider = ChangeNotifierProvider.autoDispose<BranchFormController>((ref) {
  return BranchFormController(ref);
});

class BranchFormController extends ChangeNotifier {
  BranchFormController(this._ref);

  final Ref _ref;
  bool submitting = false;
  String? errorMessage;

  Future<Branch?> create(BranchUpsertPayload payload) async {
    return _run(() => _ref.read(branchesRepositoryProvider).create(payload));
  }

  Future<Branch?> update({
    required int branchId,
    required BranchUpsertPayload payload,
  }) async {
    return _run(() => _ref.read(branchesRepositoryProvider).update(id: branchId, payload: payload));
  }

  Future<Branch?> _run(Future<Branch> Function() action) async {
    submitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      return await action();
    } on ApiException catch (error) {
      errorMessage = error.message;
      return null;
    } catch (_) {
      errorMessage = 'Failed to save branch.';
      return null;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }
}
