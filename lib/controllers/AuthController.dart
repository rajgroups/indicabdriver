import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/constants/Keys.dart';
import 'package:indicab_driver/network/client.dart';
import 'package:indicab_driver/repositories/AuthRepository.dart';
import 'package:indicab_driver/routes/names.dart';
import 'package:indicab_driver/services/SecureStorageService.dart';

class AuthController extends GetxController {
  AuthController({required AuthRepository repository}) : _repository = repository;

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
}
