import 'package:indicab_driver/models/booking_request.dart';
import 'package:indicab_driver/models/booking_response.dart';
import 'package:indicab_driver/network/client.dart';
import 'package:indicab_driver/network/network_exceptions.dart';
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
      ApiEndpoints.bookingDetails(bookingNo),
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
    int driverId,
    int? vehicleId,
  ) async {
    final payload = <String, dynamic>{
      'driver_id': driverId,
    };

    if (vehicleId != null) {
      payload['vehicle_id'] = vehicleId;
    }

    try {
      final response = await _apiClient.post(
        ApiEndpoints.acceptBooking(bookingId),
        data: payload,
      );

      final responsePayload = response.data;
      if (responsePayload is Map<String, dynamic>) {
        return BookingResponseModel.fromJson(responsePayload);
      }

      throw Exception('Unexpected booking response format.');
    } on NetworkException catch (e) {
      // Re-throw API errors with a structured response so the controller can display the message.
      return BookingResponseModel(status: false, message: e.message, data: null);
    } catch (e) {
      throw Exception('Failed to accept booking: $e');
    }
  }
}
