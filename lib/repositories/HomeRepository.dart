import 'package:indicab_driver/models/booking_response.dart';
import 'package:indicab_driver/network/client.dart';
import 'package:indicab_driver/network/endpoints.dart';

class HomeRepository {
  HomeRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> loadDashboard() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'onlineTrips': 18,
      'rating': 4.9,
      'earnings': 12450,
      'todayTrips': 6,
    };
  }

  Future<BookingResponseModel> checkActiveRide() async {
    final response = await _apiClient.get(ApiEndpoints.activeRide);
    final payload = response.data;

    if (payload is Map<String, dynamic>) {
      return BookingResponseModel.fromJson(payload);
    }

    throw Exception('Unexpected active ride response format.');
  }
}
