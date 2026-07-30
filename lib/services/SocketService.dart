import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/models/booking_response.dart';
import 'package:indicab_driver/network/client.dart';
import 'package:indicab_driver/routes/names.dart';
import 'package:indicab_driver/repository/BookingRepository.dart';
import 'package:indicab_driver/controllers/RideController.dart';

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
  final String _baseUrl = 'ws://10.138.29.83:9502';

  /// Reactive flag to observe connection status across the app.
  final RxBool isConnected = false.obs;

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
        _handleConnectedEvent();
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

  void _handleConnectedEvent() {
    // The server acknowledges auth with a connected payload.
    // No extra action is needed here beyond suppressing the unknown-event log.
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

    if (bookingNo == null || bookingNo.isEmpty) {
      return;
    }

    // Handle cancellation from any screen
    if (status == 'cancelled') {
      Get.snackbar(
        'Ride Cancelled',
        'The booking was cancelled.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      Get.offAllNamed(RouteNames.home);
      return;
    }

    if (Get.currentRoute != RouteNames.ride) {
      final bookingData = BookingDataModel.fromJson(booking);
      if (bookingData != null) {
        Get.offAllNamed(RouteNames.ride, arguments: bookingData);
      }
      return;
    }

    // If already in RideView, update state dynamically
    if (Get.isRegistered<RideController>()) {
      final bookingId = booking['id']?.toString();
      if (bookingId == null) return;

      // When ride starts or completes, fetch full details to get updated OTP or final fare.
      if (status == 'started' || status == 'completed') {
        final bookingData = await _fetchBookingData(bookingId);
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
