import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/networking/api_exception.dart';
import '../../data/patients_repository.dart';
import '../../domain/models/patient.dart';
import '../../domain/models/patient_pagination.dart';
import '../../domain/models/patients_query.dart';

final patientsListControllerProvider = ChangeNotifierProvider.autoDispose<PatientsListController>((ref) {
  final controller = PatientsListController(ref);
  controller.load();
  return controller;
});

class PatientsListController extends ChangeNotifier {
  PatientsListController(this._ref);

  final Ref _ref;

  final List<Patient> items = [];
  PatientPagination pagination = const PatientPagination(
    currentPage: 1,
    perPage: 12,
    total: 0,
    lastPage: 1,
  );
  PatientsQuery query = const PatientsQuery();
  bool loading = false;
  String? errorMessage;

  Future<void> load({PatientsQuery? nextQuery}) async {
    if (nextQuery != null) {
      query = nextQuery;
    }

    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final page = await _ref.read(patientsRepositoryProvider).list(query);
      items
        ..clear()
        ..addAll(page.items);
      pagination = page.pagination;
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Failed to load patients.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(nextQuery: query.copyWith(page: 1));

  Future<void> goToPage(int page) => load(nextQuery: query.copyWith(page: page));

  Future<void> applyFilters({
    String? search,
    Object? gender = _sentinel,
    Object? status = _sentinel,
    Object? branchId = _sentinel,
    String? sort,
  }) {
    return load(
      nextQuery: query.copyWith(
        search: search,
        gender: gender,
        status: status,
        branchId: branchId,
        sort: sort,
        page: 1,
      ),
    );
  }

  Future<bool> deletePatient(int id) async {
    try {
      await _ref.read(patientsRepositoryProvider).delete(id);
      await load(nextQuery: query.copyWith(page: 1));
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = 'Failed to delete patient.';
      notifyListeners();
      return false;
    }
  }
}

const _sentinel = Object();
