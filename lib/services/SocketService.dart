import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/constants/Keys.dart';
import 'package:indicab_driver/models/Driver.dart';
import 'package:indicab_driver/models/booking_response.dart';
import 'package:indicab_driver/network/client.dart';
import 'package:indicab_driver/routes/names.dart';
import 'package:indicab_driver/repository/BookingRepository.dart';
import 'package:indicab_driver/controllers/RideController.dart';
import 'package:indicab_driver/controllers/HomeController.dart';
import 'package:indicab_driver/services/SecureStorageService.dart';
import 'package:indicab_driver/services/StorageService.dart';
import 'package:indicab_driver/utils/AppUpdateHelper.dart';

/// A map to hold event handlers.
typedef EventCallback = void Function(dynamic data);

class SocketService extends GetxService with WidgetsBindingObserver {
  WebSocket? _socket;
  String? _token;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  bool _shouldReconnect = true;
  bool _isAppInForeground = true;
  final BookingRepository _bookingRepository = BookingRepository(ApiClient());

  /// Base URL for the WebSocket connection.
  final String _baseUrl = 'ws://10.82.106.83:9502';

  /// Reactive flag to observe connection status across the app.
  final RxBool isConnected = false.obs;
  final Rxn<DriverModel> currentDriver = Rxn<DriverModel>();

