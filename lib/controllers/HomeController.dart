import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indicab_driver/models/Driver.dart';
import 'package:indicab_driver/network/client.dart';
import 'package:indicab_driver/repositories/HomeRepository.dart';
import 'package:indicab_driver/repository/BookingRepository.dart';
import 'package:indicab_driver/routes/names.dart';
import 'package:indicab_driver/services/FirebaseService.dart';
import 'package:indicab_driver/services/SocketService.dart';
import 'package:indicab_driver/services/SecureStorageService.dart';
import 'package:indicab_driver/services/StorageService.dart';
import 'package:indicab_driver/constants/Keys.dart';
import 'package:indicab_driver/constants/Colors.dart';
import 'package:indicab_driver/models/booking_response.dart';
import 'package:indicab_driver/utils/Permissions.dart';
import 'package:indicab_driver/utils/Helpers.dart';
import 'package:indicab_driver/utils/maps/LocationHelper.dart';
import 'package:indicab_driver/utils/maps/MarkerHelper.dart';
import 'package:indicab_driver/utils/maps/CameraHelper.dart';
import 'package:indicab_driver/utils/AppUpdateHelper.dart';

class HomeController extends GetxController {
  HomeController({
    required HomeRepository repository,
    required BookingRepository bookingRepository,
  }) : _repository = repository,
       _bookingRepository = bookingRepository;

  final HomeRepository _repository;
  final BookingRepository _bookingRepository;

  final RxBool isOnline = true.obs;
  final RxBool isLoading = true.obs;
  final RxBool isTogglingOnline = false.obs;
  final RxInt onlineTrips = 0.obs;
  final RxInt todayTrips = 0.obs;
  final RxDouble rating = 4.9.obs;
  final RxDouble todayEarnings = 0.0.obs;
  final RxDouble walletBalance = 0.0.obs;
  final RxList<BookingDataModel> recentTrips = <BookingDataModel>[].obs;
  final RxBool isLocating = false.obs;

  // Incoming Booking request states
  final RxBool showIncomingRequest = false.obs;
  final Rxn<BookingDataModel> incomingRequest = Rxn<BookingDataModel>();
  final RxInt countdownSeconds = 15.obs;
  final RxDouble countdownProgress = 1.0.obs;
  final RxBool isAccepting = false.obs;

  Timer? _countdownTimer;
  Worker? _pendingIncomingBookingWorker;
  Worker? _walletBalanceWorker;
  static const String _driverIdKey = 'driverId';
  bool _checkedActiveRide = false;

  // Map variables
  GoogleMapController? mapController;
  final Rxn<LatLng> currentPosition = Rxn<LatLng>();
  final Rxn<double> heading = Rxn<double>();
  final RxSet<Marker> markers = <Marker>{}.obs;
  StreamSubscription<Position>? _locationSubscription;

  DriverModel? get currentDriver => Get.isRegistered<SocketService>()
      ? Get.find<SocketService>().currentDriver.value
      : null;

  @override
  void onInit() {
    super.onInit();
    final storedBalance = StorageService().read(StorageKeys.walletBalance);
    if (storedBalance != null) {
      walletBalance.value = double.tryParse(storedBalance.toString()) ?? 0.0;
    }
    _bindPendingIncomingBooking();
    _bindWalletBalanceUpdates();
    loadDashboard();
    _requestPermissionAndTrack();
    if (isOnline.value) {
      _connectSocket();
    }
    Future.microtask(_consumePendingIncomingBooking);
    Future.microtask(_checkActiveRide);
    Future.microtask(_checkAppUpdate);
  }

  Future<void> _checkAppUpdate() async {
    final updateData = await _repository.checkAppUpdate();
    if (updateData != null) {
      AppUpdateHelper.evaluateAndShowUpdateNotice(updateData);
    }
  }

  @override
  void onClose() {
    _stopTracking();
    _countdownTimer?.cancel();
    _pendingIncomingBookingWorker?.dispose();
    _walletBalanceWorker?.dispose();
    try {
      final socketService = Get.find<SocketService>();
      socketService.off('booking_request', _handleIncomingBookingRequest);
      socketService.off('booking_status', _handleBookingStatusUpdate);
    } catch (e) {
      print('Error removing booking listeners in onClose: $e');
    }
    super.onClose();
  }

