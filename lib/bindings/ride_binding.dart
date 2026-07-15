import 'package:get/get.dart';
import 'package:indicab_driver/controllers/ride_controller.dart';
import 'package:indicab_driver/repositories/ride_repository.dart';

class RideBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RideRepository>(() => RideRepository());
    Get.lazyPut<RideController>(
        () => RideController(repository: Get.find<RideRepository>()));
  }
}