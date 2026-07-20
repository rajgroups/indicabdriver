import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Service to handle local polyline manipulation, trimming, and route deviation checks.
class PolylineService {
  /// Calculates if the driver has deviated from the route by more than [thresholdMeters].
  bool checkDeviation({
    required LatLng driverLatLng,
    required List<LatLng> routePoints,
    double thresholdMeters = 150.0,
  }) {
    if (routePoints.isEmpty) return false;

    double minDistanceSq = double.infinity;

    for (int i = 0; i < routePoints.length; i++) {
      final double dx = driverLatLng.latitude - routePoints[i].latitude;
      final double dy = driverLatLng.longitude - routePoints[i].longitude;
      final double distSq = dx * dx + dy * dy;
      if (distSq < minDistanceSq) {
        minDistanceSq = distSq;
      }
    }

    final double distanceInDegrees = math.sqrt(minDistanceSq);
    final double distanceInMeters = distanceInDegrees * 111320; // 1 degree ~ 111.32km

    return distanceInMeters > thresholdMeters;
  }

  /// Trims passed points and returns the updated list starting from the closest index to the driver.
  List<LatLng> trimPassedPoints({
    required LatLng driverLatLng,
    required List<LatLng> routePoints,
  }) {
    if (routePoints.isEmpty) return [];
    if (routePoints.length < 2) return routePoints;

    int closestIndex = 0;
    double minDistanceSq = double.infinity;

    for (int i = 0; i < routePoints.length; i++) {
      final double dx = driverLatLng.latitude - routePoints[i].latitude;
      final double dy = driverLatLng.longitude - routePoints[i].longitude;
      final double distSq = dx * dx + dy * dy;
      if (distSq < minDistanceSq) {
        minDistanceSq = distSq;
        closestIndex = i;
      }
    }

    return <LatLng>[
      driverLatLng,
      ...routePoints.sublist(closestIndex),
    ];
  }

  /// Helper to build a Set of Polylines for Google Maps display.
  Set<Polyline> buildPolylines(List<LatLng> points) {
    if (points.isEmpty) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: const Color(0xFF1A8B4C),
        width: 5,
      ),
    };
  }
}
