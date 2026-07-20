import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indicab_driver/models/RouteDetails.dart';
import 'package:indicab_driver/utils/maps/PolylineHelper.dart';

/// Service to handle fetching route details from the Google Directions API.
class RouteService {
  LatLng? _lastDestination;
  DateTime? _lastRouteFetchTime;

  /// Fetches route details between [origin] and [destination].
  /// Incorporates throttling to prevent unnecessary Directions API calls (max once per 30 seconds, unless [force] is true).
  Future<RouteDetails?> fetchRoute({
    required LatLng origin,
    required LatLng destination,
    bool force = false,
  }) async {
    final now = DateTime.now();

    if (!force &&
        _lastDestination == destination &&
        _lastRouteFetchTime != null &&
        now.difference(_lastRouteFetchTime!) < const Duration(seconds: 30)) {
      print("RouteService: Skipping API call (throttled).");
      return null;
    }

    _lastDestination = destination;
    _lastRouteFetchTime = now;

    try {
      final routeDetails = await PolylineHelper.getRouteWithDetails(origin, destination);
      return routeDetails;
    } catch (e) {
      print("RouteService: Error fetching route: $e");
      return null;
    }
  }

  /// Reset service state
  void clear() {
    _lastDestination = null;
    _lastRouteFetchTime = null;
  }
}
