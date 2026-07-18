import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/constants/Keys.dart';
import 'package:indicab_driver/network/client.dart';
import 'package:indicab_driver/repositories/AuthRepository.dart';
import 'package:indicab_driver/routes/names.dart';
import 'package:indicab_driver/services/SecureStorageService.dart';
import 'package:indicab_driver/services/SocketService.dart';
import 'package:indicab_driver/services/StorageService.dart';
import 'package:permission_handler/permission_handler.dart';

class AuthController extends GetxController {
  AuthController({required AuthRepository repository})
      : _repository = repository;

  final AuthRepository _repository;

  final TextEditingController mobileController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool otpSent = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final secureStorage = SecureStorageService();
    final token = await secureStorage.read(StorageKeys.token);
    if (token != null && token.isNotEmpty) {
      ApiClient().setTokens(token);
      _sendLocationUpdate();
      Get.offAllNamed(RouteNames.home);
    }
  }

  @override
  void onClose() {
    mobileController.dispose();
    otpController.dispose();
    super.onClose();
  }

  void reset() {
    otpSent.value = false;
    otpController.clear();
    errorMessage.value = '';
  }

  Future<void> sendOtp() async {
    final mobile = mobileController.text.trim();
    if (mobile.length < 10) {
      errorMessage.value = 'Please enter a valid mobile number.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _repository.sendOtp(mobile);
      otpSent.value = true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final success = await _repository.verifyOtp(
        mobileController.text,
        otpController.text,
      );

      if (success) {
        _sendLocationUpdate();
        Get.offAllNamed(RouteNames.home);
      } else {
        errorMessage.value = 'Invalid OTP. Please try again.';
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  static const String _driverIdKey = 'driverId';

  Future<void> _sendLocationUpdate() async {
    try {
      final socketService = Get.find<SocketService>();
      final storage = StorageService();
      final secureStorage = SecureStorageService();
      final token = await secureStorage.read(StorageKeys.token);
      final dynamic driverIdValue = storage.read(_driverIdKey);

      if (token == null || driverIdValue == null) {
        print("Token or Driver ID is missing. Cannot send location.");
        return;
      }

      // Ensure socket is connected
      if (!socketService.isConnected.value) {
        await socketService.connect(token);
      }

      // Check and request location permission
      var permissionStatus = await Permission.location.request();
      if (permissionStatus.isGranted) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        final String driverId = driverIdValue.toString();
        final locationData = {
          "type": "driver_location",
          "driver_id": int.tryParse(driverId) ?? 0, // Use the converted string
          "latitude": position.latitude,
          "longitude": position.longitude,
        };
        socketService.send(locationData);
      } else {
        print("Location permission not granted.");
      }
    } catch (e) {
      print("Error sending location update: $e");
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      // 1. Revoke tokens in ApiClient
      ApiClient().revokeTokens();

      // 2. Clear credentials from SecureStorage and StorageService
      final secureStorage = SecureStorageService();
      final storage = StorageService();
      await secureStorage.delete(StorageKeys.token);
      storage.delete(StorageKeys.token);

      // 3. Navigate to login screen
      Get.offAllNamed(RouteNames.login);
    } catch (e) {
      // In case of error, still attempt to navigate to login
      Get.offAllNamed(RouteNames.login);
    } finally {
      isLoading.value = false;
    }
  }
}
