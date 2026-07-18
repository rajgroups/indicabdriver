import 'package:indicab_driver/network/client.dart';
import 'package:indicab_driver/network/endpoints.dart';
import 'package:indicab_driver/models/booking_response.dart';

class RideRepository {
  final ApiClient _apiClient = ApiClient();

  Future<BookingResponseModel> startRide(int bookingId, String otp) async {
    final response = await _apiClient.post(
      ApiEndpoints.startBooking(bookingId),
      data: {'start_otp': otp},
    );

    final payload = response.data;
    if (payload is Map<String, dynamic>) {
      return BookingResponseModel.fromJson(payload);
    }
    throw Exception('Unexpected response format.');
  }

  Future<BookingResponseModel> completeRide(int bookingId, String otp) async {
    final response = await _apiClient.post(
      ApiEndpoints.completeBooking(bookingId),
      data: {'end_otp': otp},
    );

    final payload = response.data;
    if (payload is Map<String, dynamic>) {
      return BookingResponseModel.fromJson(payload);
    }
    throw Exception('Unexpected response format.');
  }
}
