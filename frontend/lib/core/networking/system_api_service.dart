import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'api_exception.dart';

final systemApiServiceProvider = Provider<SystemApiService>((ref) {
  return SystemApiService(ref.read(apiClientProvider));
});

class SystemApiService {
  SystemApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> fetchHealth() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/health',
      mapper: (rawData) {
        if (rawData is Map<String, dynamic>) return rawData;
        throw ApiException(message: 'Invalid health response.');
      },
    );
    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> fetchMeta() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/meta/app',
      mapper: (rawData) {
        if (rawData is Map<String, dynamic>) return rawData;
        throw ApiException(message: 'Invalid meta response.');
      },
    );
    return response.data ?? <String, dynamic>{};
  }
}
