class BookingLocationRequest {
  BookingLocationRequest({
    required this.locationType,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.sequence,
  });

  final String locationType;
  final double latitude;
  final double longitude;
  final String? address;
  final int sequence;

  Map<String, dynamic> toJson() {
    return {
      'location_type': locationType,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'sequence': sequence,
    };
  }
}

class BookingUsageRequest {
  BookingUsageRequest({
    this.distanceKm,
    this.hoursUsed,
    this.acreUsed,
    this.weightTon,
  });

  final double? distanceKm;
  final double? hoursUsed;
  final double? acreUsed;
  final double? weightTon;

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{};

    if (distanceKm != null) {
      payload['distance_km'] = distanceKm;
    }
    if (hoursUsed != null) {
      payload['hours_used'] = hoursUsed;
    }
    if (acreUsed != null) {
      payload['acre_used'] = acreUsed;
    }
    if (weightTon != null) {
      payload['weight_ton'] = weightTon;
    }

    return payload;
  }
}

class BookingCreateRequest {
  BookingCreateRequest({
    required this.vehicleCategoryId,
    required this.bookingMode,
    required this.locations,
    required this.paymentMethod,
    this.driverId,
    this.vehicleId,
    this.scheduledAt,
    this.durationHours,
    this.usage,
  });

  final int vehicleCategoryId;
  final String bookingMode;
  final int? driverId;
  final int? vehicleId;
  final String paymentMethod;
  final String? scheduledAt;
  final double? durationHours;
  final List<BookingLocationRequest> locations;
  final BookingUsageRequest? usage;

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{
      'vehicle_category_id': vehicleCategoryId,
      'booking_mode': bookingMode,
      'payment_method': paymentMethod,
      'locations': locations.map((location) => location.toJson()).toList(),
    };

    if (driverId != null) {
      payload['driver_id'] = driverId;
    }
    if (vehicleId != null) {
      payload['vehicle_id'] = vehicleId;
    }
    if (scheduledAt != null) {
      payload['scheduled_at'] = scheduledAt;
    }
    if (durationHours != null) {
      payload['duration_hours'] = durationHours;
    }
    if (usage != null) {
      payload['usage'] = usage!.toJson();
    }

    return payload;
  }
}
