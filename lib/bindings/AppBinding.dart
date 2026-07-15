import 'package:get/get.dart';
import '../../modules/auth/AuthController.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
  }
}