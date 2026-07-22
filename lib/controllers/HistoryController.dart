import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/models/booking_response.dart';
import 'package:indicab_driver/repositories/HistoryRepository.dart';

class HistoryController extends GetxController {
  final HistoryRepository _repository = HistoryRepository();

  final RxList<BookingDataModel> bookings = <BookingDataModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  int _currentPage = 1;

  // Filter States
  final RxString selectedDateFilter = 'All'.obs;
  final RxString selectedTypeFilter = 'All'.obs;
  final RxString selectedPaymentFilter = 'All'.obs;
  final RxString selectedStatusTab = 'All'.obs;
  final Rx<RangeValues> selectedPriceRange = const RangeValues(0, 2000).obs;
  final RxString selectedSortBy = 'Date: Newest'.obs;

  // Stats
  final RxInt totalRidesCount = 0.obs;
  final RxDouble totalEarningsAmount = 0.0.obs;
  final RxDouble averageRatingValue = 4.9.obs;

  int get totalRides => totalRidesCount.value;
  double get totalSpent => totalEarningsAmount.value;
  double get averageRating => averageRatingValue.value;

  int get activeFilterCount {
    int count = 0;
    if (selectedDateFilter.value != 'All') count++;
    if (selectedTypeFilter.value != 'All') count++;
    if (selectedPaymentFilter.value != 'All') count++;
    if (selectedStatusTab.value != 'All') count++;
    if (selectedPriceRange.value.start > 0 || selectedPriceRange.value.end < 2000) count++;
    if (selectedSortBy.value != 'Date: Newest') count++;
    return count;
  }

  @override
  void onInit() {
    super.onInit();
    fetchHistory(refresh: true);
  }

  Future<void> fetchHistory({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
      isLoading.value = true;
    } else {
      if (!hasMore.value || isLoadingMore.value) return;
      isLoadingMore.value = true;
    }

    try {
      final res = await _repository.fetchHistory(
        status: selectedStatusTab.value,
        dateFilter: selectedDateFilter.value,
        type: selectedTypeFilter.value,
        paymentMethod: selectedPaymentFilter.value,
        minPrice: selectedPriceRange.value.start,
        maxPrice: selectedPriceRange.value.end,
        sortBy: selectedSortBy.value,
        page: _currentPage,
      );

      final List<BookingDataModel> fetchedBookings = res['bookings'] as List<BookingDataModel>;

      if (refresh) {
        bookings.assignAll(fetchedBookings);
      } else {
        bookings.addAll(fetchedBookings);
      }

      hasMore.value = (res['has_more'] as bool? ?? false) && fetchedBookings.isNotEmpty;
      totalRidesCount.value = (res['total_rides'] as num? ?? bookings.length).toInt();
      totalEarningsAmount.value = (res['total_spent'] as num? ?? 0.0).toDouble();
      averageRatingValue.value = (res['average_rating'] as num? ?? 4.9).toDouble();
    } catch (e) {
      debugPrint('Error fetching history: $e');
    } finally {

      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void loadMore() {
    if (!isLoading.value && !isLoadingMore.value && hasMore.value) {
      _currentPage++;
      fetchHistory(refresh: false);
    }
  }

  void changeStatusTab(String tab) {
    if (selectedStatusTab.value != tab) {
      selectedStatusTab.value = tab;
      fetchHistory(refresh: true);
    }
  }

  void resetFilters() {
    selectedDateFilter.value = 'All';
    selectedTypeFilter.value = 'All';
    selectedPaymentFilter.value = 'All';
    selectedStatusTab.value = 'All';
    selectedPriceRange.value = const RangeValues(0, 2000);
    selectedSortBy.value = 'Date: Newest';
    fetchHistory(refresh: true);
  }
}
