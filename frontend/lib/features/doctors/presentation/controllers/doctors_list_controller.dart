import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/networking/api_exception.dart';
import '../../data/doctors_repository.dart';
import '../../domain/models/doctor.dart';
import '../../domain/models/doctor_pagination.dart';
import '../../domain/models/doctors_query.dart';

final doctorsListControllerProvider = ChangeNotifierProvider.autoDispose<DoctorsListController>((ref) {
  final controller = DoctorsListController(ref);
  controller.load();
  return controller;
});

class DoctorsListController extends ChangeNotifier {
  DoctorsListController(this._ref);

  final Ref _ref;

  final List<Doctor> items = [];
  DoctorPagination pagination = const DoctorPagination(
    currentPage: 1,
    perPage: 12,
    total: 0,
    lastPage: 1,
  );
  DoctorsQuery query = const DoctorsQuery();
  bool loading = false;
  String? errorMessage;

  Future<void> load({DoctorsQuery? nextQuery}) async {
    if (nextQuery != null) {
      query = nextQuery;
    }

    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final page = await _ref.read(doctorsRepositoryProvider).list(query);
      items
        ..clear()
        ..addAll(page.items);
      pagination = page.pagination;
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Failed to load doctors.';
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
    Object? specialization = _sentinel,
    String? sort,
  }) {
    return load(
      nextQuery: query.copyWith(
        search: search,
        status: status,
        branchId: branchId,
        specialization: specialization,
        sort: sort,
        page: 1,
      ),
    );
  }

  Future<bool> deleteDoctor(int id) async {
    try {
      await _ref.read(doctorsRepositoryProvider).delete(id);
      await load(nextQuery: query.copyWith(page: 1));
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = 'Failed to delete doctor.';
      notifyListeners();
      return false;
    }
  }
}

const _sentinel = Object();
