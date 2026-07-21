import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Service to handle marker creation, state, and smooth interpolation animations for the driver icon.
class DriverMarkerService {
  Timer? _animationTimer;
  LatLng? _interpolatedPosition;
  double? _interpolatedHeading;

  /// Animates the driver marker smoothly from [start] to [end] position.
  void animateDriverMarker({
    required LatLng start,
    required LatLng end,
    required double startHeading,
    required double endHeading,
    required Function(LatLng position, double heading) onUpdate,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    _animationTimer?.cancel();

    _interpolatedPosition = start;
    _interpolatedHeading = startHeading;

    final int steps = 25; // number of interpolation frames
    final double stepTimeMs = duration.inMilliseconds / steps;
    int currentStep = 0;

    _animationTimer = Timer.periodic(Duration(milliseconds: stepTimeMs.round()), (timer) {
      currentStep++;
      final double t = currentStep / steps;

      // Linear interpolation for coordinates
      final double lat = start.latitude + (end.latitude - start.latitude) * t;
      final double lng = start.longitude + (end.longitude - start.longitude) * t;

      // Shortest path interpolation for heading (angle) using safe, loop-free modulo arithmetic.
      // This prevents infinite loops if inputs are invalid or infinite.
      double diff = (endHeading - startHeading + 180) % 360 - 180;
      final double heading = (startHeading + diff * t) % 360;

      _interpolatedPosition = LatLng(lat, lng);
      _interpolatedHeading = heading;

      onUpdate(_interpolatedPosition!, _interpolatedHeading!);

      if (currentStep >= steps) {
        timer.cancel();
      }
    });
  }

  /// Builds a set of Google Maps markers based on the current state.
  static Future<Set<Marker>> buildMarkers({
    required LatLng driverPosition,
    required double driverHeading,
    required String? status,
    required double? pickupLat,
    required double? pickupLng,
    required String? pickupAddress,
    required double? dropLat,
    required double? dropLng,
    required String? dropAddress,
    required bool isTransportMode,
    required BitmapDescriptor carIcon,
    required BitmapDescriptor pickupIcon,
    required BitmapDescriptor dropIcon,
  }) async {
    final newMarkers = <Marker>{};

    // Driver Marker (always present)
    newMarkers.add(Marker(
      markerId: const MarkerId('driver'),
      position: driverPosition,
      rotation: driverHeading,
      icon: carIcon,
      anchor: const Offset(0.5, 0.5),
      flat: true,
    ));

    final normalizedStatus = status?.toLowerCase();

    if (normalizedStatus == 'accepted' || normalizedStatus == 'arrived') {
      // Show pickup marker
      if (pickupLat != null && pickupLng != null) {
        newMarkers.add(Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(pickupLat, pickupLng),
          icon: pickupIcon,
          infoWindow: InfoWindow(title: 'Pickup', snippet: pickupAddress),
        ));
      }
    } else if (normalizedStatus == 'started') {
      if (isTransportMode) {
        // Show pickup + drop markers
        if (pickupLat != null && pickupLng != null) {
          newMarkers.add(Marker(
            markerId: const MarkerId('pickup'),
            position: LatLng(pickupLat, pickupLng),
            icon: pickupIcon,
            infoWindow: InfoWindow(title: 'Pickup', snippet: pickupAddress),
          ));
        }
        if (dropLat != null && dropLng != null) {
          newMarkers.add(Marker(
            markerId: const MarkerId('drop'),
            position: LatLng(dropLat, dropLng),
            icon: dropIcon,
            infoWindow: InfoWindow(title: 'Drop-off', snippet: dropAddress),
          ));
        }
      } else {
        // Work mode: Show pickup marker only (as Work Location)
        if (pickupLat != null && pickupLng != null) {
          newMarkers.add(Marker(
            markerId: const MarkerId('pickup'),
            position: LatLng(pickupLat, pickupLng),
            icon: pickupIcon,
            infoWindow: InfoWindow(title: 'Work Location', snippet: pickupAddress),
          ));
        }
      }
    }

    return newMarkers;
  }

  void cancel() {
    _animationTimer?.cancel();
  }
}
