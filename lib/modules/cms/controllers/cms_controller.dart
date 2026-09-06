import 'package:get/get.dart';
import 'package:indicab_driver/network/client.dart';
import 'package:indicab_driver/utils/Helpers.dart';

class CmsController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  final RxBool isLoading = true.obs;
  final RxString title = ''.obs;
  final RxString content = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final slug = Get.arguments?['slug'] as String?;
    if (slug != null) {
      fetchPage(slug);
    } else {
      isLoading.value = false;
      content.value = 'Page not found';
    }
  }

  Future<void> fetchPage(String slug) async {
    try {
      isLoading.value = true;
      final response = await _apiClient.get('/v1/cms/$slug');
      
      if (response.statusCode == 200) {
        final data = response.data['data'];
        title.value = data['title'] ?? 'Page';
        content.value = data['content'] ?? '';
      } else {
        Helpers.error('Failed to load page content.');
      }
    } catch (e) {
      Helpers.error('Error loading page: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
