import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/repositories/HomeRepository.dart';
import 'package:indicab_driver/repository/BookingRepository.dart';
import 'package:indicab_driver/routes/names.dart';
import 'package:indicab_driver/services/SocketService.dart';
import 'package:indicab_driver/services/SecureStorageService.dart';
import 'package:indicab_driver/services/StorageService.dart';
import 'package:indicab_driver/constants/Keys.dart';
import 'package:indicab_driver/constants/Colors.dart';
import 'package:indicab_driver/models/booking_response.dart';

class HomeController extends GetxController {
  HomeController({
    required HomeRepository repository,
    required BookingRepository bookingRepository,
  })  : _repository = repository,
        _bookingRepository = bookingRepository;

  final HomeRepository _repository;
  final BookingRepository _bookingRepository;

  final RxBool isOnline = true.obs;
  final RxBool isLoading = true.obs;
  final RxInt onlineTrips = 0.obs;
  final RxInt todayTrips = 0.obs;
  final RxDouble rating = 0.0.obs;
  final RxInt earnings = 0.obs;

  // Incoming Booking request states
  final RxBool showIncomingRequest = false.obs;
  final Rxn<BookingDataModel> incomingRequest = Rxn<BookingDataModel>();
  final RxInt countdownSeconds = 15.obs;
  final RxDouble countdownProgress = 1.0.obs;
  final RxBool isAccepting = false.obs;

  Timer? _countdownTimer;
  static const String _driverIdKey = 'driverId';
  bool _checkedActiveRide = false;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
    if (isOnline.value) {
      _connectSocket();
    }
    Future.microtask(_checkActiveRide);
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    try {
      final socketService = Get.find<SocketService>();
      socketService.off('booking_request', _handleIncomingBookingRequest);
    } catch (e) {
      print('Error removing booking listener in onClose: $e');
    }
    super.onClose();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    final data = await _repository.loadDashboard();
    onlineTrips.value = data['onlineTrips'] as int;
    todayTrips.value = data['todayTrips'] as int;
    rating.value = (data['rating'] as num).toDouble();
    earnings.value = data['earnings'] as int;
    isLoading.value = false;
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
      if (status != 'accepted' && status != 'started') {
        return;
      }

      _clearRequestState();
      if (Get.currentRoute != RouteNames.ride) {
        Get.offAllNamed(RouteNames.ride, arguments: booking);
      }
    } catch (e) {
      print('Error checking active ride: $e');
    }
  }

  void toggleOnline() {
    isOnline.toggle();
    if (isOnline.value) {
      _connectSocket();
    } else {
      _disconnectSocket();
    }
  }

  void logout() {
    _disconnectSocket();
    Get.offAllNamed(RouteNames.login);
  }

  void _connectSocket() async {
    try {
      final socketService = Get.find<SocketService>();
      final token = await SecureStorageService().read(StorageKeys.token);
      if (token == null || token.isEmpty) {
        Get.snackbar(
          'Offline',
          'Missing auth token. Please log in again.',
          backgroundColor: Colors.white,
          colorText: AppColors.textPrimary,
        );
        return;
      }

      await socketService.connect(token);

      // Listen for incoming booking requests
      socketService.on('booking_request', _handleIncomingBookingRequest);
    } catch (e) {
      print('Error in _connectSocket: $e');
    }
  }

  void _disconnectSocket() {
    try {
      final socketService = Get.find<SocketService>();
      socketService.off('booking_request', _handleIncomingBookingRequest);
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
    final driverIdValue = StorageService().read(_driverIdKey);
    final driverId = int.tryParse(driverIdValue?.toString() ?? '');

    try {
      if (bookingId == null) {
        isAccepting.value = false;
        Get.snackbar('Error', 'Booking ID is missing.');
        return;
      }

      if (driverId == null) {
        isAccepting.value = false;
        Get.snackbar('Error', 'Driver ID is missing.');
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
      Get.snackbar('Offline', 'Please go online to receive requests.', backgroundColor: Colors.white);
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
      estimatedAmount: 185.00,
      driverName: 'John Wick',
      vehicleNumber: 'KA-03-MY-8888',
      vehicleName: 'Toyota Etios',
    );

    showIncomingBookingRequest(mockBooking);
  }
}
