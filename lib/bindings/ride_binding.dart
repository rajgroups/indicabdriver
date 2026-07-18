import 'package:get/get.dart';
import 'package:indicab_driver/controllers/RideController.dart';
import 'package:indicab_driver/repositories/RideRepository.dart';

class RideBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RideRepository>(() => RideRepository());
    Get.lazyPut<RideController>(
        () => RideController(repository: Get.find<RideRepository>()));
  }
}