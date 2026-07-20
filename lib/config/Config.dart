import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  const AppEnv._();

  static String get googleMapsApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  static String get googlePlacesApiKey =>
      dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  static String get socketUrl =>
      dotenv.env['SOCKET_URL'] ?? const String.fromEnvironment('SOCKET_URL');

  static bool get hasGoogleMapsApiKey => _isRealValue(googleMapsApiKey);

  static bool get hasGooglePlacesApiKey => _isRealValue(googlePlacesApiKey);

  static bool get hasSocketUrl => _isRealValue(socketUrl);

  static bool _isRealValue(String value) {
    if (value.isEmpty) {
      return false;
    }

    return !value.startsWith('YOUR_');
  }
}

