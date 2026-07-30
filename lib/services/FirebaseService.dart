import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/network/client.dart';
import 'package:indicab_driver/network/endpoints.dart';
import 'package:indicab_driver/models/booking_response.dart';
import 'package:indicab_driver/repository/BookingRepository.dart';
import 'package:indicab_driver/routes/names.dart';
import 'package:indicab_driver/services/SocketService.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("FCM Background Message ID: ${message.messageId} Data: ${message.data}");
}

class FirebaseService extends GetxService {
  final RxString fcmToken = ''.obs;
  final Rxn<BookingDataModel> pendingIncomingBooking = Rxn<BookingDataModel>();
  final BookingRepository _bookingRepository = BookingRepository(ApiClient());

  Future<FirebaseService> init() async {
    try {
      await Firebase.initializeApp();
      print("Firebase initialized successfully");

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await _requestPermission();
      await fetchFcmToken();

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        fcmToken.value = newToken;
        sendTokenToBackend(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("FCM Foreground Message: ${message.notification?.title} - ${message.data}");
        _handleIncomingNotification(message, isClicked: false);
      });

      // Handle notification taps from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("FCM Notification Tapped: ${message.data}");
        _handleIncomingNotification(message, isClicked: true);
      });

      // Check if app was launched from a terminated state notification tap
      RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        print("FCM Terminated App Launch Message: ${initialMessage.data}");
        _handleIncomingNotification(initialMessage, isClicked: true);
      }
    } catch (e) {
      print("Error initializing FirebaseService: $e");
    }
    return this;
  }

  Future<void> _requestPermission() async {
    try {
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      print('User granted notification permission: ${settings.authorizationStatus}');
    } catch (e) {
      print("Error requesting notification permission: $e");
    }
  }

  Future<String?> fetchFcmToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        fcmToken.value = token;
        print("FCM Token retrieved: $token");
      }
      return token;
    } catch (e) {
      print("Error fetching FCM token: $e");
      return null;
    }
  }

  Future<void> sendTokenToBackend(String token) async {
    if (token.isEmpty) return;
    try {
      final response = await ApiClient().post(
        ApiEndpoints.updateFcmToken,
        data: {'fcm_token': token},
      );
      print("FCM token updated on backend: ${response.data}");
    } catch (e) {
      print("Failed to send FCM token to backend: $e");
    }
  }

  void _handleIncomingNotification(RemoteMessage message, {bool isClicked = false}) {
    final title = message.notification?.title ?? message.data['title'] ?? 'Ride Update';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    final data = message.data;
    final type = data['type'];

    if (!isClicked) {
      Get.snackbar(
        title,
        body,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    }

    if (type == 'new_ride_request') {
      _handleRideRequestNotification(message, isClicked: isClicked);
      return;
    }

    if (type == 'booking_status') {
      if (Get.isRegistered<SocketService>()) {
        Get.find<SocketService>().ensureConnected();
      }
    }
  }

  Future<void> _handleRideRequestNotification(
    RemoteMessage message, {
    required bool isClicked,
  }) async {
    try {
      if (Get.currentRoute == RouteNames.ride) {
        return;
      }

      final booking = await _resolveIncomingBooking(message.data);
      if (booking == null) {
        return;
      }

      pendingIncomingBooking.value = booking;

      if (isClicked && Get.currentRoute != RouteNames.home) {
        Get.offAllNamed(RouteNames.home);
      }
    } catch (e) {
      print("Error handling incoming ride request notification: $e");
    }
  }

  Future<BookingDataModel?> _resolveIncomingBooking(Map<String, dynamic> data) async {
    final bookingPayload = data['booking'];

    if (bookingPayload is String && bookingPayload.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(bookingPayload);
        if (decoded is Map<String, dynamic>) {
          return BookingDataModel.fromJson(decoded);
        }
      } catch (e) {
        print("Failed to decode booking payload from FCM: $e");
      }
    } else if (bookingPayload is Map<String, dynamic>) {
      return BookingDataModel.fromJson(bookingPayload);
    }

    final summaryBooking = _bookingFromNotificationData(data);
    if (summaryBooking != null) {
      return summaryBooking;
    }

    final bookingNo = data['booking_no']?.toString();
    if (bookingNo == null || bookingNo.isEmpty) {
      return null;
    }

    try {
      final response = await _bookingRepository.getBooking(bookingNo, includeOtp: false);
      return response.data;
    } catch (e) {
      print("Failed to fetch booking for FCM notification: $e");
      return null;
    }
  }

  BookingDataModel? _bookingFromNotificationData(Map<String, dynamic> data) {
    final bookingNo = data['booking_no']?.toString();
    if (bookingNo == null || bookingNo.isEmpty) {
      return null;
    }

    return BookingDataModel(
      id: int.tryParse(data['booking_id']?.toString() ?? ''),
      bookingNo: bookingNo,
      status: data['status']?.toString() ?? 'pending',
      bookingMode: data['booking_mode']?.toString() ?? data['service_mode']?.toString() ?? 'instant',
      vehicleCategoryId: int.tryParse(data['vehicle_category_id']?.toString() ?? '') ?? 0,
      driverId: int.tryParse(data['driver_id']?.toString() ?? ''),
      vehicleId: int.tryParse(data['vehicle_id']?.toString() ?? ''),
      scheduledAt: data['scheduled_at']?.toString(),
      pickupAddress: data['pickup_address']?.toString(),
      dropAddress: data['drop_address']?.toString(),
      pickupLatitude: double.tryParse(data['pickup_latitude']?.toString() ?? ''),
      pickupLongitude: double.tryParse(data['pickup_longitude']?.toString() ?? ''),
      dropLatitude: double.tryParse(data['drop_latitude']?.toString() ?? ''),
      dropLongitude: double.tryParse(data['drop_longitude']?.toString() ?? ''),
      estimatedAmount: double.tryParse(data['estimated_amount']?.toString() ?? ''),
      passengerName: data['passenger_name']?.toString(),
      vehicleNumber: data['vehicle_number']?.toString(),
      vehicleName: data['vehicle_name']?.toString(),
      categoryName: data['category_name']?.toString(),
      notes: data['notes']?.toString(),
    );
  }

  BookingDataModel? takePendingIncomingBooking() {
    final booking = pendingIncomingBooking.value;
    pendingIncomingBooking.value = null;
    return booking;
  }

  void clearPendingIncomingBooking() {
    pendingIncomingBooking.value = null;
  }
}
