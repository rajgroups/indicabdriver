import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/constants/Strings.dart';
import 'package:indicab_driver/controllers/HomeController.dart';
import 'package:indicab_driver/routes/names.dart';
import 'package:indicab_driver/models/booking_response.dart';
import 'package:indicab_driver/views/components/MapViewWidget.dart';
import 'package:indicab_driver/views/components/ModernTraditionalZeroWalletCard.dart';

// ─── Rapido-style palette ────────────────────────────────────────────────────
const _kNavy   = Color(0xFF1A1A2E);
const _kGreen  = Color(0xFF00C853);
const _kRed    = Color(0xFFE53935);
const _kBg     = Color(0xFFF5F6FA);
const _kBorder = Color(0xFFEEEFF3);
const _kMuted  = Color(0xFFB0B3C1);

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: _kNavy),
          );
        }

        return Stack(
          children: [
            // ── Main Content: Dashboard or Map ───────────────────────
            controller.showMapView.value
                ? _buildMapView(context)
                : _buildDashboardView(context),

            // ── Incoming Ride Overlay (always on top) ────────────────
            if (controller.showIncomingRequest.value &&
                controller.incomingRequest.value != null)
              _IncomingRideCard(
                booking: controller.incomingRequest.value!,
                countdown: controller.countdownSeconds.value,
                progress: controller.countdownProgress.value,
                onDecline: controller.declineRequest,
                onAccept: controller.acceptRequest,
                isAccepting: controller.isAccepting.value,
              ),
          ],
        );
      }),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // GPay-style Dashboard View (NO map loaded = zero API cost)
  // ════════════════════════════════════════════════════════════════════
  Widget _buildDashboardView(BuildContext context) {
    final driver = controller.currentDriver;
    final name = driver?.name?.trim().isNotEmpty == true
        ? driver!.name!.trim()
        : 'Driver';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'D';
    final vehicleInfo = driver?.vehicle != null
        ? '${driver!.vehicle!.registrationNumber ?? ''} • ${driver.vehicle!.typeName ?? 'Car'}'
        : null;

    return Stack(
      children: [
        // Scrollable content
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Top bar (navy) ──────────────────────────────────
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: _TopBar(
                  isOnline: controller.isOnline.value,
                  onSettings: () => _showProfileSheet(controller),
                ),
              ),
            ),

            // ── Greeting / Driver Hero Card ─────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _DriverGreetingCard(
                  name: name,
                  initial: initial,
                  isOnline: controller.isOnline.value,
                  vehicleInfo: vehicleInfo,
                  rating: controller.rating.value,
                ),
              ),
            ),

            // ── Status Toggle ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _StatusCard(
                  isOnline: controller.isOnline.value,
                  onToggle: controller.toggleOnline,
                ),
              ),
            ),

            // ── Wallet Warning ──────────────────────────────────
            if (controller.walletBalance.value <= 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: ModernTraditionalZeroWalletCard(
                    onRecharge: controller.showRechargeDialog,
                    balance: controller.walletBalance.value,
                  ),
                ),
              ),

            // ── Earnings ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _EarningsCard(
                  earnings: controller.todayEarnings.value,
                  trips: controller.todayTrips.value,
                  rating: controller.rating.value,
                ),
              ),
            ),

            // ── Quick Actions ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _QuickActions(
                  onSupport: () => Get.snackbar(
                    'Support',
                    'Contacting Indicab Support...',
                    backgroundColor: Colors.white,
                  ),
                  onHistory: () => Get.toNamed(RouteNames.rideHistory),
                  onEarnings: () => Get.toNamed(RouteNames.rideHistory),
                ),
              ),
            ),

            // ── Recent Trips ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _RecentTrips(
                  trips: controller.recentTrips,
                  onSeeAll: () => Get.toNamed(RouteNames.rideHistory),
                ),
              ),
            ),

            // Bottom padding for FAB clearance
            const SliverToBoxAdapter(
              child: SizedBox(height: 90),
            ),
          ],
        ),

        // ── Floating "View Map" Button ──────────────────────────
        Positioned(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          child: _ViewMapButton(
            onTap: () => controller.showMapView.value = true,
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // Map View (existing layout, only loaded on demand)
  // ════════════════════════════════════════════════════════════════════
  Widget _buildMapView(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final sheetTopOffset = mediaQuery.size.height * 0.4;

    return Stack(
      children: [
        const _DummyMap(),
        SafeArea(
          child: _TopBar(
            isOnline: controller.isOnline.value,
            onSettings: () => _showProfileSheet(controller),
          ),
        ),
        Positioned(
          top: mediaQuery.padding.top + 84,
          right: 16,
          child: _MapControlButton(
            icon: Icons.explore_rounded,
            onTap: () =>
                controller.focusCurrentLocation(resetBearing: true),
            isLoading: controller.isLocating.value,
            tooltip: 'Reset compass',
          ),
        ),
        Positioned(
          right: 16,
          bottom: sheetTopOffset + 16,
          child: _MapControlButton(
            icon: Icons.my_location_rounded,
            onTap: controller.focusCurrentLocation,
            isLoading: controller.isLocating.value,
            tooltip: 'Show current location',
          ),
        ),
        // ── Back to Dashboard button ────────────────────────────
        Positioned(
          top: mediaQuery.padding.top + 84,
          left: 16,
          child: _MapControlButton(
            icon: Icons.dashboard_rounded,
            onTap: () => controller.showMapView.value = false,
            tooltip: 'Back to Dashboard',
          ),
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          builder:
              (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDragHandle(),
                    const SizedBox(height: 12),
                    _StatusCard(
                      isOnline: controller.isOnline.value,
                      onToggle: controller.toggleOnline,
                    ),
                    const SizedBox(height: 16),
                    if (controller.walletBalance.value <= 0) ...[
                      ModernTraditionalZeroWalletCard(
                        onRecharge: controller.showRechargeDialog,
                        balance: controller.walletBalance.value,
                      ),
                      const SizedBox(height: 16),
                    ],
                    _EarningsCard(
                      earnings: controller.todayEarnings.value,
                      trips: controller.todayTrips.value,
                      rating: controller.rating.value,
                    ),
                    const SizedBox(height: 16),
                    _QuickActions(
                      onSupport: () => Get.snackbar(
                        'Support',
                        'Contacting Indicab Support...',
                        backgroundColor: Colors.white,
                      ),
                      onHistory: () =>
                          Get.toNamed(RouteNames.rideHistory),
                      onEarnings: () =>
                          Get.toNamed(RouteNames.rideHistory),
                    ),
                    const SizedBox(height: 16),
                    _RecentTrips(
                      trips: controller.recentTrips,
                      onSeeAll: () =>
                          Get.toNamed(RouteNames.rideHistory),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: _kBorder,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _DummyMap extends GetView<HomeController> {
  const _DummyMap();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return MapViewWidget(
        pickupLocation: controller.currentPosition.value,
        markers: controller.markers,
        onMapCreated: controller.onMapCreated,
        compassEnabled: false,
        myLocationButtonEnabled: false,
      );
    });
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.isOnline, required this.onSettings});

  final bool isOnline;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _kNavy,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _kNavy.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.asset(
                  'assets/images/icons/app_icon.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.local_taxi_rounded,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isOnline ? _kGreen : _kRed,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isOnline ? 'Online' : 'Offline',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Material(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: onSettings,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showProfileSheet(HomeController controller) {
  Get.bottomSheet(
    Obx(() {
      final driver = controller.currentDriver;
      final name = driver?.name?.trim().isNotEmpty == true
          ? driver!.name!.trim()
          : 'Driver';
      final phone = driver?.phone?.trim().isNotEmpty == true
          ? driver!.phone!.trim()
          : 'Not available';
      final email = driver?.email?.trim().isNotEmpty == true
          ? driver!.email!.trim()
          : 'Not available';
      final status = driver?.status?.trim().isNotEmpty == true
          ? driver!.status!.trim()
          : 'Active';
      final balance = controller.walletBalance.value;
      final initial = name.isNotEmpty ? name[0].toUpperCase() : 'D';
      final isOnline = controller.isOnline.value;

      return SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F8FC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag Handle ─────────────────────────────────────────
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 4),

              // ── Hero Header Card (Dark Gradient) ────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A1A2E).withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar with ring
                      Stack(
                        children: [
                          Container(
                            width: 66,
                            height: 66,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  _kGreen,
                                  _kGreen.withValues(alpha: 0.6),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _kGreen.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          // Online indicator dot
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: isOnline ? _kGreen : _kRed,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF16213E), width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.phone_rounded, size: 12, color: Colors.white.withValues(alpha: 0.55)),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    phone,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withValues(alpha: 0.65),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(Icons.email_rounded, size: 12, color: Colors.white.withValues(alpha: 0.55)),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    email,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withValues(alpha: 0.65),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            
                            // Vehicle details if available
                            if (driver?.vehicle != null) ...[
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(Icons.directions_car_rounded, size: 12, color: Colors.white.withValues(alpha: 0.55)),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      "${driver!.vehicle!.registrationNumber ?? 'N/A'} • ${driver.vehicle!.typeName ?? 'Car'}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withValues(alpha: 0.65),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Status badge
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? _kGreen.withValues(alpha: 0.2)
                                  : _kRed.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isOnline
                                    ? _kGreen.withValues(alpha: 0.5)
                                    : _kRed.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              isOnline ? 'Online' : 'Offline',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isOnline ? _kGreen : _kRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Stats Row ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.account_balance_wallet_rounded,
                        iconColor: const Color(0xFF00C853),
                        label: 'Wallet Balance',
                        value: '₹${balance.toStringAsFixed(2)}',
                        bgColor: const Color(0xFFEAFBF1),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.verified_rounded,
                        iconColor: const Color(0xFF6C63FF),
                        label: 'Account Status',
                        value: status.isNotEmpty ? status[0].toUpperCase() + status.substring(1) : 'Active',
                        bgColor: const Color(0xFFF0EEFF),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Menu Items ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEEEFF3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _SheetMenuItem(
                        icon: Icons.map_rounded,
                        iconColor: const Color(0xFF0288D1),
                        iconBg: const Color(0xFF0288D1).withValues(alpha: 0.08),
                        title: 'Live Map',
                        onTap: () {
                          Get.back(); // Close sheet
                          controller.showMapView.value = true;
                        },
                      ),
                      _SheetMenuDivider(),
                      _SheetMenuItem(
                        icon: Icons.privacy_tip_outlined,
                        iconColor: _kGreen,
                        iconBg: _kGreen.withValues(alpha: 0.08),
                        title: 'Privacy Policy',
                        onTap: () => Get.toNamed(
                          RouteNames.cmsPage,
                          arguments: {'slug': 'privacy-policy', 'title': 'Privacy Policy'},
                        ),
                      ),
                      _SheetMenuDivider(),
                      _SheetMenuItem(
                        icon: Icons.description_outlined,
                        iconColor: const Color(0xFF6C63FF),
                        iconBg: const Color(0xFF6C63FF).withValues(alpha: 0.08),
                        title: 'Terms & Conditions',
                        onTap: () => Get.toNamed(
                          RouteNames.cmsPage,
                          arguments: {'slug': 'terms-and-conditions', 'title': 'Terms & Conditions'},
                        ),
                      ),
                      _SheetMenuDivider(),
                      _SheetMenuItem(
                        icon: Icons.logout_rounded,
                        iconColor: _kRed,
                        iconBg: _kRed.withValues(alpha: 0.08),
                        title: 'Logout',
                        titleColor: _kRed,
                        onTap: controller.logout,
                        showArrow: false,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      );
    }),
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
  );
}


class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.bgColor,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.black.withValues(alpha: 0.45),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1A1A2E),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetMenuItem extends StatelessWidget {
  const _SheetMenuItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.onTap,
    this.titleColor = const Color(0xFF1A1A2E),
    this.showArrow = true,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final VoidCallback onTap;
  final Color titleColor;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
              ),
              if (showArrow)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.black.withValues(alpha: 0.25),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetMenuDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 70),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.black.withValues(alpha: 0.06),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// GPay-style Driver Greeting Card
// ═══════════════════════════════════════════════════════════════════════
class _DriverGreetingCard extends StatelessWidget {
  const _DriverGreetingCard({
    required this.name,
    required this.initial,
    required this.isOnline,
    required this.rating,
    this.vehicleInfo,
  });

  final String name;
  final String initial;
  final bool isOnline;
  final double rating;
  final String? vehicleInfo;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _kGreen,
                      _kGreen.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isOnline ? _kGreen : _kRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF16213E), width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                if (vehicleInfo != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.directions_car_rounded, size: 12, color: Colors.white.withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          vehicleInfo!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Rating badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Floating "View Map" Button
// ═══════════════════════════════════════════════════════════════════════
class _ViewMapButton extends StatelessWidget {
  const _ViewMapButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A1A2E).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_rounded, color: Colors.white, size: 22),
              SizedBox(width: 10),
              Text(
                'View Live Map',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.isLoading = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _kBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: _kNavy.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: _kNavy),
                    )
                  : Icon(icon, color: _kNavy, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.isOnline,
    required this.onToggle,
  });

  final bool isOnline;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isOnline ? _kGreen : _kNavy,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isOnline ? _kGreen : _kNavy).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOnline ? 'You\'re Online' : 'You\'re Offline',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOnline ? 'Accepting ride requests' : 'Tap to go online',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 60,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        left: isOnline ? 28 : 2,
                        top: 2,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isOnline ? _kGreen : _kNavy,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isOnline ? Icons.check : Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isOnline) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You will receive ride requests automatically',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  const _EarningsCard({
    required this.earnings,
    required this.trips,
    required this.rating,
  });

  final double earnings;
  final int trips;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today\'s Earnings',
                  style: TextStyle(
                    fontSize: 12,
                    color: _kMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${earnings.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _kNavy,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: _kBorder),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Trips',
                  style: TextStyle(
                    fontSize: 12,
                    color: _kMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$trips',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _kNavy,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: _kBorder),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Rating',
                  style: TextStyle(
                    fontSize: 12,
                    color: _kMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: _kNavy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onSupport,
    required this.onHistory,
    required this.onEarnings,
  });

  final VoidCallback onSupport;
  final VoidCallback onHistory;
  final VoidCallback onEarnings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _kNavy,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ActionButton(
                icon: Icons.support_agent_rounded,
                label: 'Support',
                onTap: onSupport,
              ),
              const SizedBox(width: 12),
              _ActionButton(
                icon: Icons.history_rounded,
                label: 'History',
                onTap: onHistory,
              ),
              const SizedBox(width: 12),
              _ActionButton(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Earnings',
                onTap: onEarnings,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _kBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kBorder),
          ),
          child: Column(
            children: [
              Icon(icon, color: _kNavy, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentTrips extends StatelessWidget {
  const _RecentTrips({required this.trips, required this.onSeeAll});

  final List<BookingDataModel> trips;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Trips',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _kGreen,
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _kGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (trips.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No recent trips yet',
                  style: TextStyle(
                    fontSize: 13,
                    color: _kMuted,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: trips.length,
              separatorBuilder: (context, index) => const Divider(height: 16, color: _kBorder),
              itemBuilder: (context, index) {
                final booking = trips[index];
                return _TripItem(
                  booking: booking,
                  onTap: () {
                    Get.toNamed(RouteNames.rideDetails, arguments: booking);
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _TripItem extends StatelessWidget {
  const _TripItem({required this.booking, required this.onTap});

  final BookingDataModel booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pickup = booking.pickupAddress ?? 'Pickup Address';
    final drop = booking.dropAddress ?? 'Drop Address';
    final amount = booking.finalAmount != null && booking.finalAmount! > 0
        ? '₹${booking.finalAmount!.toStringAsFixed(0)}'
        : (booking.estimatedAmount != null
              ? '₹${booking.estimatedAmount!.toStringAsFixed(0)}'
              : '₹0');
    final time = booking.scheduledAt ?? 'Recent';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.route_rounded,
              color: _kGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$pickup → $drop',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _kMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _kNavy,
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomingRideCard extends StatelessWidget {
  const _IncomingRideCard({
    required this.booking,
    required this.countdown,
    required this.progress,
    required this.onDecline,
    required this.onAccept,
    required this.isAccepting,
  });

  final BookingDataModel booking;
  final int countdown;
  final double progress;
  final VoidCallback onDecline;
  final VoidCallback onAccept;
  final bool isAccepting;

  @override
  Widget build(BuildContext context) {
    final bookingType = booking.bookingMode == 'instant'
        ? 'Instant Booking'
        : 'Scheduled Booking';
    final bookingNo = booking.bookingNo ?? 'N/A';
    final passengerName = booking.passengerName ?? 'Passenger';
    final vehicleName = booking.vehicleName?.trim();
    final vehicleNumber = booking.vehicleNumber?.trim();
    final scheduledAt = booking.scheduledAt?.trim();
    final notes = booking.notes?.trim();
    final vehicleLabelParts = <String>[
      if (vehicleName != null && vehicleName.isNotEmpty) vehicleName,
      if (vehicleNumber != null && vehicleNumber.isNotEmpty) vehicleNumber,
    ];
    final vehicleLabel = vehicleLabelParts.join(' • ');

    return Container(
      color: Colors.black.withValues(alpha: 0.68),
      child: SafeArea(
        child: Center(
          child: CustomScrollView(
            shrinkWrap: true,
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF23201C), Color(0xFF141210)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: _kGreen.withValues(alpha: 0.28),
                          width: 1.4,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: Container(
                                  width: 54,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: _kGreen.withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: const Icon(
                                      Icons.local_taxi_rounded,
                                      color: _kGreen,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _kGreen.withValues(
                                              alpha: 0.14,
                                            ),
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: const Text(
                                            'NEW RIDE REQUEST',
                                            style: TextStyle(
                                              color: _kGreen,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          bookingType,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w900,
                                            height: 1.05,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Booking #$bookingNo',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.72),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 54,
                                        height: 54,
                                        child: CircularProgressIndicator(
                                          value: progress,
                                          backgroundColor: Colors.white10,
                                          valueColor:
                                              const AlwaysStoppedAnimation<Color>(
                                                _kGreen,
                                              ),
                                          strokeWidth: 4,
                                        ),
                                      ),
                                      Text(
                                        '${countdown}s',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: _RideInfoTile(
                                      label: 'Estimated fare',
                                      value:
                                          '₹${(booking.estimatedAmount ?? 0).toStringAsFixed(0)}',
                                      icon: Icons.payments_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _RideInfoTile(
                                      label: 'Passenger',
                                      value: passengerName,
                                      icon: Icons.person_rounded,
                                    ),
                                  ),
                                ],
                              ),
                              if (vehicleLabel.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                _RideInfoTile(
                                  label: 'Vehicle',
                                  value: vehicleLabel,
                                  icon: Icons.directions_car_rounded,
                                ),
                              ],
                              if (scheduledAt != null && scheduledAt.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                _RideInfoTile(
                                  label: 'Scheduled for',
                                  value: scheduledAt,
                                  icon: Icons.schedule_rounded,
                                ),
                              ],
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Route',
                                      style: TextStyle(
                                        color: Colors.white30,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _RouteTimeline(
                                      pickup:
                                          booking.pickupAddress ??
                                          'Pickup address not available',
                                      drop:
                                          booking.dropAddress ??
                                          'Drop address not available',
                                    ),
                                  ],
                                ),
                              ),
                              if (notes != null && notes.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.04),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.06),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Notes',
                                        style: TextStyle(
                                          color: Colors.white30,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        notes,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          height: 1.4,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: OutlinedButton(
                                      onPressed: onDecline,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white70,
                                        side: const BorderSide(color: Colors.white24),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                      ),
                                      child: const Text(
                                        'Decline',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 3,
                                    child: ElevatedButton(
                                      onPressed: isAccepting ? null : onAccept,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _kGreen,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                      ),
                                      child: isAccepting
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'Accept Ride',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RideInfoTile extends StatelessWidget {
  const _RideInfoTile({
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _kGreen.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _kGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteTimeline extends StatelessWidget {
  const _RouteTimeline({required this.pickup, required this.drop});

  final String pickup;
  final String drop;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const Icon(Icons.circle, color: _kGreen, size: 14),
                Container(width: 1.5, height: 24, color: Colors.white24),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PICKUP',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pickup,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, color: _kRed, size: 14),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DROP-OFF',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    drop,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
