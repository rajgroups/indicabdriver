import 'package:indicab_driver/network/client.dart';
import 'package:indicab_driver/network/endpoints.dart';
import 'package:indicab_driver/services/SecureStorageService.dart';
import 'package:indicab_driver/services/StorageService.dart';
import 'package:indicab_driver/constants/Keys.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  Future<void> sendOtp(String mobileNumber) async {
    if (mobileNumber.trim().length < 10) {
      throw Exception('Enter a valid mobile number.');
    }

    try {
      final response = await _apiClient.post(
        ApiEndpoints.sendOtp,
        data: {'mobile': mobileNumber},
      );

      final payload = response.data;
      if (payload is Map<String, dynamic> && (payload['status'] == true || payload['status'] == 'success')) {
        final otp = payload['data']?['otp']?.toString();
        if (otp != null) {
          print('Backend generated OTP: $otp');
        }
      } else {
        throw Exception(payload['message'] ?? 'Failed to send OTP.');
      }
    } catch (e) {
      print('sendOtp error: $e');
      rethrow;
    }
  }

  static const String _driverIdKey = 'driverId';

  Future<bool> verifyOtp(String mobileNumber, String otp) async {
    if (mobileNumber.trim().length < 10) {
      throw Exception('Enter a valid mobile number.');
    }

    try {
      final response = await _apiClient.post(
        ApiEndpoints.verifyOtp,
        data: {'mobile': mobileNumber, 'otp': otp},
      );

      final payload = response.data;
      if (payload is Map<String, dynamic> && (payload['status'] == true || payload['status'] == 'success')) {
        final data = payload['data'];
        if (data is Map<String, dynamic>) {
          final token = data['token']?.toString();
          final driverData = data['driver'];

          if (token != null && driverData is Map<String, dynamic>) {
            final driverId = driverData['id']?.toString();

          final secureStorage = SecureStorageService();
          final storage = StorageService();
          await secureStorage.write(StorageKeys.token, token);
          storage.write(StorageKeys.token, token);
            if (driverId != null) {
              storage.write(_driverIdKey, driverId);
            }

          _apiClient.setTokens(token);
          return true;
          }
        }
      }
      return false;
    } catch (e) {
      print('verifyOtp error: $e');
      rethrow;
    }
  }
}
