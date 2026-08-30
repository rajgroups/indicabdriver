import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  const AppEnv._();

  static String get googleMapsApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  static String get googlePlacesApiKey =>
      dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.191.92.83:8000/api/driver';

  static String get socketUrl =>
      dotenv.env['SOCKET_URL'] ?? 'ws://10.191.92.83:9502';

  static bool get hasGoogleMapsApiKey => _isRealValue(googleMapsApiKey);

  static bool get hasGooglePlacesApiKey => _isRealValue(googlePlacesApiKey);

  static bool get hasApiBaseUrl => _isRealValue(apiBaseUrl);

  static bool get hasSocketUrl => _isRealValue(socketUrl);

  static int get splashDelaySeconds =>
      int.tryParse(dotenv.env['SPLASH_DELAY_SECONDS'] ?? '') ??
      int.tryParse(dotenv.env['SPLASH_DURATION'] ?? '') ??
      2;

  static bool _isRealValue(String value) {
    if (value.isEmpty) {
      return false;
    }

    return !value.startsWith('YOUR_');
  }
}

