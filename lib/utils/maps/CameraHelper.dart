import 'package:google_maps_flutter/google_maps_flutter.dart';

class CameraHelper {
  static LatLngBounds getBounds(List<LatLng> points) {
    if (points.isEmpty) {
      return LatLngBounds(southwest: const LatLng(0, 0), northeast: const LatLng(0, 0));
    }
    
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) {
        minLat = point.latitude;
      }
      if (point.latitude > maxLat) {
        maxLat = point.latitude;
      }
      if (point.longitude < minLng) {
        minLng = point.longitude;
      }
      if (point.longitude > maxLng) {
        maxLng = point.longitude;
      }
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  static Future<void> autoFitRoute(
    GoogleMapController? controller,
    List<LatLng> points, {
    double padding = 60.0,
  }) async {
    if (controller == null || points.isEmpty) {
      return;
    }
    try {
      final bounds = getBounds(points);
      await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, padding));
    } catch (e) {
      print("CameraHelper: Error auto-fitting bounds: $e");
    }
  }

  static Future<void> animateToPosition(
    GoogleMapController? controller,
    LatLng position, {
    double zoom = 15.0,
    double? bearing,
  }) async {
    if (controller == null) {
      return;
    }
    try {
      if (bearing != null) {
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: position,
              zoom: zoom,
              bearing: bearing,
              tilt: 30.0, // A slight tilt adds premium depth
            ),
          ),
        );
      } else {
        await controller.animateCamera(
          CameraUpdate.newLatLng(position),
        );
      }
    } catch (e) {
      print("CameraHelper: Error animating to position: $e");
    }
  }
}
