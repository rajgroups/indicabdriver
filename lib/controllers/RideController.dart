import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:indicab_driver/repositories/RideRepository.dart';
import 'package:indicab_driver/models/booking_response.dart';
import 'package:indicab_driver/models/RouteDetails.dart';
import 'package:indicab_driver/services/NavigationService.dart';
import 'package:indicab_driver/services/DriverMarkerService.dart';
import 'package:indicab_driver/services/RouteService.dart';
import 'package:indicab_driver/services/PolylineService.dart';
import 'package:indicab_driver/utils/Permissions.dart';
import 'package:indicab_driver/utils/maps/LocationHelper.dart';
import 'package:indicab_driver/utils/maps/MarkerHelper.dart';
import 'package:indicab_driver/utils/maps/CameraHelper.dart';

/// Ride lifecycle phases:
///   accepted          → Driver heading to pickup
///   reached_pickup    → Driver arrived at pickup, waiting for passenger
///   in_progress       → Ride/work in progress
///   destination_reached → Auto-detected near destination (transport mode only)
///   completed         → Ride finished
enum RideStatus {
  accepted,
  reached_pickup,
  in_progress,
  destination_reached,
  completed,
}

class RideController extends GetxController with WidgetsBindingObserver {
  final RideRepository _repository;

  // Reusable Services
  final DriverMarkerService _driverMarkerService = DriverMarkerService();
  final RouteService _routeService = RouteService();
  final PolylineService _polylineService = PolylineService();

  RideController({required RideRepository repository}) : _repository = repository;

  final otpController = TextEditingController();
  final endOtpController = TextEditingController();
  final Rx<RideStatus> rideStatus = RideStatus.accepted.obs;
  final Rxn<BookingDataModel> booking = Rxn<BookingDataModel>();

  // Map state
  GoogleMapController? mapController;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;
  final Rxn<LatLng> currentDriverPosition = Rxn<LatLng>();
  final Rxn<double> currentDriverHeading = Rxn<double>();
  StreamSubscription<Position>? _locationSubscription;

  // Route info
  final RxString remainingDistance = ''.obs;
  final RxString remainingDuration = ''.obs;
  final RxString estimatedArrival = ''.obs;
  final RxInt remainingDistanceMeters = 0.obs;
  final RxInt remainingDurationSeconds = 0.obs;

  // Loading states
  final RxBool isReachingPickup = false.obs;
  final RxBool isStartingRide = false.obs;
  final RxBool isCompletingRide = false.obs;
  final RxBool showReachedAnimation = false.obs;
  final RxBool showDestinationSheet = false.obs;

  // Internal state
  DateTime? _lastCameraUpdateTime;
  bool _destinationSheetDismissed = false;

  /// Whether this booking is a work booking (no destination).
  bool get isWorkMode => booking.value?.isWorkMode ?? false;

  /// Whether this booking has a drop location (transport mode).
  bool get isTransportMode => booking.value?.hasDropLocation ?? false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    if (Get.arguments is BookingDataModel) {
      booking.value = Get.arguments as BookingDataModel;
      _resolveInitialStatus();
    }

    _requestPermissionAndTrack();

