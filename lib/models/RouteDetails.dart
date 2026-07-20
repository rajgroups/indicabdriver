import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Data class holding route details from Google Directions API.
class RouteDetails {
  final List<LatLng> points;
  final String distanceText;
  final String durationText;
  final int distanceMeters;
  final int durationSeconds;

  const RouteDetails({
    required this.points,
    required this.distanceText,
    required this.durationText,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  static const empty = RouteDetails(
    points: [],
    distanceText: '',
    durationText: '',
    distanceMeters: 0,
    durationSeconds: 0,
  );
}
