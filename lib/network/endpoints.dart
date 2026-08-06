class ApiEndpoints {
  static const login = '/login';
  static const sendOtp = '/send-otp';
  static const verifyOtp = '/verify-otp';
  static const socialLogin = '/social-login';
  static const vehicletype = '/vehicle-types';
  static const vehicletypelist = '/vehicles';
  static const bookings = '/bookings';
  static const activeRide = '/bookings/check/active';
  static String bookingDetails(String id) => '/bookings/$id';
  static String acceptBooking(int bookingId) => '/bookings/$bookingId/accept';
  static String arrivedBooking(int bookingId) => '/bookings/$bookingId/arrived';
  static String startBooking(int bookingId) => '/bookings/$bookingId/start';
  static String completeBooking(int bookingId) => '/bookings/$bookingId/complete';
  static const dashboard = '/dashboard';
  static const onlineStatus = '/profile/online-status';
  static String bookingFare(dynamic id) => '/bookings/$id/fare';
  static const updateFcmToken = '/fcm-token';
  static const walletRechargeRequest = '/wallet/recharge-request';
}


