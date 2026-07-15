class ApiEndpoints {
  static const login = '/login';
  static const sendOtp = '/send-otp';
  static const verifyOtp = '/verify-otp';
  static const socialLogin = '/social-login';
  static const vehicletype = '/vehicle-types';
  static const vehicletypelist = '/vehicles';
  static const bookings = '/bookings';
  static String bookingDetails(String bookingNo) => '/bookings/$bookingNo';
}
