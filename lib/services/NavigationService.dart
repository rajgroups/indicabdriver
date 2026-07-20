import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

/// Launches Google Maps turn-by-turn navigation.
class NavigationService {
  /// Opens Google Maps with turn-by-turn navigation to the given coordinates.
  ///
  /// On Android: uses `google.navigation:q=lat,lng`
  /// On iOS: uses `comgooglemaps://` scheme, falls back to web URL
  static Future<void> launchNavigation(double lat, double lng) async {
    Uri uri;

    if (Platform.isAndroid) {
      uri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    } else if (Platform.isIOS) {
      uri = Uri.parse('comgooglemaps://?daddr=$lat,$lng&directionsmode=driving');
    } else {
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
      );
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to web URL
      final webUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
      );
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }
}
