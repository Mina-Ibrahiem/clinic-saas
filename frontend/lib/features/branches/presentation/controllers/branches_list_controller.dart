import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/networking/api_exception.dart';
import '../../data/branches_repository.dart';
import '../../domain/models/branch.dart';
import '../../domain/models/branch_pagination.dart';
import '../../domain/models/branches_query.dart';

final branchesListControllerProvider = ChangeNotifierProvider.autoDispose<BranchesListController>((ref) {
  final controller = BranchesListController(ref);
  controller.load();
  return controller;
});

class BranchesListController extends ChangeNotifier {
  BranchesListController(this._ref);

  final Ref _ref;

  final List<Branch> items = [];
  BranchPagination pagination = const BranchPagination(
    currentPage: 1,
    perPage: 15,
    total: 0,
    lastPage: 1,
  );
  BranchesQuery query = const BranchesQuery();
  bool loading = false;
  String? errorMessage;

  Future<void> load({BranchesQuery? nextQuery}) async {
    if (nextQuery != null) {
      query = nextQuery;
    }

    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final page = await _ref.read(branchesRepositoryProvider).list(query);
      items
        ..clear()
        ..addAll(page.items);
      pagination = page.pagination;
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Failed to load branches.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(nextQuery: query.copyWith(page: 1));
  Future<void> goToPage(int page) => load(nextQuery: query.copyWith(page: page));

  Future<void> applyFilters({
    String? search,
    Object? status = _sentinel,
    String? sort,
  }) {
    return load(
      nextQuery: query.copyWith(
        search: search,
        status: status,
        sort: sort,
        page: 1,
      ),
    );
  }

  Future<bool> deleteBranch(int id) async {
    try {
      await _ref.read(branchesRepositoryProvider).delete(id);
      await load(nextQuery: query.copyWith(page: 1));
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = 'Failed to delete branch.';
      notifyListeners();
      return false;
    }
  }
}

const _sentinel = Object();
