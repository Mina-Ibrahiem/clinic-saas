import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../domain/models/patient.dart';
import '../domain/models/patient_pagination.dart';
import '../domain/models/patient_upsert_payload.dart';
import '../domain/models/patients_page.dart';
import '../domain/models/patients_query.dart';

final patientsRepositoryProvider = Provider<PatientsRepository>((ref) {
  return PatientsRepository(ref.read(apiClientProvider));
});

class PatientsRepository {
  PatientsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<PatientsPage> list(PatientsQuery query) async {
    final response = await _apiClient.get<PatientsPage>(
      '/patients',
      queryParameters: query.toQueryParameters(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid patients list response.');
        }
        return PatientsPage.fromJson(rawData);
      },
    );

    return response.data ??
        const PatientsPage(
          items: [],
          pagination: PatientPagination(
            currentPage: 1,
            perPage: 15,
            total: 0,
            lastPage: 1,
          ),
        );
  }

  Future<Patient> getById(int id) async {
    final response = await _apiClient.get<Patient>(
      '/patients/$id',
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid patient details response.');
        }
        return Patient.fromJson(rawData);
      },
    );

    final patient = response.data;
    if (patient == null) {
      throw ApiException(message: 'Patient details are empty.');
    }
    return patient;
  }

  Future<Patient> create(PatientUpsertPayload payload) async {
    final response = await _apiClient.post<Patient>(
      '/patients',
      data: payload.toJson(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid create patient response.');
        }
        return Patient.fromJson(rawData);
      },
    );

    final patient = response.data;
    if (patient == null) {
      throw ApiException(message: 'Created patient payload is empty.');
    }
    return patient;
  }

  Future<Patient> update({
    required int id,
    required PatientUpsertPayload payload,
  }) async {
    final response = await _apiClient.put<Patient>(
      '/patients/$id',
      data: payload.toJson(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid update patient response.');
        }
        return Patient.fromJson(rawData);
      },
    );

    final patient = response.data;
    if (patient == null) {
      throw ApiException(message: 'Updated patient payload is empty.');
    }
    return patient;
  }

  Future<void> delete(int id) async {
    await _apiClient.delete<Object?>(
      '/patients/$id',
      mapper: (_) => null,
    );
  }
}
