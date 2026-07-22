import 'package:flutter/foundation.dart';
import 'package:indicab_driver/network/client.dart';
import 'package:indicab_driver/network/endpoints.dart';
import 'package:indicab_driver/models/booking_response.dart';
import 'package:indicab_driver/models/ride_history_item.dart';

class HistoryRepository {
  final ApiClient _apiClient = ApiClient();

  /// Fetch driver bookings with optional filters and pagination
  Future<Map<String, dynamic>> fetchHistory({
    String? status,
    String? dateFilter,
    String? type,
    String? paymentMethod,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    int page = 1,
    int perPage = 15,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      queryParams['status'] = status.toLowerCase();
    }
    if (dateFilter != null && dateFilter.isNotEmpty && dateFilter.toLowerCase() != 'all') {
      queryParams['date_filter'] = dateFilter.toLowerCase().replaceAll(' ', '_');
    }
    if (type != null && type.isNotEmpty && type.toLowerCase() != 'all') {
      queryParams['type'] = type;
    }
    if (paymentMethod != null && paymentMethod.isNotEmpty && paymentMethod.toLowerCase() != 'all') {
      queryParams['payment_method'] = paymentMethod.toLowerCase();
    }
    if (minPrice != null && minPrice > 0) {
      queryParams['min_price'] = minPrice;
    }
    if (maxPrice != null && maxPrice > 0 && maxPrice < 2000) {
      queryParams['max_price'] = maxPrice;
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParams['sort_by'] = sortBy;
    }

    final response = await _apiClient.get(
      ApiEndpoints.bookings,
      queryParameters: queryParams,
    );

    final payload = response.data;
    if (payload is Map<String, dynamic>) {
      final dataList = payload['data'];
      final List<BookingDataModel> bookings = [];

      if (dataList is List) {
        for (var item in dataList) {
          if (item is Map<String, dynamic>) {
            bookings.add(BookingDataModel.fromJson(item));
          }
        }
      }

      final meta = payload['meta'] is Map<String, dynamic> ? payload['meta'] : <String, dynamic>{};

      return {
        'bookings': bookings,
        'has_more': meta['has_more'] ?? false,
        'total_rides': meta['total_rides'] ?? bookings.length,
        'total_spent': (meta['total_spent'] ?? meta['total_earnings'] ?? 0.0) as num,
        'average_rating': (meta['average_rating'] ?? 4.9) as num,
      };
    }

    throw Exception('Failed to load ride history.');
  }

  /// Fetch invoice fare breakdown for a booking
  Future<RideHistoryItem> fetchBookingFare(dynamic bookingId) async {
    final response = await _apiClient.get(
      ApiEndpoints.bookingFare(bookingId),
    );

    final payload = response.data;
    if (payload is Map<String, dynamic> && payload['data'] is Map<String, dynamic>) {
      return RideHistoryItem.fromJson(payload['data']);
    }

    throw Exception('Failed to load booking fare invoice.');
  }
}
