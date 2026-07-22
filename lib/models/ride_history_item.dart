import 'booking_response.dart';

class RideHistoryItem {
  final int? id;
  final String bookingId;
  final String dateLabel;
  final String type;
  final String vehicleNumber;
  final String pickup;
  final String drop;
  final String distance;
  final String duration;
  final double amountValue;
  final String amountLabel;
  final String paymentMethod;
  final String driverName;
  final String status;
  final BookingDataModel? rawBooking;

  RideHistoryItem({
    this.id,
    required this.bookingId,
    required this.dateLabel,
    required this.type,
    required this.vehicleNumber,
    required this.pickup,
    required this.drop,
    required this.distance,
    required this.duration,
    required this.amountValue,
    required this.amountLabel,
    required this.paymentMethod,
    required this.driverName,
    required this.status,
    this.rawBooking,
  });

  factory RideHistoryItem.fromBookingData(BookingDataModel booking) {
    final amt = booking.finalAmount != null && booking.finalAmount! > 0
        ? booking.finalAmount!
        : (booking.estimatedAmount ?? 0.0);

    return RideHistoryItem(
      id: booking.id,
      bookingId: booking.bookingNo ?? 'N/A',
      dateLabel: booking.scheduledAt ?? 'Recent',
      type: booking.categoryName ?? 'Ride',
      vehicleNumber: booking.vehicleNumber ?? 'N/A',
      pickup: booking.pickupAddress ?? 'Pickup Address',
      drop: booking.dropAddress ?? 'Drop Address',
      distance: 'N/A',
      duration: booking.durationHours != null ? '${booking.durationHours} hrs' : 'N/A',
      amountValue: amt,
      amountLabel: '₹${amt.toStringAsFixed(2)}',
      paymentMethod: booking.bookingMode ?? 'Cash / UPI',
      driverName: booking.driverName ?? 'Assigned Driver',
      status: booking.status ?? 'Completed',
      rawBooking: booking,
    );
  }

  factory RideHistoryItem.fromJson(Map<String, dynamic> json) {
    final amt = json['total_amount'] != null
        ? double.tryParse(json['total_amount'].toString()) ?? 0.0
        : (json['amount_value'] != null ? double.tryParse(json['amount_value'].toString()) ?? 0.0 : 0.0);

    return RideHistoryItem(
      id: json['id'] as int?,
      bookingId: json['booking_id']?.toString() ?? json['booking_no']?.toString() ?? 'N/A',
      dateLabel: json['date_label']?.toString() ?? json['created_at']?.toString() ?? 'Recent',
      type: json['type']?.toString() ?? json['category_name']?.toString() ?? 'Ride',
      vehicleNumber: json['vehicle_number']?.toString() ?? 'N/A',
      pickup: json['pickup']?.toString() ?? json['pickup_address']?.toString() ?? '',
      drop: json['drop']?.toString() ?? json['drop_address']?.toString() ?? '',
      distance: json['distance']?.toString() ?? 'N/A',
      duration: json['duration']?.toString() ?? 'N/A',
      amountValue: amt,
      amountLabel: '₹${amt.toStringAsFixed(2)}',
      paymentMethod: json['payment_method']?.toString() ?? 'Cash',
      driverName: json['driver_name']?.toString() ?? 'Driver',
      status: json['status']?.toString() ?? 'Completed',
    );
  }
}
