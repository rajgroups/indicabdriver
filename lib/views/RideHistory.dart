import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/constants/Colors.dart';
import 'package:indicab_driver/models/booking_response.dart';
import 'package:indicab_driver/routes/names.dart';
import 'package:indicab_driver/layout/app.dart';

import 'package:indicab_driver/controllers/HistoryController.dart';
import 'RideHistoryFilter.dart';


class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  late final HistoryController _controller;
  final ScrollController _scrollController = ScrollController();

  static const List<String> _dateFilters = [
    'All',
    'Today',
    'This Week',
    'This Month',
  ];

  static const List<String> _statusTabs = [
    'All',
    'Ongoing',
    'Completed',
    'Cancelled',
    'Missed',
  ];

  @override
  void initState() {
    super.initState();
    _controller = Get.put(HistoryController());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _controller.loadMore();
    }
  }

  Future<void> _openFilters() async {
    final result = await Get.to<RideHistoryFilterResult>(
      () => RideHistoryFilterScreen(
        dateFilters: _dateFilters,
        typeFilters: const ['All', 'Cab', 'Auto', 'Bike', 'Parcel'],
        paymentFilters: const ['All', 'cash', 'upi', 'card', 'wallet'],
        initialDateFilter: _controller.selectedDateFilter.value,
        initialTypeFilter: _controller.selectedTypeFilter.value,
        initialPaymentFilter: _controller.selectedPaymentFilter.value,
        statusFilters: _statusTabs,
        initialStatusFilter: _controller.selectedStatusTab.value,
        initialPriceRange: _controller.selectedPriceRange.value,
        initialSortBy: _controller.selectedSortBy.value,
      ),
      fullscreenDialog: true,
    );

    if (result == null) return;

    _controller.selectedDateFilter.value = result.dateFilter;
    _controller.selectedTypeFilter.value = result.typeFilter;
    _controller.selectedPaymentFilter.value = result.paymentFilter;
    _controller.selectedPriceRange.value = result.priceRange;
    _controller.selectedSortBy.value = result.sortBy;

    if (result.statusFilter != _controller.selectedStatusTab.value) {
      _controller.selectedStatusTab.value = result.statusFilter;
    }

    _controller.fetchHistory(refresh: true);
  }

  void _onBookingTap(BookingDataModel booking) {
    final status = booking.status?.trim().toLowerCase() ?? '';

    // 1. Ongoing Rides -> Navigate to ActiveRideScreen or FindingDriverScreen
    if (status == 'accepted' || status == 'arrived' || status == 'started') {
      Get.offAllNamed(
        RouteNames.activeRide,
        arguments: <String, dynamic>{
          'booking_no': booking.bookingNo,
          'booking_data': booking,
        },
      );
      return;
    }

    if (status == 'pending' || status == 'requested') {
      Get.offAllNamed(
        RouteNames.findingDriver,
        arguments: <String, dynamic>{
          'booking_no': booking.bookingNo,
          'booking_data': booking,
          'vehicle_type': booking.categoryName,
        },
      );
      return;
    }

    // 2. Completed / Cancelled / Missed -> Ride Details
    Get.toNamed(RouteNames.rideDetails, arguments: booking);
  }

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      backgroundColor: AppColors.authBackground,
      child: Column(
        children: [
          // Header
          Obx(() => _HistoryHeader(
                onBack: Get.back,
                onOpenFilters: _openFilters,
                activeFilterCount: _controller.activeFilterCount,
              )),

          // Status Filter Tabs (All, Ongoing, Completed, Cancelled, Missed)
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Obx(() => Row(
                    children: _statusTabs.map((tab) {
                      final selected = _controller.selectedStatusTab.value == tab;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            tab,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          selected: selected,
                          onSelected: (_) => _controller.changeStatusTab(tab),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.inputFill,
                          side: BorderSide(
                            color: selected
                                ? AppColors.primaryDark
                                : AppColors.borderSoft,
                          ),
                        ),
                      );
                    }).toList(),
                  )),
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSoft),

          // Main List View with Pull To Refresh
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _controller.fetchHistory(refresh: true),
              color: AppColors.primaryDark,
              child: Obx(() {
                if (_controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final bookingsList = _controller.bookings;

                return ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                  itemCount: bookingsList.isEmpty
                      ? 3
                      : bookingsList.length + 3 + (_controller.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _StatsCard(
                        totalRides: _controller.totalRides,
                        totalSpent: _controller.totalSpent,
                        averageRating: _controller.averageRating,
                      );
                    }

                    if (index == 1) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 12),
                        child: _FilterSummaryCard(
                          activeFilterCount: _controller.activeFilterCount,
                          selectedDateFilter: _controller.selectedDateFilter.value,
                          selectedTypeFilter: _controller.selectedTypeFilter.value,
                          selectedPaymentFilter: _controller.selectedPaymentFilter.value,
                          selectedStatusFilter: _controller.selectedStatusTab.value,
                          selectedPriceRange: _controller.selectedPriceRange.value,
                          selectedSortBy: _controller.selectedSortBy.value,
                          onReset: _controller.resetFilters,
                        ),
                      );
                    }

                    if (index == 2) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trips (${_controller.selectedStatusTab.value})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tap any trip to view active tracking or trip summary.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (bookingsList.isEmpty) {
                      return _EmptyFilterState(onReset: _controller.resetFilters);
                    }

                    final bookingIndex = index - 3;
                    if (bookingIndex < bookingsList.length) {
                      final booking = bookingsList[bookingIndex];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _RideBookingCard(
                          booking: booking,
                          onTap: () => _onBookingTap(booking),
                        ),
                      );
                    }

                    // Loading indicator for pagination
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({
    required this.onBack,
    required this.onOpenFilters,
    required this.activeFilterCount,
  });

  final VoidCallback onBack;
  final VoidCallback onOpenFilters;
  final int activeFilterCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderSoft)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.inputFill,
              foregroundColor: AppColors.textPrimary,
            ),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ride History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Your ongoing & past trips',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: onOpenFilters,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.inputFill,
                  foregroundColor: AppColors.textPrimary,
                ),
                icon: const Icon(Icons.tune_rounded),
              ),
              if (activeFilterCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDark,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$activeFilterCount',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterSummaryCard extends StatelessWidget {
  const _FilterSummaryCard({
    required this.activeFilterCount,
    required this.selectedDateFilter,
    required this.selectedTypeFilter,
    required this.selectedPaymentFilter,
    required this.selectedStatusFilter,
    required this.selectedPriceRange,
    required this.selectedSortBy,
    required this.onReset,
  });

  final int activeFilterCount;
  final String selectedDateFilter;
  final String selectedTypeFilter;
  final String selectedPaymentFilter;
  final String selectedStatusFilter;
  final RangeValues selectedPriceRange;
  final String selectedSortBy;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Applied filters',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (activeFilterCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$activeFilterCount active',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AppliedFilterChip(label: 'Status', value: selectedStatusFilter, icon: Icons.data_usage_rounded),
              if (selectedSortBy != 'Date: Newest')
                _AppliedFilterChip(label: 'Sort', value: selectedSortBy, icon: Icons.sort_rounded),
              if (selectedDateFilter != 'All')
                _AppliedFilterChip(label: 'Date', value: selectedDateFilter, icon: Icons.calendar_month_rounded),
              if (selectedPaymentFilter != 'All')
                _AppliedFilterChip(label: 'Payment', value: selectedPaymentFilter, icon: Icons.account_balance_wallet_rounded),
            ],
          ),
          if (activeFilterCount > 0) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.restart_alt_rounded, size: 16),
                label: const Text('Clear filters'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AppliedFilterChip extends StatelessWidget {
  const _AppliedFilterChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFilterState extends StatelessWidget {
  const _EmptyFilterState({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.filter_alt_off_rounded,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No trips found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try selecting another filter or create a new booking.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          TextButton(onPressed: onReset, child: const Text('Reset filters')),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.totalRides,
    required this.totalSpent,
    required this.averageRating,
  });

  final int totalRides;
  final double totalSpent;
  final double averageRating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7D6), Color(0xFFFBE9A4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(value: '$totalRides', label: 'Total rides'),
          ),
          Expanded(
            child: _StatItem(
              value: '₹${totalSpent.toStringAsFixed(0)}',
              label: 'Total spent',
            ),
          ),
          Expanded(
            child: _StatItem(
              value: '${averageRating.toStringAsFixed(1)}★',
              label: 'Avg rating',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _RideBookingCard extends StatelessWidget {
  const _RideBookingCard({
    required this.booking,
    required this.onTap,
  });

  final BookingDataModel booking;
  final VoidCallback onTap;

  Color get _statusColor {
    final status = booking.status?.trim().toLowerCase() ?? '';
    switch (status) {
      case 'accepted':
      case 'arrived':
      case 'started':
      case 'pending':
      case 'requested':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'expired':
      case 'no_driver_available':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }

  String get _statusLabel {
    final status = booking.status?.trim().toLowerCase() ?? '';
    switch (status) {
      case 'accepted':
        return 'Driver Accepted';
      case 'arrived':
        return 'Driver Arrived';
      case 'started':
        return 'Ride Started';
      case 'pending':
      case 'requested':
        return 'Finding Driver';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'expired':
      case 'no_driver_available':
        return 'Missed (No Driver)';
      default:
        return status;
    }
  }

  bool get _isOngoing {
    final status = booking.status?.trim().toLowerCase() ?? '';
    return ['accepted', 'arrived', 'started', 'pending', 'requested'].contains(status);
  }

  @override
  Widget build(BuildContext context) {
    final category = booking.categoryName ?? 'Ride';
    final amount = booking.estimatedAmount != null
        ? '₹${booking.estimatedAmount!.toStringAsFixed(0)}'
        : '₹0';
    final pickup = booking.pickupAddress ?? 'Pickup Location';
    final drop = booking.dropAddress ?? 'Drop Location';
    final bookingNo = booking.bookingNo ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isOngoing ? AppColors.primaryDark : AppColors.borderSoft,
              width: _isOngoing ? 1.5 : 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _isOngoing ? Icons.directions_car_filled_rounded : Icons.local_taxi_rounded,
                      color: _statusColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              amount,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _statusLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _statusColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '#$bookingNo',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isOngoing ? Icons.arrow_forward_ios_rounded : Icons.chevron_right_rounded,
                    color: _isOngoing ? AppColors.primaryDark : AppColors.textMuted,
                    size: _isOngoing ? 16 : 24,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2A9D8F),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(width: 2, height: 34, color: AppColors.border),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE76F51),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pickup,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          drop,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_isOngoing) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Tap to view live tracking →',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
