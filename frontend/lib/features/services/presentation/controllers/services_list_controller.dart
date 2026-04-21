import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/networking/api_exception.dart';
import '../../data/services_repository.dart';
import '../../domain/models/service.dart';
import '../../domain/models/service_pagination.dart';
import '../../domain/models/services_query.dart';

final servicesListControllerProvider = ChangeNotifierProvider.autoDispose<ServicesListController>((ref) {
  final controller = ServicesListController(ref);
  controller.load();
  return controller;
});

class ServicesListController extends ChangeNotifier {
  ServicesListController(this._ref);

  final Ref _ref;

  final List<Service> items = [];
  ServicePagination pagination = const ServicePagination(
    currentPage: 1,
    perPage: 12,
    total: 0,
    lastPage: 1,
  );
  ServicesQuery query = const ServicesQuery();
  bool loading = false;
  String? errorMessage;

  Future<void> load({ServicesQuery? nextQuery}) async {
    if (nextQuery != null) {
      query = nextQuery;
    }

    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final page = await _ref.read(servicesRepositoryProvider).list(query);
      items
        ..clear()
        ..addAll(page.items);
      pagination = page.pagination;
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Failed to load services.';
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
    Object? branchId = _sentinel,
    Object? minPrice = _sentinel,
    Object? maxPrice = _sentinel,
    String? sort,
  }) {
    return load(
      nextQuery: query.copyWith(
        search: search,
        status: status,
        branchId: branchId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sort: sort,
        page: 1,
      ),
    );
  }

  Future<bool> deleteService(int id) async {
    try {
      await _ref.read(servicesRepositoryProvider).delete(id);
      await load(nextQuery: query.copyWith(page: 1));
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = 'Failed to delete service.';
      notifyListeners();
      return false;
    }
  }
}

const _sentinel = Object();
