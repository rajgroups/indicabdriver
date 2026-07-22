import 'package:flutter/foundation.dart';
import 'package:indicab_driver/models/booking_response.dart';
import 'package:indicab_driver/network/client.dart';
import 'package:indicab_driver/network/endpoints.dart';


class HomeRepository {
  HomeRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> loadDashboard() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.dashboard);
      final payload = response.data;

      if (payload is Map<String, dynamic> && payload['data'] is Map<String, dynamic>) {
        final data = payload['data'] as Map<String, dynamic>;
        final List<BookingDataModel> recentBookings = [];

        if (data['recent_trips'] is List) {
          for (var item in (data['recent_trips'] as List)) {
            if (item is Map<String, dynamic>) {
              recentBookings.add(BookingDataModel.fromJson(item));
            }
          }
        }

        return {
          'is_online': data['is_online'] as bool? ?? false,
          'todayTrips': (data['today_trips'] as num? ?? 0).toInt(),
          'rating': (data['average_rating'] as num? ?? 4.9).toDouble(),
          'earnings': (data['today_earnings'] as num? ?? 0.0).toDouble(),
          'recentBookings': recentBookings,
        };
      }
    } catch (e) {
      debugPrint('loadDashboard API error, fallback: $e');
    }


    return {
      'is_online': true,
      'todayTrips': 0,
      'rating': 4.9,
      'earnings': 0.0,
      'recentBookings': <BookingDataModel>[],
    };
  }

  Future<bool> toggleOnlineStatus(bool isOnline) async {
    final response = await _apiClient.post(
      ApiEndpoints.onlineStatus,
      data: {'is_online': isOnline},
    );

    final payload = response.data;
    if (payload is Map<String, dynamic> && payload['status'] == true) {
      final data = payload['data'];
      if (data is Map<String, dynamic> && data['is_online'] != null) {
        return data['is_online'] as bool;
      }
      return isOnline;
    }

    throw Exception(payload['message'] ?? 'Failed to update online status.');
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