  Future<void> _requestPermissionAndTrack() async {
    final granted = await PermissionHelper.requestLocation();
    if (granted && isOnline.value) {
      _startTracking();
    }
  }

  Future<void> focusCurrentLocation({bool resetBearing = false}) async {
    if (isLocating.value) return;

    isLocating.value = true;
    try {
      if (currentPosition.value == null) {
        final granted = await PermissionHelper.requestLocation();
        if (!granted) {
          Get.snackbar(
            'Location Required',
            'Please allow location access to center the map on your current position.',
            backgroundColor: Colors.white,
            colorText: AppColors.textPrimary,
          );
          return;
        }
      }

      final position = await LocationHelper.getCurrentLocation();
      if (position == null) {
        Get.snackbar(
          'Location Unavailable',
          'Unable to fetch your current location right now.',
          backgroundColor: Colors.white,
          colorText: AppColors.textPrimary,
        );
        return;
      }

      final latLng = LatLng(position.latitude, position.longitude);
      currentPosition.value = latLng;
      heading.value = position.heading;
      _updateDriverMarker(latLng, position.heading);

      if (mapController != null) {
        CameraHelper.animateToPosition(
          mapController,
          latLng,
          bearing: resetBearing ? 0.0 : position.heading,
        );
      }

      if (!isOnline.value) {
        Get.snackbar(
          'Location Centered',
          'Your current location is now visible on the map.',
          backgroundColor: Colors.white,
          colorText: AppColors.textPrimary,
        );
      }
    } catch (e) {
      debugPrint('Error focusing current location: $e');
      Get.snackbar(
        'Location Error',
        'Could not center the map on your current location.',
        backgroundColor: Colors.white,
        colorText: AppColors.textPrimary,
      );
    } finally {
      isLocating.value = false;
    }
  }

