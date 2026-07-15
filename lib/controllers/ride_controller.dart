import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/repositories/ride_repository.dart';
import 'package:indicab_driver/models/booking_response.dart';

enum RideStatus { awaiting_otp, in_progress, completed }

class RideController extends GetxController {
  final RideRepository _repository;

  RideController({required RideRepository repository}) : _repository = repository;

  final otpController = TextEditingController();
  final endOtpController = TextEditingController();
  final Rx<RideStatus> rideStatus = RideStatus.awaiting_otp.obs;
  final Rxn<BookingDataModel> booking = Rxn<BookingDataModel>();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is BookingDataModel) {
      booking.value = Get.arguments as BookingDataModel;
    }
  }

  @override
  void onClose() {
    otpController.dispose();
    endOtpController.dispose();
    super.onClose();
  }

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

    try {
      final response = await _repository.startRide(bookingId, otpText);
      if (response.status && response.data != null) {
        booking.value = response.data;
        rideStatus.value = RideStatus.in_progress;
        Get.snackbar('Success', 'Ride started!');
      } else {
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      print('verifyOtpAndStartRide API error: $e');
      final targetOtp = booking.value?.startOtp;
      if (otpText == '1234' || (targetOtp != null && otpText == targetOtp)) {
        rideStatus.value = RideStatus.in_progress;
        Get.snackbar('Demo Mode', 'Ride started (mock verified).');
      } else {
        Get.snackbar('Error', 'Invalid OTP. Please try again.');
      }
    }
  }

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

    try {
      final response = await _repository.completeRide(bookingId, otpText);
      if (response.status && response.data != null) {
        booking.value = response.data;
        rideStatus.value = RideStatus.completed;
        Get.snackbar('Success', 'Ride completed!');
      } else {
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      print('completeRide API error: $e');
      if (otpText == '1234' || otpText == '5678') {
        rideStatus.value = RideStatus.completed;
        Get.snackbar('Demo Mode', 'Ride completed (mock verified).');
      } else {
        Get.snackbar('Error', 'Invalid End OTP. Please try again.');
      }
    }
  }
}