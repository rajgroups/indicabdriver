import 'package:get/get.dart';
import 'package:indicab_driver/bindings/auth_binding.dart';
import 'package:indicab_driver/bindings/home_binding.dart';
import 'package:indicab_driver/bindings/ride_binding.dart';
import 'package:indicab_driver/routes/names.dart';
import 'package:indicab_driver/views/HomeView.dart';
import 'package:indicab_driver/views/LoginView.dart';
import 'package:indicab_driver/views/RideView.dart';
import 'package:indicab_driver/views/SplashView.dart';

import 'package:indicab_driver/views/RideHistory.dart';
import 'package:indicab_driver/views/RideDetails.dart';

class AppPages {
  static const initialRoute = RouteNames.splash;

  static final routes = [
    GetPage(name: RouteNames.splash, page: () => const SplashView()),
    GetPage(
      name: RouteNames.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: RouteNames.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: RouteNames.ride,
      page: () => const RideView(),
      binding: RideBinding(),
    ),
    GetPage(
      name: RouteNames.rideHistory,
      page: () => const RideHistoryScreen(),
    ),
    GetPage(
      name: RouteNames.rideDetails,
      page: () => const RideDetailsScreen(),
    ),
  ];
}