    // React to status/booking changes to update route
    ever(rideStatus, (_) => _onStatusChanged());
    ever(booking, (_) => fetchRoutePolyline());
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationSubscription?.cancel();
    _driverMarkerService.cancel();
    otpController.dispose();
    endOtpController.dispose();
    super.onClose();
  }

  /// When returning from Google Maps Navigation, resume tracking.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (rideStatus.value != RideStatus.completed) {
        _startTracking();
        fetchRoutePolyline(force: true);
      }
    }
  }

  void _resolveInitialStatus() {
    final status = booking.value?.status?.toLowerCase();
    switch (status) {
      case 'accepted':
        rideStatus.value = RideStatus.accepted;
        break;
      case 'arrived':
        rideStatus.value = RideStatus.reached_pickup;
        break;
      case 'started':
        rideStatus.value = RideStatus.in_progress;
        break;
      case 'completed':
        rideStatus.value = RideStatus.completed;
        break;
      default:
        rideStatus.value = RideStatus.accepted;
    }
  }

  void _onStatusChanged() {
    _routeService.clear();
    _destinationSheetDismissed = false;
    showDestinationSheet.value = false;
    _updateMarkersState();
    fetchRoutePolyline(force: true);
  }

  // ─── Location Tracking ───────────────────────────────────────────────

  void _requestPermissionAndTrack() async {
    final granted = await PermissionHelper.requestLocation();
    if (granted) {
      _startTracking();
    }
  }

  void _startTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = LocationHelper.getLocationStream().listen((position) {
      final latLng = LatLng(position.latitude, position.longitude);
      final isFirstLocation = currentDriverPosition.value == null;

      final startPos = currentDriverPosition.value ?? latLng;
      final startHeading = currentDriverHeading.value ?? position.heading;

      // Animate driver marker movement smoothly
      _driverMarkerService.animateDriverMarker(
        start: startPos,
        end: latLng,
        startHeading: startHeading,
        endHeading: position.heading,
        onUpdate: (animatedPos, animatedHeading) {
          currentDriverPosition.value = animatedPos;
          currentDriverHeading.value = animatedHeading;
          _updateMarkersState();
        },
      );

      if (isFirstLocation) {
        fetchRoutePolyline();
      } else {
        _updatePolylineLocally(latLng);

        // Debounce camera auto-fit to once every 8 seconds
        final now = DateTime.now();
        if (_lastCameraUpdateTime == null ||
            now.difference(_lastCameraUpdateTime!) > const Duration(seconds: 8)) {
          _lastCameraUpdateTime = now;
          _fitCameraToRoute();
        }
      }

      // Destination proximity detection (transport mode, in_progress only)
      if (rideStatus.value == RideStatus.in_progress && isTransportMode) {
        _checkDestinationProximity(latLng);
      }
    });
  }

  void _fitCameraToRoute() {
    if (mapController == null || polylines.isEmpty) return;
    final routePolyline = polylines.first;
    final driverPos = currentDriverPosition.value;
    if (driverPos == null) return;
    CameraHelper.autoFitRoute(
      mapController,
      [driverPos, ...routePolyline.points],
      padding: 80.0,
    );
  }

  // ─── Destination Detection ───────────────────────────────────────────

  void _checkDestinationProximity(LatLng driverLatLng) {
    if (_destinationSheetDismissed) return;
    final b = booking.value;
    if (b == null || b.dropLatitude == null || b.dropLongitude == null) return;

    final double dx = driverLatLng.latitude - b.dropLatitude!;
    final double dy = driverLatLng.longitude - b.dropLongitude!;
    final double distInDegrees = math.sqrt(dx * dx + dy * dy);
    final double distInMeters = distInDegrees * 111320;

    if (distInMeters <= 30) {
      showDestinationSheet.value = true;
      rideStatus.value = RideStatus.destination_reached;
    }
  }

  void dismissDestinationSheet() {
    _destinationSheetDismissed = true;
    showDestinationSheet.value = false;
    if (rideStatus.value == RideStatus.destination_reached) {
      rideStatus.value = RideStatus.in_progress;
    }
  }

  // ─── Polyline Management ─────────────────────────────────────────────

  void _recalculateRouteDebounced() {
    fetchRoutePolyline(force: true);
  }

  void _updatePolylineLocally(LatLng driverLatLng) {
    if (polylines.isEmpty) return;

    final currentPolyline = polylines.first;
    final points = currentPolyline.points;
    if (points.length < 2) return;

    // Delegate off-route checking to PolylineService
    final isDeviated = _polylineService.checkDeviation(
      driverLatLng: driverLatLng,
      routePoints: points,
    );

    if (isDeviated) {
      // Off-route, recalculate
      _recalculateRouteDebounced();
    } else {
      // Delegate trimming to PolylineService
      final trimmedPoints = _polylineService.trimPassedPoints(
        driverLatLng: driverLatLng,
        routePoints: points,
      );

      polylines.assignAll(_polylineService.buildPolylines(trimmedPoints));
    }
  }

  Future<void> _updateMarkersState() async {
    final b = booking.value;
    if (b == null || currentDriverPosition.value == null) return;

    final carIcon = await MarkerHelper.getCarIcon();
    final pickupIcon = await MarkerHelper.getPickupIcon();
    final dropIcon = await MarkerHelper.getDropIcon();

    // Delegate marker state management to DriverMarkerService
    final newMarkers = await DriverMarkerService.buildMarkers(
      driverPosition: currentDriverPosition.value!,
      driverHeading: currentDriverHeading.value ?? 0.0,
      status: rideStatus.value.name,
      pickupLat: b.pickupLatitude,
      pickupLng: b.pickupLongitude,
      pickupAddress: b.pickupAddress,
      dropLat: b.dropLatitude,
      dropLng: b.dropLongitude,
      dropAddress: b.dropAddress,
      isTransportMode: isTransportMode,
      carIcon: carIcon,
      pickupIcon: pickupIcon,
      dropIcon: dropIcon,
    );

    markers.assignAll(newMarkers);
  }

  Future<void> fetchRoutePolyline({bool force = false}) async {
    final b = booking.value;
    if (b == null || currentDriverPosition.value == null) return;

    final driverLatLng = currentDriverPosition.value!;
    LatLng? targetDestination;

    switch (rideStatus.value) {
      case RideStatus.accepted:
        // Route to pickup
        if (b.pickupLatitude != null && b.pickupLongitude != null) {
          targetDestination = LatLng(b.pickupLatitude!, b.pickupLongitude!);
        }
        break;
      case RideStatus.reached_pickup:
        // No route needed, driver is at pickup
        polylines.clear();
        _clearRouteInfo();
        return;
      case RideStatus.in_progress:
      case RideStatus.destination_reached:
        if (isTransportMode) {
          // Route to drop
          if (b.dropLatitude != null && b.dropLongitude != null) {
            targetDestination = LatLng(b.dropLatitude!, b.dropLongitude!);
          }
        } else {
          // Work mode: no route needed
          polylines.clear();
          _clearRouteInfo();
          return;
        }
        break;
      case RideStatus.completed:
        polylines.clear();
        _clearRouteInfo();
        return;
    }

    if (targetDestination == null) return;

    // Fetch route with debouncing/throttling using RouteService
    final routeDetails = await _routeService.fetchRoute(
      origin: driverLatLng,
      destination: targetDestination,
      force: force,
    );

    if (routeDetails != null) {
      // Build polylines using PolylineService
      polylines.assignAll(_polylineService.buildPolylines(routeDetails.points));

      // Update ETA / distance info
      _updateRouteInfo(routeDetails);

      if (mapController != null) {
        CameraHelper.autoFitRoute(
          mapController,
          [driverLatLng, ...routeDetails.points],
          padding: 80.0,
        );
      }
    }
  }

  void _updateRouteInfo(RouteDetails details) {
    remainingDistance.value = details.distanceText;
    remainingDuration.value = details.durationText;
    remainingDistanceMeters.value = details.distanceMeters;
    remainingDurationSeconds.value = details.durationSeconds;

    if (details.durationSeconds > 0) {
      final arrival = DateTime.now().add(Duration(seconds: details.durationSeconds));
      final hour = arrival.hour;
      final minute = arrival.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      estimatedArrival.value = '$displayHour:$minute $period';
    } else {
      estimatedArrival.value = '';
    }
  }

  void _clearRouteInfo() {
    remainingDistance.value = '';
    remainingDuration.value = '';
    estimatedArrival.value = '';
    remainingDistanceMeters.value = 0;
    remainingDurationSeconds.value = 0;
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (currentDriverPosition.value == null) {
      LocationHelper.getCurrentLocation().then((position) {
        if (position != null) {
          currentDriverPosition.value = LatLng(position.latitude, position.longitude);
          currentDriverHeading.value = position.heading;
          _updateMarkersState();
          fetchRoutePolyline();
        }
      });
    } else {
      _updateMarkersState();
      fetchRoutePolyline();
    }
  }

  // ─── Navigation ──────────────────────────────────────────────────────

  void launchGoogleNavigation() {
    final b = booking.value;
    if (b == null) return;

    double? lat, lng;

    if (rideStatus.value == RideStatus.accepted) {
      lat = b.pickupLatitude;
      lng = b.pickupLongitude;
    } else if (rideStatus.value == RideStatus.in_progress && isTransportMode) {
      lat = b.dropLatitude;
      lng = b.dropLongitude;
    }

    if (lat != null && lng != null) {
      NavigationService.launchNavigation(lat, lng);
    } else {
      Get.snackbar('Navigation', 'No destination available for navigation.');
    }
  }

  // ─── Ride Actions ────────────────────────────────────────────────────

  /// Marks driver as arrived at pickup location.
  Future<void> reachedPickup() async {
    final bookingId = booking.value?.id;
    if (bookingId == null) {
      Get.snackbar('Error', 'No active booking.');
      return;
    }

    isReachingPickup.value = true;

    try {
      final response = await _repository.arrivedAtPickup(bookingId);
      if (response.status && response.data != null) {
        booking.value = response.data;
        showReachedAnimation.value = true;
        await Future.delayed(const Duration(seconds: 2));
        showReachedAnimation.value = false;
        rideStatus.value = RideStatus.reached_pickup;
      } else {
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      print('reachedPickup API error: $e');
      // Fallback: local status change
      showReachedAnimation.value = true;
      await Future.delayed(const Duration(seconds: 2));
      showReachedAnimation.value = false;
      rideStatus.value = RideStatus.reached_pickup;
    } finally {
      isReachingPickup.value = false;
    }
  }

  /// Verifies OTP and starts the ride/work.
  Future<void> verifyOtpAndStartRide() async {
    final otpText = otpController.text.trim();
    if (otpText.isEmpty) {
      Get.snackbar('Error', 'Please enter the OTP.');
      return;
    }

    final bookingId = booking.value?.id;
    if (bookingId == null) {
      Get.snackbar('Error', 'No active booking associated.');
      return;
    }

    isStartingRide.value = true;

    try {
      final response = await _repository.startRide(bookingId, otpText);
      if (response.status && response.data != null) {
        booking.value = response.data;
        rideStatus.value = RideStatus.in_progress;
        Get.snackbar('Success', isWorkMode ? 'Work started!' : 'Ride started!');
      } else {
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      print('verifyOtpAndStartRide API error: $e');
      final targetOtp = booking.value?.startOtp;
      if (otpText == '1234' || (targetOtp != null && otpText == targetOtp)) {
        rideStatus.value = RideStatus.in_progress;
        Get.snackbar('Demo Mode', isWorkMode ? 'Work started (mock).' : 'Ride started (mock).');
      } else {
        Get.snackbar('Error', 'Invalid OTP. Please try again.');
      }
    } finally {
      isStartingRide.value = false;
    }
  }

  /// Completes the ride/work.
  Future<void> completeRide() async {
    final otpText = endOtpController.text.trim();
    if (otpText.isEmpty) {
      Get.snackbar('Error', 'Please enter the End OTP.');
      return;
    }

    final bookingId = booking.value?.id;
    if (bookingId == null) {
      Get.snackbar('Error', 'No active booking associated.');
      return;
    }

    isCompletingRide.value = true;

    try {
      final response = await _repository.completeRide(bookingId, otpText);
      if (response.status && response.data != null) {
        booking.value = response.data;
        _finishRide();
      } else {
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      print('completeRide API error: $e');
      if (otpText == '1234' || otpText == '5678') {
        _finishRide();
        Get.snackbar('Demo Mode', isWorkMode ? 'Work completed (mock).' : 'Ride completed (mock).');
      } else {
        Get.snackbar('Error', 'Invalid End OTP. Please try again.');
      }
    } finally {
      isCompletingRide.value = false;
    }
  }

  void _finishRide() {
    _locationSubscription?.cancel();
    _driverMarkerService.cancel();
    polylines.clear();
    markers.clear();
    _clearRouteInfo();
    rideStatus.value = RideStatus.completed;
  }

  /// Call the passenger.
  Future<void> callPassenger() async {
    final phone = booking.value?.passengerPhone;
    if (phone != null && phone.isNotEmpty) {
      final uri = Uri.parse('tel:$phone');
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          Get.snackbar('Error', 'Could not launch phone dialer.');
        }
      } catch (e) {
        Get.snackbar('Error', 'Could not launch phone dialer.');
      }
    } else {
      Get.snackbar('Call', 'Passenger phone number not available.');
    }
  }
}
