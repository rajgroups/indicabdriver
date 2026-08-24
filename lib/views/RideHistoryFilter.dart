import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ─── Rapido-style palette ────────────────────────────────────────────────────
const _kNavy   = Color(0xFF1A1A2E);
const _kGreen  = Color(0xFF00C853);
const _kBg     = Color(0xFFF5F6FA);
const _kBorder = Color(0xFFEEEFF3);
const _kMuted  = Color(0xFFB0B3C1);

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
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // ── Rapido-style top bar ──────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Material(
                  color: const Color(0xFFF3F4F6),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: Get.back,
                    customBorder: const CircleBorder(),
                    child: const SizedBox(
                      width: 42,
                      height: 42,
                      child: Center(
                        child: Icon(Icons.close_rounded,
                            size: 20, color: _kNavy),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter Trips',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _kNavy,
                        ),
                      ),
                      Text(
                        'Refine your ride history list',
                        style: TextStyle(
                          fontSize: 11,
                          color: _kMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _clearAll,
                  child: const Text(
                    'Clear All',
                    style: TextStyle(
                      color: _kGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Filter Body ───────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    title: 'Sort By',
                    child: _buildChips(
                      items: const ['Date: Newest', 'Date: Oldest', 'Price: High to Low', 'Price: Low to High'],
                      selectedItem: _selectedSortBy,
                      onSelected: (val) => setState(() => _selectedSortBy = val),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildSection(
                    title: 'Status',
                    child: _buildChips(
                      items: widget.statusFilters,
                      selectedItem: _selectedStatusFilter,
                      onSelected: (val) => setState(() => _selectedStatusFilter = val),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildSection(
                    title: 'Time Period',
                    child: _buildChips(
                      items: widget.dateFilters,
                      selectedItem: _selectedDateFilter,
                      onSelected: (val) => setState(() => _selectedDateFilter = val),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildSection(
                    title: 'Vehicle Type',
                    child: _buildChips(
                      items: widget.typeFilters,
                      selectedItem: _selectedTypeFilter,
                      onSelected: (val) => setState(() => _selectedTypeFilter = val),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildSection(
                    title: 'Payment Mode',
                    child: _buildChips(
                      items: widget.paymentFilters,
                      selectedItem: _selectedPaymentFilter,
                      onSelected: (val) => setState(() => _selectedPaymentFilter = val),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildSection(
                    title: 'Price Range',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _kBorder),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹${_selectedPriceRange.start.round()}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, color: _kNavy),
                              ),
                              Text(
                                '₹${_selectedPriceRange.end.round()}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, color: _kNavy),
                              ),
                            ],
                          ),
                          RangeSlider(
                            values: _selectedPriceRange,
                            min: 0,
                            max: 2000,
                            divisions: 20,
                            activeColor: _kGreen,
                            inactiveColor: _kBorder,
                            labels: RangeLabels(
                              '₹${_selectedPriceRange.start.round()}',
                              '₹${_selectedPriceRange.end.round()}',
                            ),
                            onChanged: (values) {
                              setState(() {
                                _selectedPriceRange = values;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _applyFilters,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kNavy,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Apply Filters',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _kNavy,
            ),
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildChips({
    required List<String> items,
    required String selectedItem,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selectedItem == item;
        return ChoiceChip(
          label: Text(item),
          selected: isSelected,
          onSelected: (_) => onSelected(item),
          selectedColor: _kNavy,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : _kNavy,
          ),
          side: BorderSide(
            color: isSelected ? _kNavy : _kBorder,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }).toList(),
    );
  }
}