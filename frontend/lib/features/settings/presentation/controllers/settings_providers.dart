import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/settings_repository.dart';
import '../../domain/models/settings_models.dart';
import '../../domain/models/settings_scope.dart';

/// Active tenant/branch scope for all settings screens (query + update payloads).
final settingsScopeProvider = StateProvider<SettingsScope>((ref) => const SettingsScope());

final fullSettingsProvider = FutureProvider.autoDispose<SettingsBundle>((ref) async {
  final scope = ref.watch(settingsScopeProvider);
  return ref.read(settingsRepositoryProvider).fetchFull(scope);
});

final clinicProfileSettingsProvider = FutureProvider.autoDispose<ClinicProfileSettingsResponse>((ref) async {
  final scope = ref.watch(settingsScopeProvider);
  return ref.read(settingsRepositoryProvider).fetchClinicProfile(scope);
});

final invoiceSettingsProvider = FutureProvider.autoDispose<InvoiceSettingsResponse>((ref) async {
  final scope = ref.watch(settingsScopeProvider);
  return ref.read(settingsRepositoryProvider).fetchInvoice(scope);
});
