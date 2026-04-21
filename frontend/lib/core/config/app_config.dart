class AppConfig {
  AppConfig._();

  static const appName = 'Clinic SaaS';
  static const apiVersion = 'v1';

  /// Override with:
  /// flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );
}
