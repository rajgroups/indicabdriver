import 'package:indicab_driver/models/Vehicle.dart';
import 'package:indicab_driver/network/client.dart';
import 'package:indicab_driver/network/endpoints.dart';

class VehicleRespository {
  final ApiClient _apiService;

  VehicleRespository(this._apiService);

  Future<List<VehicleModel>>  getTypeVehicles({
    double lat = 1,
    double lng = 10,
    int radius = 400,
    int? category,
    String? search,
  }) async {
    final Map<String, dynamic> queryParameters = {
      'lat': lat,
      'lng': lng,
      'radius': radius,
    };

    if (category != null) queryParameters['category'] = category;
    if (search != null && search.isNotEmpty) queryParameters['search'] = search;

    final response = await _apiService.get(
      ApiEndpoints.vehicletypelist,
      queryParameters: queryParameters,
    );

  final List data = response.data['data'];

  return data
      .map((e) => VehicleModel.fromJson(e))
      .toList();
  }
}