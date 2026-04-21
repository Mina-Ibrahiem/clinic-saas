import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../domain/models/billing_pagination.dart';
import '../domain/models/payment.dart';
import '../domain/models/payment_create_payload.dart';
import '../domain/models/payment_query.dart';
import '../domain/models/payments_page.dart';

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return PaymentsRepository(ref.read(apiClientProvider));
});

class PaymentsRepository {
  PaymentsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<PaymentsPage> list(PaymentQuery query) async {
    final response = await _apiClient.get<PaymentsPage>(
      '/payments',
      queryParameters: query.toQueryParameters(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid payments list response.');
        }
        return PaymentsPage.fromJson(rawData);
      },
    );

    return response.data ??
        const PaymentsPage(
          items: [],
          pagination: BillingPagination(
            currentPage: 1,
            perPage: 15,
            total: 0,
            lastPage: 1,
          ),
        );
  }

  Future<Payment> getById(int id) async {
    final response = await _apiClient.get<Payment>(
      '/payments/$id',
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid payment details response.');
        }
        return Payment.fromJson(rawData);
      },
    );

    final payment = response.data;
    if (payment == null) {
      throw ApiException(message: 'Payment details are empty.');
    }
    return payment;
  }

  Future<Payment> create(PaymentCreatePayload payload) async {
    final response = await _apiClient.post<Payment>(
      '/payments',
      data: payload.toJson(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid create payment response.');
        }
        return Payment.fromJson(rawData);
      },
    );

    final payment = response.data;
    if (payment == null) {
      throw ApiException(message: 'Created payment payload is empty.');
    }
    return payment;
  }

  Future<void> delete(int id) async {
    await _apiClient.delete<Object?>(
      '/payments/$id',
      mapper: (_) => null,
    );
  }
}
