import 'dart:convert';
import 'package:indicab_driver/network/client.dart';
import 'package:indicab_driver/network/endpoints.dart';
import 'package:indicab_driver/services/SecureStorageService.dart';
import 'package:indicab_driver/services/StorageService.dart';
import 'package:indicab_driver/constants/Keys.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  static const String _driverIdKey = 'driverId';

  Future<String?> sendOtp(String mobileNumber) async {
    if (mobileNumber.trim().length < 10) {
      throw Exception('Enter a valid mobile number.');
    }

    try {
      final response = await _apiClient.post(
        ApiEndpoints.sendOtp,
        data: {'mobile': mobileNumber},
      );

      var payload = response.data;
      if (payload is String) {
        try {
          payload = jsonDecode(payload);
        } catch (_) {}
      }

      if (payload is Map<String, dynamic> && (payload['status'] == true || payload['status'] == 'success')) {
        final data = payload['data'];
        final otp = (data is Map<String, dynamic>) ? data['otp']?.toString() : null;
        if (otp != null) {
          print('Backend generated OTP: $otp');
        }
        return otp; // Return OTP so controller can show it
      } else {
        String errorMessage = 'Failed to send OTP.';
        if (payload is Map<String, dynamic>) {
          errorMessage = payload['message'] ?? errorMessage;
        } else if (payload is String && payload.isNotEmpty) {
          errorMessage = payload;
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('sendOtp error: $e');
      rethrow;
    }
  }

  Future<bool> verifyOtp(String mobileNumber, String otp, {String? fcmToken}) async {
    if (mobileNumber.trim().length < 10) {
      throw Exception('Enter a valid mobile number.');
    }

    try {
      final Map<String, dynamic> requestData = {
        'mobile': mobileNumber,
        'otp': otp,
      };
      if (fcmToken != null && fcmToken.isNotEmpty) {
        requestData['fcm_token'] = fcmToken;
      }

      final response = await _apiClient.post(
        ApiEndpoints.verifyOtp,
        data: requestData,
      );

      var payload = response.data;
      if (payload is String) {
        try {
          payload = jsonDecode(payload);
        } catch (_) {}
      }

      if (payload is Map<String, dynamic> && (payload['status'] == true || payload['status'] == 'success')) {
        final data = payload['data'];
        if (data is Map<String, dynamic>) {
          final token = data['token']?.toString();
          final driverData = data['driver'];
          final driverId = driverData is Map<String, dynamic> ? driverData['id']?.toString() : null;
          final walletBalance = driverData is Map<String, dynamic>
              ? driverData['wallet_balance']?.toString()
              : null;

          if (token != null && token.isNotEmpty && driverId != null && driverId.isNotEmpty) {
            final secureStorage = SecureStorageService();
            final storage = StorageService();
            await secureStorage.write(StorageKeys.token, token);
            storage.write(StorageKeys.token, token);
            storage.write(_driverIdKey, driverId);
            await secureStorage.write(_driverIdKey, driverId);

            if (walletBalance != null && walletBalance.isNotEmpty) {
              storage.write(StorageKeys.walletBalance, walletBalance);
              await secureStorage.write(StorageKeys.walletBalance, walletBalance);
            }

            _apiClient.setTokens(token);
            return true;
          }

          await _clearStoredAuthData();
          throw Exception('Login data is incomplete. Please log in again.');
        }
      }
      return false;
    } catch (e) {
      print('verifyOtp error: $e');
      rethrow;
    }
  }

  Future<void> _clearStoredAuthData() async {
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
}
