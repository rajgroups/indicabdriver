import 'package:get/get.dart';
import 'package:indicab_driver/controllers/HomeController.dart';
import 'package:indicab_driver/repositories/HomeRepository.dart';
import 'package:indicab_driver/repository/BookingRepository.dart';
import 'package:indicab_driver/network/client.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeRepository>(() => HomeRepository());
    Get.lazyPut<BookingRepository>(() => BookingRepository(ApiClient()));
    Get.lazyPut<HomeController>(
        () => HomeController(
              repository: Get.find<HomeRepository>(),
              bookingRepository: Get.find<BookingRepository>(),
            ));
  }
}