  void _startTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = LocationHelper.getLocationStream().listen(
      (position) {
        final latLng = LatLng(position.latitude, position.longitude);
        currentPosition.value = latLng;
        heading.value = position.heading;

        _sendLocationUpdateToSocket(position);
        _updateDriverMarker(latLng, position.heading);

        if (mapController != null) {
          CameraHelper.animateToPosition(
            mapController,
            latLng,
            bearing: position.heading,
          );
        }
      },
      onError: (e) {
        print("HomeController location stream error: $e");
      },
    );
  }

  void _stopTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  Future<void> _updateDriverMarker(LatLng position, double bearing) async {
    final carIcon = await MarkerHelper.getCarIcon();
    markers.assignAll({
      Marker(
        markerId: const MarkerId('driver'),
        position: position,
        rotation: bearing,
        icon: carIcon,
        anchor: const Offset(0.5, 0.5),
        flat: true,
      ),
    });
  }

  void _sendLocationUpdateToSocket(Position position) {
    try {
      final socketService = Get.find<SocketService>();
      if (!socketService.isConnected.value) return;

      final driverIdValue = StorageService().read(_driverIdKey);
      final String? driverId = driverIdValue?.toString();
      if (driverId == null) return;

      final locationData = {
        "type": "driver_location",
        "driver_id": int.tryParse(driverId) ?? 0,
        "latitude": position.latitude,
        "longitude": position.longitude,
      };
      socketService.send(locationData);
    } catch (e) {
      print("Error sending location update to socket: $e");
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (currentPosition.value != null) {
      CameraHelper.animateToPosition(
        mapController,
        currentPosition.value!,
        bearing: heading.value,
      );
      _updateDriverMarker(currentPosition.value!, heading.value ?? 0);
    } else {
      LocationHelper.getCurrentLocation().then((position) {
        if (position != null) {
          final latLng = LatLng(position.latitude, position.longitude);
          currentPosition.value = latLng;
          heading.value = position.heading;
          CameraHelper.animateToPosition(
            mapController,
            latLng,
            bearing: position.heading,
          );
          _updateDriverMarker(latLng, position.heading);
        }
      });
    }
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    try {
      final data = await _repository.loadDashboard();
      isOnline.value = data['is_online'] as bool? ?? false;
      todayTrips.value = data['todayTrips'] as int? ?? 0;
      rating.value = (data['rating'] as num? ?? 4.9).toDouble();
      todayEarnings.value = (data['earnings'] as num? ?? 0.0).toDouble();
      if (data['wallet_balance'] != null) {
        walletBalance.value = (data['wallet_balance'] as num).toDouble();
      }

      final recent = data['recentBookings'];
      if (recent is List<BookingDataModel>) {
        recentTrips.assignAll(recent);
      }
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _bindWalletBalanceUpdates() {
    if (!Get.isRegistered<SocketService>()) {
      return;
    }

    _walletBalanceWorker = ever<DriverModel?>(
      Get.find<SocketService>().currentDriver,
      (driver) {
        if (driver?.walletBalance != null) {
          walletBalance.value = driver!.walletBalance!;
        }
      },
    );
  }

  void showRechargeDialog() {
    final TextEditingController amountController = TextEditingController(
      text: '500',
    );
    final RxDouble selectedAmount = 500.0.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF167A3F).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Color(0xFF167A3F),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Recharge Wallet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Amount (₹)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [100.0, 200.0, 500.0, 1000.0].map((amt) {
                    final isSelected = selectedAmount.value == amt;
                    return ChoiceChip(
                      label: Text('₹${amt.toInt()}'),
                      selected: isSelected,
                      selectedColor: const Color(0xFF167A3F),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          selectedAmount.value = amt;
                          amountController.text = amt.toInt().toString();
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Custom Amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null) {
                    selectedAmount.value = parsed;
                  }
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF167A3F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      final amt =
                          double.tryParse(amountController.text) ??
                          selectedAmount.value;
                      if (amt <= 0) {
                        Get.snackbar('Error', 'Please enter a valid amount');
                        return;
                      }
                      Get.back();
                      rechargeWallet(amt);
                    },
                    child: const Text('Proceed to Recharge'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> rechargeWallet(double amount) async {
    try {
      Helpers.loading();
      final response = await _repository.requestWalletRecharge(amount);
      Helpers.close();

      final rawStatus = response['status'];
      final bool status = rawStatus == true ||
          rawStatus == 'success' ||
          rawStatus == 'true' ||
          rawStatus == 1;
      final String message =
          response['message']?.toString() ??
          'Recharge request submitted successfully. Pending admin approval.';

      if (status) {
        Helpers.success(message, null);
      } else {
        Helpers.error(message);
      }
    } catch (e) {
      Helpers.close();
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      Helpers.error('Failed to submit recharge request: $errorMsg');
    }
  }

  Future<void> _checkActiveRide() async {
    if (_checkedActiveRide) {
      return;
    }

    _checkedActiveRide = true;

    try {
      final response = await _repository.checkActiveRide();
      final booking = response.data;

      if (!response.status || booking == null) {
        return;
      }

      final status = booking.status?.toLowerCase();
      if (status != 'accepted' && status != 'arrived' && status != 'started') {
        return;
      }

      _clearRequestState();
      if (Get.currentRoute != RouteNames.ride) {
        Get.offAllNamed(RouteNames.ride, arguments: booking);
      }
    } catch (e) {
      debugPrint('Error checking active ride: $e');
    }
  }

  void _bindPendingIncomingBooking() {
    if (!Get.isRegistered<FirebaseService>()) {
      return;
    }

    final firebaseService = Get.find<FirebaseService>();
    _pendingIncomingBookingWorker = ever<BookingDataModel?>(
      firebaseService.pendingIncomingBooking,
      (booking) {
        if (booking == null) {
          return;
        }

        if (Get.currentRoute == RouteNames.ride) {
          firebaseService.clearPendingIncomingBooking();
          return;
        }

        showIncomingBookingRequest(booking);
        firebaseService.clearPendingIncomingBooking();
      },
    );
  }

  Future<void> _consumePendingIncomingBooking() async {
    if (!Get.isRegistered<FirebaseService>()) {
      return;
    }

    final firebaseService = Get.find<FirebaseService>();
    final booking = firebaseService.takePendingIncomingBooking();
    if (booking == null) {
      return;
    }

    if (Get.currentRoute == RouteNames.ride) {
      return;
    }

    showIncomingBookingRequest(booking);
  }

  Future<void> toggleOnline() async {
    if (isTogglingOnline.value) return;

    final targetStatus = !isOnline.value;
    isTogglingOnline.value = true;

    try {
      final updatedStatus = await _repository.toggleOnlineStatus(targetStatus);
      isOnline.value = updatedStatus;

      if (isOnline.value) {
        _connectSocket();
        _startTracking();
        Get.snackbar(
          'Online',
          'You are now online and receiving ride requests.',
          backgroundColor: Colors.white,
          colorText: AppColors.textPrimary,
        );
      } else {
        _disconnectSocket();
        _stopTracking();
        Get.snackbar(
          'Offline',
          'You are now offline.',
          backgroundColor: Colors.white,
          colorText: AppColors.textPrimary,
        );
      }
    } catch (e) {
      debugPrint('Error toggling online status: $e');
      final msg = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Action Denied',
        msg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isTogglingOnline.value = false;
    }
  }

  Future<void> logout() async {
    _disconnectSocket();
    await _clearStoredSession();
    ApiClient().revokeTokens();
    Get.offAllNamed(RouteNames.login);
  }

  void _connectSocket() async {
    try {
      final socketService = Get.find<SocketService>();
      final token = await SecureStorageService().read(StorageKeys.token);
      final driverId = await _readDriverId();
      if (token == null || token.isEmpty || driverId == null) {
        Get.snackbar(
          'Offline',
          'Missing login data. Please log in again.',
          backgroundColor: Colors.white,
          colorText: AppColors.textPrimary,
        );
        await _handleMissingSession();
        return;
      }

      await socketService.connect(token);

      // Listen for incoming booking requests
      socketService.on('booking_request', _handleIncomingBookingRequest);

      // Listen for booking status updates (e.g., user cancellation while popup is shown)
      socketService.on('booking_status', _handleBookingStatusUpdate);
    } catch (e) {
      print('Error in _connectSocket: $e');
    }
  }

  void _disconnectSocket() {
    try {
      final socketService = Get.find<SocketService>();
      socketService.off('booking_request', _handleIncomingBookingRequest);
      socketService.off('booking_status', _handleBookingStatusUpdate);
      socketService.disconnect();

      // Clear active request if offline
      _clearRequestState();
    } catch (e) {
      print('Error in _disconnectSocket: $e');
    }
  }

  void _handleIncomingBookingRequest(dynamic data) {
    if (Get.currentRoute == RouteNames.ride) {
      return;
    }

    final bookingMap = data['booking'];
    if (bookingMap != null && bookingMap is Map<String, dynamic>) {
      final booking = BookingDataModel.fromJson(bookingMap);
      showIncomingBookingRequest(booking);
    }
  }

  /// Handles incoming booking_status socket events on the home screen.
  /// Specifically auto-dismisses the accept popup when a user cancels.
  void _handleBookingStatusUpdate(dynamic data) {
    if (data is! Map<String, dynamic>) return;

    final bookingMap = data['booking'];
    if (bookingMap is! Map<String, dynamic>) return;

    final status = bookingMap['status']?.toString().trim().toLowerCase();
    if (status != 'cancelled') return;

    // Only act if the popup is currently showing
    if (!showIncomingRequest.value) return;

    final cancelledId = bookingMap['id'];
    final cancelledNo = bookingMap['booking_no']?.toString();
    final current = incomingRequest.value;

    final idMatch =
        cancelledId != null &&
        current?.id != null &&
        cancelledId.toString() == current!.id.toString();
    final noMatch =
        cancelledNo != null &&
        cancelledNo.isNotEmpty &&
        cancelledNo == current?.bookingNo;

    if (idMatch || noMatch) {
      _clearRequestState();
      Get.snackbar(
        'Ride Cancelled',
        'The passenger cancelled their booking.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Public entry-point for the SocketService to dismiss the popup
  /// when a booking accepted by this driver gets cancelled externally.
  void dismissCancelledRequest(String? bookingNo, dynamic bookingId) {
    if (!showIncomingRequest.value) return;

    final current = incomingRequest.value;
    final idMatch =
        bookingId != null &&
        current?.id != null &&
        bookingId.toString() == current!.id.toString();
    final noMatch =
        bookingNo != null &&
        bookingNo.isNotEmpty &&
        bookingNo == current?.bookingNo;

    if (idMatch || noMatch) {
      _clearRequestState();
      Get.snackbar(
        'Ride Cancelled',
        'The passenger cancelled their booking.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void showIncomingBookingRequest(BookingDataModel booking) {
    _countdownTimer?.cancel();

    incomingRequest.value = booking;
    countdownSeconds.value = 15;
    countdownProgress.value = 1.0;
    showIncomingRequest.value = true;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownSeconds.value > 0) {
        countdownSeconds.value--;
        countdownProgress.value = countdownSeconds.value / 15.0;
      } else {
        timer.cancel();
        _autoDeclineRequest();
      }
    });
  }

  void declineRequest() {
    _clearRequestState();
    Get.snackbar(
      'Ride Request',
      'Ride request declined.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: AppColors.textPrimary,
    );
  }

  void _autoDeclineRequest() {
    _clearRequestState();
    Get.snackbar(
      'Ride Request',
      'Ride request expired.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: AppColors.textPrimary,
    );
  }

  void _clearRequestState() {
    _countdownTimer?.cancel();
    showIncomingRequest.value = false;
    incomingRequest.value = null;
    isAccepting.value = false;
  }

  Future<void> acceptRequest() async {
    if (incomingRequest.value == null || isAccepting.value) return;

    isAccepting.value = true;
    _countdownTimer?.cancel();

    final booking = incomingRequest.value!;
    final bookingId = booking.id;
    final vehicleId = booking.vehicleId;
    final driverId = await _readDriverId();

    try {
      if (bookingId == null) {
        isAccepting.value = false;
        Get.snackbar('Error', 'Booking ID is missing.');
        return;
      }

      if (driverId == null) {
        isAccepting.value = false;
        Get.snackbar(
          'Error',
          'Driver login data is missing. Please log in again.',
        );
        await _handleMissingSession();
        return;
      }

      final response = await _bookingRepository.acceptBooking(
        bookingId,
        driverId,
        vehicleId,
      );

      if (response.status && response.data != null) {
        // Success: Hide the request and navigate to the ride screen.
        _clearRequestState();
        Get.toNamed(RouteNames.ride, arguments: response.data);
      } else {
        // Failure from API (e.g., already on a trip)
        isAccepting.value = false; // Allow user to try again if appropriate
        Get.snackbar(
          'Error',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error accepting booking: $e');
      isAccepting.value = false;
      Get.snackbar(
        'Error',
        'Failed to accept booking. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void simulateIncomingRequest() {
    if (!isOnline.value) {
      Get.snackbar(
        'Offline',
        'Please go online to receive requests.',
        backgroundColor: Colors.white,
      );
      return;
    }

    final mockBooking = BookingDataModel(
      id: 1,
      bookingNo: 'BK-999-XYZ',
      status: 'pending',
      bookingMode: 'instant',
      vehicleCategoryId: 1,
      pickupAddress: 'MG Road Metro Station',
      dropAddress: 'Indiranagar 12th Main Road',
      pickupLatitude: 12.9754,
      pickupLongitude: 77.6061,
      dropLatitude: 12.9718,
      dropLongitude: 77.6412,
      estimatedAmount: 185.00,
      driverName: 'John Wick',
      vehicleNumber: 'KA-03-MY-8888',
      vehicleName: 'Toyota Etios',
    );

    showIncomingBookingRequest(mockBooking);
  }

  Future<int?> _readDriverId() async {
    final storage = StorageService();
    final secureStorage = SecureStorageService();

    final dynamic storedDriverId = storage.read(_driverIdKey);
    if (storedDriverId != null) {
      return int.tryParse(storedDriverId.toString());
    }

    final secureDriverId = await secureStorage.read(_driverIdKey);
    if (secureDriverId != null && secureDriverId.isNotEmpty) {
      return int.tryParse(secureDriverId);
    }

    return null;
  }

  Future<void> _clearStoredSession() async {
    final secureStorage = SecureStorageService();
    final storage = StorageService();
    await secureStorage.delete(StorageKeys.token);
    await secureStorage.delete(_driverIdKey);
    await secureStorage.delete(StorageKeys.walletBalance);
    await secureStorage.delete(StorageKeys.driverStatus);
    storage.delete(StorageKeys.token);
    storage.delete(_driverIdKey);
    storage.delete(StorageKeys.walletBalance);
    storage.delete(StorageKeys.driverStatus);
  }

  Future<void> _handleMissingSession() async {
    _disconnectSocket();
    await _clearStoredSession();
    ApiClient().revokeTokens();
    Get.offAllNamed(RouteNames.login);
  }
}
