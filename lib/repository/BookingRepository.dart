import 'package:indicab_driver/models/booking_request.dart';
import 'package:indicab_driver/models/booking_response.dart';
import 'package:indicab_driver/network/client.dart';
import 'package:indicab_driver/network/endpoints.dart';

class BookingRepository {
  BookingRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<BookingResponseModel> createBooking(
    BookingCreateRequest request,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.bookings,
      data: request.toJson(),
    );

    final payload = response.data;
    if (payload is Map<String, dynamic>) {
      return BookingResponseModel.fromJson(payload);
    }

    throw Exception('Unexpected booking response format.');
  }

  Future<BookingResponseModel> getBooking(
    String bookingNo, {
    bool includeOtp = true,
  }) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.bookings}/$bookingNo',
      queryParameters: {if (includeOtp) 'include_otp': 1},
    );

    final payload = response.data;
    if (payload is Map<String, dynamic>) {
      return BookingResponseModel.fromJson(payload);
    }

    throw Exception('Unexpected booking response format.');
  }

  Future<BookingResponseModel> acceptBooking(
    int bookingId,
    int vehicleId,
  ) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.bookings}/$bookingId/accept',
      data: {'vehicle_id': vehicleId},
    );

    final payload = response.data;
    if (payload is Map<String, dynamic>) {
      return BookingResponseModel.fromJson(payload);
    }

    throw Exception('Unexpected booking response format.');
  }
}
