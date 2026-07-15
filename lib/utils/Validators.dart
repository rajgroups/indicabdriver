class Validators {
  static bool isPhoneValid(String phone) => phone.length == 10;

  static String? validateMobile(String mobile) {
    if (mobile.isEmpty) {
      return "Mobile number is required";
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile)) {
      return "Enter valid 10-digit mobile number";
    }

    return null;
  }

  static String? validateOtp(String otp) {
    if (otp.isEmpty) {
      return "OTP is required";
    }

    if (!RegExp(r'^[0-9]{4}$').hasMatch(otp)) {
      return "Enter valid 4-digit OTP";
    }

    return null;
  }
}
