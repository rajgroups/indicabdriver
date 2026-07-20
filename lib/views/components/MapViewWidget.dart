import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapViewWidget extends StatelessWidget {
  final LatLng? pickupLocation;
  final LatLng? dropLocation;
  final Function(LatLng)? onMapTap;
  final Function(GoogleMapController)? onMapCreated;
  final Function(CameraPosition)? onCameraMove;
  final VoidCallback? onCameraIdle;
  final Set<Marker>? markers;
  final Set<Polyline>? polylines;
  final Set<Circle>? circles;
  final double? zoom;
  final MapType? mapType;
  final bool? compassEnabled; 
  final bool? myLocationButtonEnabled;
  
  const MapViewWidget({
    super.key,
    this.pickupLocation,
    this.dropLocation,
    this.onMapTap,
    this.onMapCreated,
    this.onCameraMove,
    this.onCameraIdle,
    this.markers,
    this.polylines,
    this.circles,
    this.zoom,
    this.mapType, 
    this.compassEnabled, 
    this.myLocationButtonEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 1,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: pickupLocation ?? dropLocation ?? const LatLng(12.9715987, 77.5945627), // Default to Bangalore center if null
          zoom: zoom ?? 13,
        ),
        onMapCreated: onMapCreated,
        onCameraMove: onCameraMove,
        onCameraIdle: onCameraIdle,
        onTap: onMapTap,
        markers: markers ?? {},
        polylines: polylines ?? {},
        circles: circles ?? {},
        mapType: mapType ?? MapType.normal,
        compassEnabled: compassEnabled ?? true,
        myLocationButtonEnabled: myLocationButtonEnabled ?? false, // My location button custom positioning might be needed or enabled/disabled
        zoomControlsEnabled: false, // Zoom controls disabled as per requirements
        myLocationEnabled: true, // Enable blue dot
      ),
    );
  }
}
