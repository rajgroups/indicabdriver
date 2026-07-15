import 'package:get/get.dart';
import 'package:indicab/modules/home/HomeController.dart';
import 'package:indicab/core/controller/BookingController.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    if (!Get.isRegistered<BookingController>()) {
      Get.lazyPut<BookingController>(() => BookingController());
    }
  }
}
