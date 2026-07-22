import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/constants/Colors.dart';


class RideHistoryFilterResult {
  const RideHistoryFilterResult({
    required this.dateFilter,
    required this.typeFilter,
    required this.paymentFilter,
    required this.statusFilter,
    required this.priceRange,
    required this.sortBy,
  });

  final String dateFilter;
  final String typeFilter;
  final String paymentFilter;
  final String statusFilter;
  final RangeValues priceRange;
  final String sortBy;
}

class RideHistoryFilterScreen extends StatefulWidget {
  const RideHistoryFilterScreen({
    super.key,
    required this.dateFilters,
    required this.typeFilters,
    required this.paymentFilters,
    required this.statusFilters,
    required this.initialDateFilter,
    required this.initialTypeFilter,
    required this.initialPaymentFilter,
    required this.initialStatusFilter,
    required this.initialPriceRange,
    required this.initialSortBy,
  });

  final List<String> dateFilters;
  final List<String> typeFilters;
  final List<String> paymentFilters;
  final List<String> statusFilters;
  final String initialDateFilter;
  final String initialTypeFilter;
  final String initialPaymentFilter;
  final String initialStatusFilter;
  final RangeValues initialPriceRange;
  final String initialSortBy;

  @override
  State<RideHistoryFilterScreen> createState() =>
      _RideHistoryFilterScreenState();
}

class _RideHistoryFilterScreenState extends State<RideHistoryFilterScreen> {
  late String _selectedDateFilter;
  late String _selectedTypeFilter;
  late String _selectedPaymentFilter;
  late String _selectedStatusFilter;
  late RangeValues _selectedPriceRange;
  late String _selectedSortBy;

  @override
  void initState() {
    super.initState();
    _selectedDateFilter = widget.initialDateFilter;
    _selectedTypeFilter = widget.initialTypeFilter;
    _selectedPaymentFilter = widget.initialPaymentFilter;
    _selectedStatusFilter = widget.initialStatusFilter;
    _selectedPriceRange = widget.initialPriceRange;
    _selectedSortBy = widget.initialSortBy;
  }

  void _clearAll() {
    setState(() {
      _selectedDateFilter = 'All';
      _selectedTypeFilter = 'All';
      _selectedPaymentFilter = 'All';
      _selectedStatusFilter = 'All';
      _selectedPriceRange = const RangeValues(0, 2000);
      _selectedSortBy = 'Date: Newest';
    });
  }

  void _applyFilters() {
    Get.back(
      result: RideHistoryFilterResult(
        dateFilter: _selectedDateFilter,
        typeFilter: _selectedTypeFilter,
        paymentFilter: _selectedPaymentFilter,
        statusFilter: _selectedStatusFilter,
        priceRange: _selectedPriceRange,
        sortBy: _selectedSortBy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: Get.back,
        ),
        centerTitle: true,
        title: const Text(
          'Filters',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _clearAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
            ),
            child: const Text(
              'Reset',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              physics: const BouncingScrollPhysics(),
              children: [
                _FilterGroup(
                  title: 'Vehicle Type',
                  icon: Icons.directions_car_rounded,
                  options: widget.typeFilters,
                  selectedValue: _selectedTypeFilter,
                  onSelected: (value) =>
                      setState(() => _selectedTypeFilter = value),
                ),
                const SizedBox(height: 32),
                _FilterGroup(
                  title: 'Status',
                  icon: Icons.data_usage_rounded,
                  options: widget.statusFilters,
                  selectedValue: _selectedStatusFilter,
                  onSelected: (value) =>
                      setState(() => _selectedStatusFilter = value),
                ),
                const SizedBox(height: 32),
                _PriceRangeSection(
                  range: _selectedPriceRange,
                  onChanged: (value) =>
                      setState(() => _selectedPriceRange = value),
                ),
                const SizedBox(height: 32),
                _FilterGroup(
                  title: 'Sort By',
                  icon: Icons.sort_rounded,
                  options: const [
                    'Date: Newest',
                    'Date: Oldest',
                    'Price: High to Low',
                    'Price: Low to High'
                  ],
                  selectedValue: _selectedSortBy,
                  onSelected: (value) =>
                      setState(() => _selectedSortBy = value),
                ),
                const SizedBox(height: 32),
                _FilterGroup(
                  title: 'Date Range',
                  icon: Icons.calendar_month_rounded,
                  options: widget.dateFilters,
                  selectedValue: _selectedDateFilter,
                  onSelected: (value) =>
                      setState(() => _selectedDateFilter = value),
                ),
                const SizedBox(height: 32),
                _FilterGroup(
                  title: 'Payment Method',
                  icon: Icons.account_balance_wallet_rounded,
                  options: widget.paymentFilters,
                  selectedValue: _selectedPaymentFilter,
                  onSelected: (value) =>
                      setState(() => _selectedPaymentFilter = value),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: AppColors.surface,
                  minimumSize: const Size(double.infinity, 56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Show Results',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterGroup extends StatelessWidget {
  const _FilterGroup({
    required this.title,
    required this.icon,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  final String title;
  final IconData icon;
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textPrimary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            return InkWell(
              onTap: () => onSelected(option),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.textPrimary : AppColors.inputFill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.borderSoft,
                    width: 1,
                  ),
                ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          const Icon(Icons.check_circle_rounded,
                              size: 16, color: AppColors.surface),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          option,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w600,
                            color:
                                isSelected ? AppColors.surface : AppColors.textPrimary,
                          ),
                        ),
                      ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PriceRangeSection extends StatelessWidget {
  const _PriceRangeSection({required this.range, required this.onChanged});

  final RangeValues range;
  final ValueChanged<RangeValues> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.payments_rounded,
                size: 20, color: AppColors.textPrimary),
            const SizedBox(width: 8),
            const Text(
              'Price Range',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '₹${range.start.toInt()} - ₹${range.end.toInt()}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.textPrimary,
            inactiveTrackColor: AppColors.borderSoft,
            thumbColor: AppColors.textPrimary,
            overlayColor: AppColors.textPrimary.withValues(alpha: 0.1),
            valueIndicatorTextStyle:
                const TextStyle(color: AppColors.surface),
          ),
          child: RangeSlider(
            values: range,
            min: 0,
            max: 2000,
            divisions: 40,
            labels: RangeLabels(
                '₹${range.start.toInt()}', '₹${range.end.toInt()}'),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}