import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indicab_driver/config/Config.dart';
import 'package:indicab_driver/models/RouteDetails.dart';

class PolylineHelper {
  /// Returns route points only (backward compatible).
  static Future<List<LatLng>> getRoutePoints(LatLng origin, LatLng destination) async {
    final details = await getRouteWithDetails(origin, destination);
    return details.points;
  }

  /// Returns full route details including distance, duration, and polyline points.
  static Future<RouteDetails> getRouteWithDetails(LatLng origin, LatLng destination) async {
    final apiKey = AppEnv.googlePlacesApiKey.isNotEmpty
        ? AppEnv.googlePlacesApiKey
        : AppEnv.googleMapsApiKey;

    if (apiKey.isEmpty || apiKey.startsWith('YOUR_')) {
      print("PolylineHelper: Missing API key, returning straight line.");
      return RouteDetails(
        points: [origin, destination],
        distanceText: '',
        durationText: '',
        distanceMeters: 0,
        durationSeconds: 0,
      );
    }

    // Try direct Directions API call via Dio (gives us distance/duration)
    try {
      final dio = Dio();
      final url = "https://maps.googleapis.com/maps/api/directions/json"
          "?origin=${origin.latitude},${origin.longitude}"
          "&destination=${destination.latitude},${destination.longitude}"
          "&key=$apiKey"
          "&mode=driving";

      final response = await dio.get(url);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == 'OK' &&
            data['routes'] != null &&
            (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final pointsStr = route['overview_polyline']['points'] as String;
          final points = _decodePoly(pointsStr);

          // Extract distance and duration from the first leg
          String distanceText = '';
          String durationText = '';
          int distanceMeters = 0;
          int durationSeconds = 0;

          if (route['legs'] != null && (route['legs'] as List).isNotEmpty) {
            final leg = route['legs'][0];
            distanceText = leg['distance']?['text'] ?? '';
            durationText = leg['duration']?['text'] ?? '';
            distanceMeters = leg['distance']?['value'] ?? 0;
            durationSeconds = leg['duration']?['value'] ?? 0;
          }

          return RouteDetails(
            points: points,
            distanceText: distanceText,
            durationText: durationText,
            distanceMeters: distanceMeters,
            durationSeconds: durationSeconds,
          );
        } else {
          print("PolylineHelper: API status not OK: ${data['status']}");
        }
      }
    } catch (e) {
      print("PolylineHelper: Direct HTTP request failed: $e");
    }

    // Fallback: flutter_polyline_points (no distance/duration info)
    try {
      final polylinePoints = PolylinePoints(apiKey: apiKey);

      final result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        return RouteDetails(
          points: result.points.map((p) => LatLng(p.latitude, p.longitude)).toList(),
          distanceText: '',
          durationText: '',
          distanceMeters: 0,
          durationSeconds: 0,
        );
      } else {
        print("PolylineHelper: Package returned empty points, message: ${result.errorMessage}");
      }
    } catch (e) {
      print("PolylineHelper: Package call failed: $e");
    }

    // Ultimate fallback: straight line
    return RouteDetails(
      points: [origin, destination],
      distanceText: '',
      durationText: '',
      distanceMeters: 0,
      durationSeconds: 0,
    );
  }

  // Decodes Google overview_polyline string to LatLng list
  static List<LatLng> _decodePoly(String poly) {
    final list = <LatLng>[];
    int index = 0, len = poly.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      list.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return list;
  }
}
