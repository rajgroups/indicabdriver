class DriverModel {
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? dob;
  final String? gender;
  final String? aadhaarNumber;
  final String? panNumber;
  final String? licenseNumber;
  final String? licenseExpiry;
  final String? licenseCategories;
  final String? driverType;
  final String? status;
  final bool? isVerified;
  final String? profilePhoto;
  final String? licenseFront;
  final String? licenseBack;
  final String? aadhaarFront;
  final String? aadhaarBack;
  final String? panCardFile;
  final String? policeVerificationFile;
  final String? medicalCertificate;
  final String? remarks;

  DriverModel({
    this.name,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.dob,
    this.gender,
    this.aadhaarNumber,
    this.panNumber,
    this.licenseNumber,
    this.licenseExpiry,
    this.licenseCategories,
    this.driverType,
    this.status,
    this.isVerified,
    this.profilePhoto,
    this.licenseFront,
    this.licenseBack,
    this.aadhaarFront,
    this.aadhaarBack,
    this.panCardFile,
    this.policeVerificationFile,
    this.medicalCertificate,
    this.remarks,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      dob: json['dob'],
      gender: json['gender'],
      aadhaarNumber: json['aadhaar_number'],
      panNumber: json['pan_number'],
      licenseNumber: json['license_number'],
      licenseExpiry: json['license_expiry'],
      licenseCategories: json['license_categories'],
      driverType: json['driver_type'],
      status: json['status'],
      isVerified: json['is_verified'],
      profilePhoto: json['profile_photo'],
      licenseFront: json['license_front'],
      licenseBack: json['license_back'],
      aadhaarFront: json['aadhaar_front'],
      aadhaarBack: json['aadhaar_back'],
      panCardFile: json['pan_card_file'],
      policeVerificationFile: json['police_verification_file'],
      medicalCertificate: json['medical_certificate'],
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return{
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'dob': dob,
      'gender': gender,
      'aadhaar_number': aadhaarNumber,
      'pan_number': panNumber,
      'license_number': licenseNumber,
      'license_expiry': licenseExpiry,
      'license_categories': licenseCategories,
      'driver_type': driverType,
      'status': status,
      'is_verified': isVerified,
      'profile_photo': profilePhoto,
      'license_front': licenseFront,
      'license_back': licenseBack,
      'aadhaar_front': aadhaarFront,
      'aadhaar_back': aadhaarBack,
      'pan_card_file': panCardFile,
      'police_verification_file': policeVerificationFile,
      'medical_certificate': medicalCertificate,
      'remarks': remarks,
    };
  }
}
