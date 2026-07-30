import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/constants/Keys.dart';
import 'package:indicab_driver/network/client.dart';
import 'package:indicab_driver/repositories/AuthRepository.dart';
import 'package:indicab_driver/routes/names.dart';
import 'package:indicab_driver/services/FirebaseService.dart';
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
  static const String _driverIdKey = 'driverId';

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final secureStorage = SecureStorageService();
    final token = await secureStorage.read(StorageKeys.token);
    final driverId = await _readDriverId();

    if (token != null && token.isNotEmpty && driverId != null) {
      ApiClient().setTokens(token);
      if (Get.isRegistered<SocketService>()) {
        Get.find<SocketService>().setToken(token);
      }
      await _sendLocationUpdate();
      Get.offAllNamed(RouteNames.home);
      return;
    }

    if (token != null || driverId != null) {
      await _clearStoredSession();
    }

    await _navigateToLoginIfNeeded();
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
      String? fcmToken;
      if (Get.isRegistered<FirebaseService>()) {
        final firebaseService = Get.find<FirebaseService>();
        fcmToken = firebaseService.fcmToken.value;
        if (fcmToken.isEmpty) {
          fcmToken = await firebaseService.fetchFcmToken();
        }
      }

      final success = await _repository.verifyOtp(
        mobileController.text,
        otpController.text,
        fcmToken: fcmToken,
      );

      if (success) {
        final secureToken = await SecureStorageService().read(StorageKeys.token);
        if (secureToken != null && secureToken.isNotEmpty && Get.isRegistered<SocketService>()) {
          Get.find<SocketService>().setToken(secureToken);
        }
        await _sendLocationUpdate();
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

  Future<void> _sendLocationUpdate() async {
    try {
      final socketService = Get.find<SocketService>();
      final secureStorage = SecureStorageService();
      final token = await secureStorage.read(StorageKeys.token);
      final driverIdValue = await _readDriverId();

      if (token == null || token.isEmpty || driverIdValue == null) {
        print("Token or Driver ID is missing. Cannot send location.");
        await _redirectToLoginAndClearSession();
        return;
      }

      if (!socketService.isConnected.value) {
        await socketService.ensureConnected();
      }

      if (!socketService.isConnected.value) {
        print('WebSocket is offline. Skipping driver location send.');
        return;
      }

      // Check and request location permission
      var permissionStatus = await Permission.location.request();
      if (!permissionStatus.isGranted) {
        print("Location permission not granted.");
        return;
      }

      final lifecycleState = WidgetsBinding.instance.lifecycleState;
      if (lifecycleState != null && lifecycleState != AppLifecycleState.resumed) {
        print('App is not in the foreground. Skipping driver location send.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final String driverId = driverIdValue.toString();
      final locationData = {
        "type": "driver_location",
        "driver_id": int.tryParse(driverId) ?? 0,
        "latitude": position.latitude,
        "longitude": position.longitude,
      };
      socketService.send(locationData);
    } catch (e) {
      print("Error sending location update: $e");
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _clearStoredSession();
      _disconnectSocketIfAvailable();
      ApiClient().revokeTokens();
      Get.offAllNamed(RouteNames.login);
    } catch (e) {
      await _clearStoredSession();
      _disconnectSocketIfAvailable();
      Get.offAllNamed(RouteNames.login);
    } finally {
      isLoading.value = false;
    }
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
    storage.delete(StorageKeys.token);
    storage.delete(_driverIdKey);
  }

  void _disconnectSocketIfAvailable() {
    if (!Get.isRegistered<SocketService>()) {
      return;
    }

    try {
      Get.find<SocketService>().disconnect();
    } catch (e) {
      print('Error disconnecting socket during auth cleanup: $e');
    }
  }

  Future<void> _redirectToLoginAndClearSession() async {
    await _clearStoredSession();
    _disconnectSocketIfAvailable();
    ApiClient().revokeTokens();
    await _navigateToLoginIfNeeded();
  }

  Future<void> _navigateToLoginIfNeeded() async {
    if (Get.currentRoute == RouteNames.login) {
      return;
    }

    Get.offAllNamed(RouteNames.login);
  }
}
