class BookingResponseModel {
  BookingResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final bool status;
  final String message;
  final BookingDataModel? data;

  factory BookingResponseModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'];
    final data = json['data'];

    return BookingResponseModel(
      status: rawStatus is bool ? rawStatus : rawStatus.toString() == 'true',
      message: json['message']?.toString() ?? '',
      data: data is Map<String, dynamic>
          ? BookingDataModel.fromJson(data)
          : null,
    );
  }
}

class BookingDataModel {
  BookingDataModel({
    required this.id,
    required this.bookingNo,
    required this.status,
    required this.bookingMode,
    required this.vehicleCategoryId,
    this.driverId,
    this.vehicleId,
    this.scheduledAt,
    this.pickupAddress,
    this.dropAddress,
    this.startOtp,
    this.estimatedAmount,
    this.driverName,
    this.vehicleNumber,
    this.vehicleName,
  });

  final int? id;
  final String? bookingNo;
  final String? status;
  final String? bookingMode;
  final int? driverId;
  final int? vehicleId;
  final int? vehicleCategoryId;
  final String? scheduledAt;
  final String? pickupAddress;
  final String? dropAddress;
  final String? startOtp;
  final double? estimatedAmount;
  final String? driverName;
  final String? vehicleNumber;
  final String? vehicleName;

  factory BookingDataModel.fromJson(Map<String, dynamic> json) {
    return BookingDataModel(
      id: json['id'] as int?,
      bookingNo: json['booking_no']?.toString(),
      status: json['status']?.toString(),
      bookingMode:
          json['booking_mode']?.toString() ?? json['service_mode']?.toString(),
      driverId: json['driver_id'] as int?,
      vehicleId: json['vehicle_id'] as int?,
      vehicleCategoryId: json['vehicle_category_id'] as int?,
      scheduledAt: json['scheduled_at']?.toString(),
      pickupAddress: json['pickup_address']?.toString(),
      dropAddress: json['drop_address']?.toString(),
      startOtp: json['start_otp']?.toString(),
      estimatedAmount: json['estimated_amount'] != null
          ? double.tryParse(json['estimated_amount'].toString())
          : null,
      driverName: json['driver'] is Map<String, dynamic>
          ? (json['driver']['name']?.toString())
          : null,
      vehicleNumber: json['vehicle'] is Map<String, dynamic>
          ? (json['vehicle']['vehicle_number']?.toString())
          : null,
      vehicleName: json['vehicle'] is Map<String, dynamic>
          ? _joinParts([
              json['vehicle']['brand']?.toString(),
              json['vehicle']['model']?.toString(),
            ])
          : null,
    );
  }

  static String? _joinParts(List<String?> parts) {
    final values = parts
        .where((part) => part != null && part!.trim().isNotEmpty)
        .map((part) => part!.trim())
        .toList();

    if (values.isEmpty) {
      return null;
    }

    return values.join(' ');
  }
}
