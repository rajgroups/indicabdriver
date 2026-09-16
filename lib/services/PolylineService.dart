import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Service to handle local polyline manipulation, trimming, and route deviation checks.
class PolylineService {
  /// With straight-line routing, deviation checking is no longer necessary.
  /// Always returns false to avoid triggering route recalculations.
  bool checkDeviation({
    required LatLng driverLatLng,
    required List<LatLng> routePoints,
    double thresholdMeters = 150.0,
  }) {
    return false;
  }

  /// Since we use straight lines, we only need to connect the driver to the destination.
  List<LatLng> trimPassedPoints({
    required LatLng driverLatLng,
    required List<LatLng> routePoints,
  }) {
    if (routePoints.isEmpty) return [];
    if (routePoints.length < 2) return routePoints;

    // Simply connect the current driver location to the destination (the last point)
    return <LatLng>[
      driverLatLng,
      routePoints.last,
    ];
  }

  /// Helper to build a Set of Polylines for Google Maps display.
  Set<Polyline> buildPolylines(List<LatLng> points) {
    if (points.isEmpty) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: const Color(0xFF000080), // Navy Blue
        width: 5,
      ),
    };
  }
}
