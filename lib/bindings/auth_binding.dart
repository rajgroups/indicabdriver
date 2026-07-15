import 'package:get/get.dart';
import 'package:indicab_driver/controllers/AuthController.dart';
import 'package:indicab_driver/repositories/AuthRepository.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<AuthController>(
        () => AuthController(repository: Get.find<AuthRepository>()));
  }
}
