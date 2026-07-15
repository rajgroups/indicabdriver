class AppEnv {
  const AppEnv._();

  static const String googleMapsApiKey =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  static const String googlePlacesApiKey =
      String.fromEnvironment('GOOGLE_PLACES_API_KEY');

  static const String socketUrl = String.fromEnvironment('SOCKET_URL');

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
