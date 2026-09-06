import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:indicab_driver/config/Config.dart';

class AppConfigService extends GetxService {
  final RxString communicationMode = 'economy'.obs;

  bool get isEconomyMode => communicationMode.value == 'economy';
  bool get isPrimeMode => communicationMode.value == 'prime';

  Future<AppConfigService> init() async {
    await fetchConfig();
    return this;
  }

  Future<void> fetchConfig() async {
    try {
      final baseUrl = AppEnv.apiBaseUrl.replaceAll('/driver', '');
      final response = await Dio().get(
        '$baseUrl/v1/config',
        options: Options(
          headers: {'Accept': 'application/json'},
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          final configData = data['data'];
          if (configData['communication_mode'] != null) {
            communicationMode.value = configData['communication_mode'];
            print('AppConfigService: Communication mode set to ${communicationMode.value}');
          }
        }
      }
    } catch (e) {
      print('AppConfigService: Failed to fetch config: $e');
      // Default safely remains 'economy'
    }
  }
}
