import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services_repository.dart';
import '../../domain/models/service.dart';

final serviceDetailsProvider = FutureProvider.autoDispose.family<Service, int>((ref, serviceId) async {
  return ref.read(servicesRepositoryProvider).getById(serviceId);
});
