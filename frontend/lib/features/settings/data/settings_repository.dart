import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../domain/models/settings_models.dart';
import '../domain/models/settings_scope.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.read(apiClientProvider));
});

class SettingsRepository {
  SettingsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<SettingsBundle> fetchFull(SettingsScope scope) async {
    final response = await _apiClient.get<SettingsBundle>(
      '/settings',
      queryParameters: scope.toQueryParameters(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid settings response.');
        }
        return SettingsBundle.fromJson(rawData);
      },
    );

    final data = response.data;
    if (data == null) {
      throw ApiException(message: 'Settings payload is empty.');
    }
    return data;
  }

  Future<SettingsBundle> updateFull({
    required SettingsScope scope,
    required Map<String, dynamic> settings,
  }) async {
    final body = <String, dynamic>{
      'settings': settings,
      ...scope.toBodyFields(),
    };

    final response = await _apiClient.put<SettingsBundle>(
      '/settings',
      data: body,
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid settings update response.');
        }
        return SettingsBundle.fromJson(rawData);
      },
    );

    final data = response.data;
    if (data == null) {
      throw ApiException(message: 'Settings update payload is empty.');
    }
    return data;
  }

  Future<ClinicProfileSettingsResponse> fetchClinicProfile(SettingsScope scope) async {
    final response = await _apiClient.get<ClinicProfileSettingsResponse>(
      '/settings/clinic-profile',
      queryParameters: scope.toQueryParameters(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid clinic profile settings response.');
        }
        return ClinicProfileSettingsResponse.fromJson(rawData);
      },
    );

    final data = response.data;
    if (data == null) {
      throw ApiException(message: 'Clinic profile settings are empty.');
    }
    return data;
  }

  Future<ClinicProfileSettingsResponse> updateClinicProfile({
    required SettingsScope scope,
    required Map<String, dynamic> payload,
  }) async {
    final body = <String, dynamic>{
      ...payload,
      ...scope.toBodyFields(),
    };

    final response = await _apiClient.put<ClinicProfileSettingsResponse>(
      '/settings/clinic-profile',
      data: body,
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid clinic profile update response.');
        }
        return ClinicProfileSettingsResponse.fromJson(rawData);
      },
    );

    final data = response.data;
    if (data == null) {
      throw ApiException(message: 'Clinic profile update payload is empty.');
    }
    return data;
  }

  Future<InvoiceSettingsResponse> fetchInvoice(SettingsScope scope) async {
    final response = await _apiClient.get<InvoiceSettingsResponse>(
      '/settings/invoice',
      queryParameters: scope.toQueryParameters(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid invoice settings response.');
        }
        return InvoiceSettingsResponse.fromJson(rawData);
      },
    );

    final data = response.data;
    if (data == null) {
      throw ApiException(message: 'Invoice settings are empty.');
    }
    return data;
  }

  Future<InvoiceSettingsResponse> updateInvoice({
    required SettingsScope scope,
    required Map<String, dynamic> payload,
  }) async {
    final body = <String, dynamic>{
      ...payload,
      ...scope.toBodyFields(),
    };

    final response = await _apiClient.put<InvoiceSettingsResponse>(
      '/settings/invoice',
      data: body,
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid invoice settings update response.');
        }
        return InvoiceSettingsResponse.fromJson(rawData);
      },
    );

    final data = response.data;
    if (data == null) {
      throw ApiException(message: 'Invoice settings update payload is empty.');
    }
    return data;
  }
}
