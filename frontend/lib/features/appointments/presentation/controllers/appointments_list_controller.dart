import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/networking/api_exception.dart';
import '../../data/appointments_repository.dart';
import '../../domain/models/appointment.dart';
import '../../domain/models/appointment_pagination.dart';
import '../../domain/models/appointments_query.dart';

final appointmentsListControllerProvider = ChangeNotifierProvider.autoDispose<AppointmentsListController>((ref) {
  final controller = AppointmentsListController(ref);
  controller.load();
  return controller;
});

class AppointmentsListController extends ChangeNotifier {
  AppointmentsListController(this._ref);

  final Ref _ref;

  final List<Appointment> items = [];
  AppointmentPagination pagination = const AppointmentPagination(
    currentPage: 1,
    perPage: 12,
    total: 0,
    lastPage: 1,
  );
  AppointmentsQuery query = const AppointmentsQuery();
  bool loading = false;
  String? errorMessage;

  Future<void> load({AppointmentsQuery? nextQuery}) async {
    if (nextQuery != null) {
      query = nextQuery;
    }

    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final page = await _ref.read(appointmentsRepositoryProvider).list(query);
      items
        ..clear()
        ..addAll(page.items);
      pagination = page.pagination;
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Failed to load appointments.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(nextQuery: query.copyWith(page: 1));

  Future<void> goToPage(int page) => load(nextQuery: query.copyWith(page: page));

  Future<void> applyFilters({
    String? search,
    Object? doctorId = _sentinel,
    Object? patientId = _sentinel,
    Object? serviceId = _sentinel,
    Object? status = _sentinel,
    Object? branchId = _sentinel,
    Object? appointmentDate = _sentinel,
    Object? dateFrom = _sentinel,
    Object? dateTo = _sentinel,
    String? sort,
  }) {
    return load(
      nextQuery: query.copyWith(
        search: search,
        doctorId: doctorId,
        patientId: patientId,
        serviceId: serviceId,
        status: status,
        branchId: branchId,
        appointmentDate: appointmentDate,
        dateFrom: dateFrom,
        dateTo: dateTo,
        sort: sort,
        page: 1,
      ),
    );
  }

  Future<bool> deleteAppointment(int id) async {
    try {
      await _ref.read(appointmentsRepositoryProvider).delete(id);
      await load(nextQuery: query.copyWith(page: 1));
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = 'Failed to delete appointment.';
      notifyListeners();
      return false;
    }
  }
}

const _sentinel = Object();
