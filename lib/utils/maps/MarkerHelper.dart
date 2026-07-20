import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerHelper {
  static BitmapDescriptor? _carIcon;
  static BitmapDescriptor? _pickupIcon;
  static BitmapDescriptor? _dropIcon;

  static Future<void> preloadIcons() async {
    await Future.wait([
      getCarIcon(),
      getPickupIcon(),
      getDropIcon(),
    ]);
  }

  static Future<BitmapDescriptor> getCarIcon() async {
    if (_carIcon != null) {
      return _carIcon!;
    }
    try {
      _carIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(40, 80)),
        'assets/images/icons/car.png',
      );
    } catch (e) {
      print("MarkerHelper: Error loading car icon from assets: $e");
      _carIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    }
    return _carIcon!;
  }

  static Future<BitmapDescriptor> getPickupIcon() async {
    if (_pickupIcon != null) {
      return _pickupIcon!;
    }
    try {
      _pickupIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(40, 40)),
        'assets/images/icons/pickup.png',
      );
    } catch (e) {
      print("MarkerHelper: Error loading pickup icon from assets: $e");
      _pickupIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
    return _pickupIcon!;
  }

  static Future<BitmapDescriptor> getDropIcon() async {
    if (_dropIcon != null) {
      return _dropIcon!;
    }
    try {
      _dropIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(40, 40)),
        'assets/images/icons/drop.png',
      );
    } catch (e) {
      print("MarkerHelper: Error loading drop icon from assets: $e");
      _dropIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
    return _dropIcon!;
  }
}
