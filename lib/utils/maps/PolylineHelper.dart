import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:indicab_driver/models/RouteDetails.dart';

class PolylineHelper {
  /// Returns route points only (backward compatible).
  static Future<List<LatLng>> getRoutePoints(LatLng origin, LatLng destination) async {
    final details = await getRouteWithDetails(origin, destination);
    return details.points;
  }

  /// Returns full route details including manually estimated distance, duration, and straight-line points.
  static Future<RouteDetails> getRouteWithDetails(LatLng origin, LatLng destination) async {
    // Calculate straight-line distance in meters
    final double distanceMeters = Geolocator.distanceBetween(
      origin.latitude,
      origin.longitude,
      destination.latitude,
      destination.longitude,
    );

    // Rough estimate duration: Assume 30 km/h average speed in city
    // 30 km/h = 8.33 m/s
    final int durationSeconds = (distanceMeters / 8.33).round();

    String distanceText = '';
    if (distanceMeters < 1000) {
      distanceText = '${distanceMeters.round()} m';
    } else {
      distanceText = '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }

    String durationText = '';
    final int minutes = durationSeconds ~/ 60;
    if (minutes < 60) {
      durationText = '$minutes min';
    } else {
      final int hours = minutes ~/ 60;
      final int remainingMins = minutes % 60;
      durationText = '$hours h $remainingMins min';
    }

    // Always return a straight line locally
    return RouteDetails(
      points: [origin, destination],
      distanceText: distanceText,
      durationText: durationText,
      distanceMeters: distanceMeters.round(),
      durationSeconds: durationSeconds,
    );
  }
}
