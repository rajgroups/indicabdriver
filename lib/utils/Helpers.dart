import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:quickalert/quickalert.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/routes/names.dart';

class Helpers {

  static void success(String message,String? route,) {
    QuickAlert.show(
      context: Get.context!,
      type: QuickAlertType.success,
      text: message,
      onConfirmBtnTap: () async {

        /// CLOSE ALERT
        Get.back();

        /// WAIT SMALL DELAY
        await Future.delayed(
          const Duration(milliseconds: 200),
        );

        /// NAVIGATE
        if (route != null) {
          Get.offAllNamed(route);
        }
      },
    );
  }

  static bool _isSessionExpiredAlertShowing = false;

  static void error(String message) {
    if (message.contains("Unauthenticated") || message.contains("Session expired")) {
      if (_isSessionExpiredAlertShowing || Get.currentRoute == RouteNames.login) {
        return;
      }
      _isSessionExpiredAlertShowing = true;
      QuickAlert.show(
        context: Get.context!,
        type: QuickAlertType.error,
        text: "Session expired. Please log in again.",
        onConfirmBtnTap: () {
          _isSessionExpiredAlertShowing = false;
          Get.back();
        },
      );
      return;
    }

    QuickAlert.show(
      context: Get.context!,
      type: QuickAlertType.error,
      text: message,
    );
  }

  static void loading() {
    QuickAlert.show(
      context: Get.context!,
      type: QuickAlertType.loading,
      text: "Please wait...",
      barrierDismissible: false,
    );
  }

  static void close() {
    Get.back();
  }
}
