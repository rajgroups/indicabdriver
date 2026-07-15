
import 'package:indicab_driver/models/Driver.dart';

class VehicleModel {
  final int? id;
  final int? driverId;
  final DriverModel? driver;
  final int? vehicleCategoryId;
  final String? vehicleCategory;
  final String? type;
  final double? distance;

  final String? brand;
  final String? model;
  final String? vehicleNumber;
  final VehicleLocations? vehicleLocations;
  final String? color;

  final int? manufactureYear;

  final String? rcNumber;
  final String? rcExpiry;

  final String? insuranceNumber;
  final String? insuranceExpiry;

  final String? permitNumber;
  final String? permitExpiry;

  final String? fitnessCertificateNumber;
  final String? fitnessExpiry;

  final int? seatingCapacity;
  final double? loadCapacity;

  final String? frontImage;
  final String? backImage;
  final String? sideImage;

  final String? status;
  final bool? isVerified;

  VehicleModel({
    this.id,
    this.driverId,
    this.vehicleCategoryId,
    this.vehicleCategory,
    this.type,
    this.distance,
    this.brand,
    this.model,
    this.vehicleNumber,
    this.color,
    this.manufactureYear,
    this.rcNumber,
    this.rcExpiry,
    this.insuranceNumber,
    this.insuranceExpiry,
    this.permitNumber,
    this.permitExpiry,
    this.fitnessCertificateNumber,
    this.fitnessExpiry,
    this.seatingCapacity,
    this.loadCapacity,
    this.frontImage,
    this.backImage,
    this.sideImage,
    this.status,
    this.isVerified, 
    this.driver, 
    this.vehicleLocations,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as Map<String, dynamic>?;
    final locationJson =
        (json['vehicle_locations'] ?? json['location']) as Map<String, dynamic>?;

    return VehicleModel(
      id: json['id'],
      driverId: json['driver_id'],
      vehicleCategoryId: json['vehicle_category_id'],
      vehicleCategory: json['vehicle_category'],
      type: json['type'],
      distance: json['distance'] != null
          ? double.tryParse(json['distance'].toString())
          : null,
      brand: json['brand'],
      model: json['model'],
      vehicleNumber: json['vehicle_number'],
      color: json['color'],
      manufactureYear: json['manufacture_year'],
      rcNumber: json['rc_number'],
      rcExpiry: json['rc_expiry'],
      insuranceNumber: json['insurance_number'],
      insuranceExpiry: json['insurance_expiry'],
      permitNumber: json['permit_number'],
      permitExpiry: json['permit_expiry'],
      fitnessCertificateNumber: json['fitness_certificate_number'],
      fitnessExpiry: json['fitness_expiry'],
      seatingCapacity: json['seating_capacity'],
      loadCapacity: json['load_capacity'] != null
          ? double.tryParse(json['load_capacity'].toString())
          : null,
      frontImage: json['front_image'] ?? images?['front'],
      backImage: json['back_image'] ?? images?['back'],
      sideImage: json['side_image'] ?? images?['side'],
      status: json['status'],
      isVerified: json['is_verified'],
      driver: json['driver'] != null ? DriverModel.fromJson(json['driver']) : null,
      vehicleLocations: locationJson != null
          ? VehicleLocations.fromJson(locationJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'vehicle_category_id': vehicleCategoryId,
      'vehicle_category': vehicleCategory,
      'type': type,
      'distance': distance,
      'brand': brand,
      'model': model,
      'vehicle_number': vehicleNumber, 
      'color': color,
      'manufacture_year': manufactureYear,
      'rc_number': rcNumber,
      'rc_expiry': rcExpiry,
      'insurance_number': insuranceNumber,
      'insurance_expiry': insuranceExpiry,
      'permit_number': permitNumber,
      'permit_expiry': permitExpiry,
      'fitness_certificate_number': fitnessCertificateNumber,
      'fitness_expiry': fitnessExpiry,
      'seating_capacity': seatingCapacity,
      'load_capacity': loadCapacity,
      'front_image': frontImage,
      'back_image': backImage,
      'side_image': sideImage,
      'status': status,
      'is_verified': isVerified,
    };
  }
}


class VehicleLocations{
  final double? latitude;
  final double? longitude;
  final double? speed;
  final double? heading;
  final double? accuracy;
  final bool? isOnline;
  final String? updatedAt;

  VehicleLocations({
    this.latitude,
    this.longitude,
    this.speed,
    this.heading,
    this.accuracy,
    this.isOnline,
    this.updatedAt,
  });

  factory VehicleLocations.fromJson(Map<String, dynamic> json) {
    return VehicleLocations(
      latitude: double.tryParse(json['latitude'].toString()),
      longitude: double.tryParse(json['longitude'].toString()),
      speed: double.tryParse(json['speed'].toString()),
      heading: double.tryParse(json['heading'].toString()),
      accuracy: double.tryParse(json['accuracy'].toString()),
      isOnline: json['is_online'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'heading': heading,
      'accuracy': accuracy,
      'is_online': isOnline,
      'updated_at': updatedAt,  
    };
  }
}
