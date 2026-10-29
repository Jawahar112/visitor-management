//flutter run --dart-define=API_BASE_URL=https://6ae2b589bbb54129229a4f5a.mockapi.io/api/v1
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://6ae2b589bbb54129229a4f5a.mockapi.io/api/v1',
  );

  static const String visitorsPath = '/visitors';
  static const Duration timeout = Duration(seconds: 12);
}
