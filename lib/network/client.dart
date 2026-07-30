import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:indicab_driver/constants/Keys.dart';
import 'package:indicab_driver/routes/names.dart';
import 'package:indicab_driver/services/SecureStorageService.dart';
import 'package:indicab_driver/services/StorageService.dart';
import 'package:indicab_driver/services/SocketService.dart';
import 'package:indicab_driver/utils/Helpers.dart';
import 'network_exceptions.dart';

class ApiClient {

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  late Dio _dio;
  static bool _isRedirectingToLogin = false;

  ApiClient._internal(){
    _dio = Dio(
      BaseOptions(
        // Live
        // baseUrl: 'https://api.indicab.com',
        
        // Local
        baseUrl: 'http://10.138.29.83:8000/api/driver',

        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    // Add LogInterceptor to automatically print network requests/responses
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));

    // Handle 401 Unauthorized globally
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) async {
          final isUnauthorized = e.response?.statusCode == 401 ||
              (e.response?.data is Map &&
                  (e.response?.data['message'] == 'Unauthenticated.' ||
                      e.response?.data['message'] == 'Unauthenticated'));
          if (isUnauthorized) {
            await handleUnauthorized();
          }
          return handler.next(e);
        },
      ),
    );
  }

  static Future<void> handleUnauthorized() async {
    if (_isRedirectingToLogin) return;
    _isRedirectingToLogin = true;

    try {
      // 1. Revoke tokens in client
      ApiClient().revokeTokens();

      // 2. Clear credentials from SecureStorage and Cache
      final secureStorage = SecureStorageService();
      final storage = StorageService();
      await secureStorage.delete(StorageKeys.token);
      await secureStorage.delete('driverId');
      storage.delete(StorageKeys.token);
      storage.delete('driverId');

      if (Get.isRegistered<SocketService>()) {
        try {
          Get.find<SocketService>().disconnect();
        } catch (_) {}
      }

      // 3. Navigate to login
      Get.offAllNamed(RouteNames.login);

      // 4. Show friendly alert
      Helpers.error("Session expired. Please log in again.");
    } catch (err) {
      print("Error in handleUnauthorized: $err");
    } finally {
      // Allow future unauthorized redirects after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        _isRedirectingToLogin = false;
      });
    }
  }


  // Set tokens
  void setTokens(String accessToken){
    _dio.options.headers['Authorization'] = 'Bearer $accessToken';
    // _dio.options.headers['Refresh-Token'] = 'Bearer $refreshToken';
  }

  // revoke Tokens
  void revokeTokens(){
    _dio.options.headers.remove('Authorization');
    // _dio.options.headers.remove('Refresh-Token');
  }

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<Response> put(
      String path, {
        dynamic data,
      }) async {
    try {
      return await _dio.put(
        path,
        data: data,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<Response> delete(
      String path, {
        dynamic data,
      }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Exception _handleError(DioException e) {
    final status = e.response?.statusCode;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return NetworkException("Connection timed out. Please try again.", statusCode: status);
    }

    if (e.type == DioExceptionType.connectionError) {
      return NetworkException("No internet connection.", statusCode: status);
    }

    // Handle API Validation Errors (e.g., 422 Unprocessable Entity, 400 Bad Request)
    if (e.response != null && e.response?.data != null) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final errorMessage = data['message'] ?? data['error'] ?? "Validation failed";
        return NetworkException(errorMessage.toString(), statusCode: status);
      }
    }

    return NetworkException(e.message ?? "An unexpected error occurred.", statusCode: status);
  }
}
