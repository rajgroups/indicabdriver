import 'package:get/get.dart';
import '../controllers/cms_controller.dart';

class CmsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CmsController>(() => CmsController());
  }
}