  /// A map to store event listeners. Controllers can subscribe to events they are interested in.
  final Map<String, List<EventCallback>> _eventListeners = {};

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    disconnect();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print('WebSocket: App resumed, checking connection.');
      ensureConnected();
    } else if (state == AppLifecycleState.paused) {
      print('WebSocket: App is paused.');
    } else if (state == AppLifecycleState.detached) {
      disconnect(); // Disconnect only when the app is being terminated.
    }
  }

  /// Establishes a connection to the WebSocket server.
  /// It stores the token for automatic reconnection.
  Future<void> connect(String token) async {
    _token = token;
    _shouldReconnect = true;
    final url = '$_baseUrl?token=$_token';

    try {
      _socket = await WebSocket.connect(url);
      isConnected.value = true;
      print('WebSocket: Connected successfully.');

      _socket!.listen(
        _onData,
        onDone: _onDone,
        onError: _onError,
        cancelOnError: true,
      );

      // Handle the connection event
      _handleConnected();
    } catch (e) {
      print('WebSocket: Connection error: $e');
      _onError(e);
    }
  }

  /// Closes the WebSocket connection and stops any timers.
  void disconnect() {
    print('WebSocket: Disconnecting...');
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _socket?.close();
    _socket = null;
    isConnected.value = false;
    currentDriver.value = null;
  }

  void setToken(String token) {
    _token = token;
  }

  bool get hasToken => _token != null && _token!.isNotEmpty;

  Future<void> ensureConnected() async {
    if (isConnected.value || !hasToken) {
      return;
    }

    await connect(_token!);
  }

  /// Sends data to the server. The data is encoded as a JSON string.
  void send(Map<String, dynamic> data) {
    if (_socket != null && isConnected.value) {
      final message = json.encode(data);
      print('WebSocket: SEND => $message');
      _socket!.add(message);
    } else {
      print('WebSocket: Cannot send data, socket is not connected.');
    }
  }

  /// Sends a ping message to keep the connection alive.
  void sendPing() {
    send({'type': 'ping'});
  }

  /// Allows other parts of the app to subscribe to a specific event type.
  void on(String event, EventCallback callback) {
    _eventListeners.putIfAbsent(event, () => []).add(callback);
  }

  /// Allows other parts of the app to unsubscribe from an event.
  void off(String event, EventCallback callback) {
    if (_eventListeners.containsKey(event)) {
      _eventListeners[event]!.remove(callback);
    }
  }

  /// Internal handler for incoming data.
  void _onData(dynamic data) {
    print('WebSocket: RECEIVED => $data');
    try {
      final Map<String, dynamic> message = json.decode(data);
      final String eventType = message['type'] ?? 'unknown';

      // Route event to a specific handler if needed, e.g., for global actions.
      _routeEvent(eventType, message);

      // Notify generic listeners for this event type
      if (_eventListeners.containsKey(eventType)) {
        for (var callback in _eventListeners[eventType]!) {
          callback(message);
        }
      }
    } catch (e) {
      print('WebSocket: Error parsing message: $e');
    }
  }

  /// Internal handler for when the connection is closed by the server.
  void _onDone() {
    print('WebSocket: Disconnected by server.');
    isConnected.value = false;
    _pingTimer?.cancel();
    if (_shouldReconnect) {
      _tryReconnect();
    }
  }

  /// Internal handler for any connection errors.
  void _onError(dynamic error) {
    print('WebSocket: Socket Error: $error');
    isConnected.value = false;
    _pingTimer?.cancel();
    if (_shouldReconnect) {
      _tryReconnect();
    }
  }

  /// Attempts to reconnect to the server after a delay.
  void _tryReconnect() {
    if (!_shouldReconnect) {
      return;
    }
    if (_reconnectTimer?.isActive ?? false) return;

    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      print('WebSocket: Attempting to reconnect...');
      if (_token != null) {
        connect(_token!);
      } else {
        print('WebSocket: Cannot reconnect, token is missing.');
      }
    });
  }

  /// Routes events to internal handlers for global actions.
  void _routeEvent(String eventType, Map<String, dynamic> data) {
    switch (eventType) {
      case 'connected':
        _handleConnectedEvent(data);
        break;
      case 'app_update':
        if (data['app_update'] is Map<String, dynamic>) {
          AppUpdateHelper.evaluateAndShowUpdateNotice(data['app_update'] as Map<String, dynamic>);
        } else if (data['data'] is Map<String, dynamic>) {
          AppUpdateHelper.evaluateAndShowUpdateNotice(data['data'] as Map<String, dynamic>);
        } else {
          AppUpdateHelper.evaluateAndShowUpdateNotice(data);
        }
        break;
      case 'pong':
        _handlePong();
        break;
      case 'auth_error':
        _handleAuthError(data);
        break;
      case 'booking_request':
      case 'booking_status':
        unawaited(_handleBookingEvent(eventType, data));
        break;
      case 'location_updated':
        // Acknowledged from server, handled silently
        break;
      default:
        print('WebSocket: Received unknown event type: $eventType');
    }
  }
  // --- Event Handler Methods ---

  void _handleConnected() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      sendPing();
    });
  }

  void _handleConnectedEvent(Map<String, dynamic> data) {
    if (data['app_update'] is Map<String, dynamic>) {
      AppUpdateHelper.evaluateAndShowUpdateNotice(data['app_update'] as Map<String, dynamic>);
    }

    final driverData = data['driver'];
    if (driverData is! Map<String, dynamic>) {
      return;
    }

    final driver = DriverModel.fromJson(driverData);
    currentDriver.value = driver;

    final walletBalance = driver.walletBalance;
    final driverStatus = driver.status;

    if (walletBalance != null) {
      final walletBalanceText = walletBalance.toStringAsFixed(2);
      StorageService().write(StorageKeys.walletBalance, walletBalanceText);
      unawaited(
        SecureStorageService().write(StorageKeys.walletBalance, walletBalanceText),
      );
    }

    if (driverStatus != null && driverStatus.isNotEmpty) {
      StorageService().write(StorageKeys.driverStatus, driverStatus);
      unawaited(
        SecureStorageService().write(StorageKeys.driverStatus, driverStatus),
      );
    }
  }

  void _handleAuthError(Map<String, dynamic> data) {
    print('WebSocket: Authentication error: ${data['message']}');
    disconnect();
    ApiClient.handleUnauthorized();
  }

  void _handlePong() {
    print('WebSocket: Pong received.');
  }

  Future<void> _handleBookingEvent(
    String eventType,
    Map<String, dynamic> data,
  ) async {
    if (eventType != 'booking_status') {
      return;
    }

    final booking = data['booking'];
    if (booking is! Map<String, dynamic>) {
      return;
    }

    final status = booking['status']?.toString();
    final bookingNo = booking['booking_no']?.toString();
    final bookingId = booking['id'];

    // ── Handle Cancellation ──────────────────────────────────────────────
    if (status == 'cancelled') {
      // Case A: Driver is on the home screen with an accept popup open.
      //         Dismiss it if the cancelled booking matches.
      if (Get.isRegistered<HomeController>()) {
        try {
          final homeCtrl = Get.find<HomeController>();
          homeCtrl.dismissCancelledRequest(bookingNo, bookingId);
        } catch (e) {
          print('SocketService: Error dismissing popup on cancel: $e');
        }
      }

      // Case B: Driver already accepted and is on the ride screen.
      if (Get.currentRoute == RouteNames.ride) {
        Get.snackbar(
          'Ride Cancelled',
          'The booking was cancelled by the passenger.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        Get.offAllNamed(RouteNames.home);
      }
      return;
    }

    // ── Route to RideController if already on the ride screen ─────────────
    if (bookingNo == null || bookingNo.isEmpty) {
      return;
    }

    if (Get.currentRoute != RouteNames.ride) {
      final bookingData = BookingDataModel.fromJson(booking);
      Get.offAllNamed(RouteNames.ride, arguments: bookingData);
      return;
    }

    // If already in RideView, update state dynamically
    if (Get.isRegistered<RideController>()) {
      final bookingIdStr = booking['id']?.toString();
      if (bookingIdStr == null) return;

      // When ride starts or completes, fetch full details to get updated OTP or final fare.
      if (status == 'started' || status == 'completed') {
        final bookingData = await _fetchBookingData(bookingIdStr);
        if (bookingData != null && Get.isRegistered<RideController>()) {
          final rideCtrl = Get.find<RideController>();
          rideCtrl.booking.value = bookingData;

          if (status == 'started') {
            rideCtrl.rideStatus.value = RideStatus.in_progress;
          } else if (status == 'completed') {
            rideCtrl.rideStatus.value = RideStatus.completed;
          }
        }
      }
    }
  }

  Future<BookingDataModel?> _fetchBookingData(String bookingNo) async {
    try {
      final response = await _bookingRepository.getBooking(
        bookingNo,
        includeOtp: true,
      );
      return response.data;
    } catch (error) {
      print(
        'WebSocket: Failed to fetch booking details for $bookingNo: $error',
      );
      return null;
    }
  }
}
