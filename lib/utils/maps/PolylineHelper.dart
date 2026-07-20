import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indicab_driver/config/Config.dart';

class PolylineHelper {
  static Future<List<LatLng>> getRoutePoints(LatLng origin, LatLng destination) async {
    final apiKey = AppEnv.googlePlacesApiKey.isNotEmpty
        ? AppEnv.googlePlacesApiKey
        : AppEnv.googleMapsApiKey;

    if (apiKey.isEmpty || apiKey.startsWith('YOUR_')) {
      print("PolylineHelper: Missing API key, returning straight line.");
      return [origin, destination];
    }

    // Try using flutter_polyline_points first
    try {
      final polylinePoints = PolylinePoints(apiKey: apiKey);
      
      // Attempt using the package
      final result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        return result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
      } else {
        print("PolylineHelper: Package returned empty points, message: ${result.errorMessage}");
      }
    } catch (e) {
      print("PolylineHelper: Package call failed, trying direct HTTP request: $e");
    }

    // Fallback: Direct API request via Dio
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
          final pointsStr = data['routes'][0]['overview_polyline']['points'] as String;
          return _decodePoly(pointsStr);
        } else {
          print("PolylineHelper: API status not OK: ${data['status']}");
        }
      }
    } catch (e) {
      print("PolylineHelper: Direct HTTP fallback failed: $e");
    }

    // Ultimate fallback: straight line
    return [origin, destination];
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
