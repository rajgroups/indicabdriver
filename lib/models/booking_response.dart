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
      status: rawStatus is bool
          ? rawStatus
          : ['true', 'success'].contains(rawStatus?.toString()),
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
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropLatitude,
    this.dropLongitude,
    this.startOtp,
    this.estimatedAmount,
    this.finalAmount,
    this.driverName,
    this.vehicleNumber,
    this.vehicleName,
    this.passengerName,
    this.passengerPhone,
    this.categoryName,
    this.requiresDropLocation,
    this.durationHours,
    this.notes,
    this.paymentMethod,
    this.paymentStatus,
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
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropLatitude;
  final double? dropLongitude;
  final String? startOtp;
  final double? estimatedAmount;
  final double? finalAmount;
  final String? driverName;
  final String? vehicleNumber;
  final String? vehicleName;
  final String? passengerName;
  final String? passengerPhone;
  final String? categoryName;
  final bool? requiresDropLocation;
  final double? durationHours;
  final String? notes;
  final String? paymentMethod;
  final String? paymentStatus;

  /// Whether this booking has a valid drop location (Transport Mode).
  /// If false, this is a Work Mode booking (e.g., tractor, JCB, crane).
  bool get hasDropLocation =>
      dropLatitude != null && dropLongitude != null;

  /// Whether this is a work-based booking (no destination).
  bool get isWorkMode => !hasDropLocation;

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
      paymentMethod: json['payment_method']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      pickupLatitude: json['pickup_latitude'] != null
          ? double.tryParse(json['pickup_latitude'].toString())
          : _extractLocationCoord(json, 'pickup_location', 'latitude'),
      pickupLongitude: json['pickup_longitude'] != null
          ? double.tryParse(json['pickup_longitude'].toString())
          : _extractLocationCoord(json, 'pickup_location', 'longitude'),
      dropLatitude: json['drop_latitude'] != null
          ? double.tryParse(json['drop_latitude'].toString())
          : _extractLocationCoord(json, 'drop_location', 'latitude'),
      dropLongitude: json['drop_longitude'] != null
          ? double.tryParse(json['drop_longitude'].toString())
          : _extractLocationCoord(json, 'drop_location', 'longitude'),
      startOtp: json['start_otp']?.toString(),
      estimatedAmount: json['estimated_amount'] != null
          ? double.tryParse(json['estimated_amount'].toString())
          : null,
      finalAmount: json['final_amount'] != null
          ? double.tryParse(json['final_amount'].toString())
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
      passengerName: json['user'] is Map<String, dynamic>
          ? (json['user']['name']?.toString())
          : (json['passenger_name']?.toString()),
      passengerPhone: json['user'] is Map<String, dynamic>
          ? (json['user']['phone']?.toString())
          : (json['passenger_phone']?.toString()),
      categoryName: json['category_name']?.toString() ??
          (json['category'] is Map<String, dynamic>
              ? json['category']['name']?.toString()
              : null),
      requiresDropLocation: json['requires_drop_location'] as bool?,
      durationHours: json['duration_hours'] != null
          ? double.tryParse(json['duration_hours'].toString())
          : null,
      notes: json['notes']?.toString(),
    );
  }

  /// Extracts latitude or longitude from a nested location object.
  static double? _extractLocationCoord(
      Map<String, dynamic> json, String locationKey, String coordKey) {
    final location = json[locationKey];
    if (location is Map<String, dynamic>) {
      final value = location[coordKey];
      if (value != null) {
        return double.tryParse(value.toString());
      }
    }
    return null;
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
