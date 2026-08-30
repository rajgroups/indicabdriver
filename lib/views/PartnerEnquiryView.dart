import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/layout/app.dart';
import 'package:indicab_driver/network/client.dart';
import 'package:indicab_driver/network/endpoints.dart';

// ─── Palette (matching login screen) ─────────────────────────────────────────
const _kNavy  = Color(0xFF1A1A2E);
const _kGreen = Color(0xFF00C853);
const _kBg    = Color(0xFFF5F6FA);
const _kGold  = Color(0xFFF5B800);

class PartnerEnquiryView extends StatefulWidget {
  const PartnerEnquiryView({super.key});

  @override
  State<PartnerEnquiryView> createState() => _PartnerEnquiryViewState();
}

class _PartnerEnquiryViewState extends State<PartnerEnquiryView>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _noteController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient().post(
        ApiEndpoints.partnerEnquiry,
        data: {
          'name': _nameController.text.trim(),
          'mobile': _mobileController.text.trim(),
          'contact_note': _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        },
      );

      var payload = response.data;
      if (payload is String) {
        try {
          payload = jsonDecode(payload);
        } catch (_) {}
      }

      if (payload is Map<String, dynamic> &&
          (payload['status'] == 'success' || payload['status'] == true)) {
        Get.snackbar(
          'Success! 🎉',
          payload['message'] ?? 'Your enquiry has been submitted successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: _kGreen,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
          margin: const EdgeInsets.all(16),
          borderRadius: 16,
          duration: const Duration(seconds: 3),
          snackStyle: SnackStyle.FLOATING,
        );
        // Clear form
        _nameController.clear();
        _mobileController.clear();
        _noteController.clear();

        // Navigate back after a short delay
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) Get.back();
        });
      } else {
        final msg = (payload is Map<String, dynamic>)
            ? (payload['message'] ?? 'Something went wrong.')
            : 'Something went wrong.';
        Get.snackbar(
          'Error',
          msg.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          icon: const Icon(Icons.error_rounded, color: Colors.white),
          margin: const EdgeInsets.all(16),
          borderRadius: 16,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to submit enquiry. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        icon: const Icon(Icons.error_rounded, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      backgroundColor: _kBg,
      resizeToAvoidBottomInset: true,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// ─── Top Hero Banner ─────────────────────
                          _buildHeroBanner(),

                          const SizedBox(height: 16),

                          /// ─── Form Card ───────────────────────────
                          Expanded(child: _buildFormCard()),

                          const SizedBox(height: 16),

                          /// ─── Footer ──────────────────────────────
                          Center(
                            child: Text(
                              "We'll reach out to you within 24 hours.",
                              style: TextStyle(
                                fontSize: 11,
                                color: const Color(0xFFB0B3C1),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEEEFF3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _kGold.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            /// Gradient background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFF8E1).withValues(alpha: 0.7),
                      Colors.white,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Top row with back button and badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          /// Back Button
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFEEEFF3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  size: 18,
                                  color: _kNavy,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Become a Partner",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                  color: _kNavy,
                                  fontFamily: 'SF Pro Text',
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                "DRIVER ENQUIRY",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  color: _kGold,
                                  fontFamily: 'SF Pro Text',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      /// Partner Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFFFD54F),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.handshake_rounded,
                              size: 13,
                              color: Color(0xFFB88400),
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Join Us",
                              style: TextStyle(
                                color: Color(0xFFB88400),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  /// Title
                  const Text(
                    "Start Earning with Indicab",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _kNavy,
                      fontFamily: 'SF Pro Display',
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// Subtitle
                  Text(
                    "Fill in your details and we'll get in touch to onboard you as a driver partner.",
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF6B6E7B),
                      fontFamily: 'SF Pro Text',
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// Feature badges
                  Row(
                    children: [
                      _BadgeChip(
                        icon: Icons.payments_rounded,
                        iconColor: const Color(0xFF2E7D32),
                        text: "Daily Payouts",
                      ),
                      const SizedBox(width: 8),
                      _BadgeChip(
                        icon: Icons.schedule_rounded,
                        iconColor: const Color(0xFFB88400),
                        text: "Flexible Hours",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFEEEFF3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _kNavy.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Fields
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ─── Name Field ─────────────────────────────
                _buildLabel("Full Name", Icons.person_rounded),
                const SizedBox(height: 8),
                _buildInputContainer(
                  child: TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                      fontSize: 15,
                      color: _kNavy,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDecoration("Enter your full name"),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 16),

                /// ─── Mobile Field ────────────────────────────
                _buildLabel("Mobile Number", Icons.phone_android_rounded),
                const SizedBox(height: 8),
                _buildInputContainer(
                  child: Row(
                    children: [
                      /// Country code
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFEEEFF3),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("🇮🇳", style: TextStyle(fontSize: 14)),
                            SizedBox(width: 4),
                            Text(
                              "+91",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _kNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(
                            fontSize: 16,
                            color: _kNavy,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                          decoration: _inputDecoration("10-digit mobile number"),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (v) {
                            if (v == null || v.trim().length != 10) {
                              return 'Enter a valid 10-digit number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// ─── Contact Note (Optional) ─────────────────
                _buildLabel(
                  "Additional Contact Info",
                  Icons.chat_bubble_outline_rounded,
                  optional: true,
                ),
                const SizedBox(height: 8),
                _buildInputContainer(
                  child: TextFormField(
                    controller: _noteController,
                    maxLines: 3,
                    minLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      fontSize: 14,
                      color: _kNavy,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: _inputDecoration(
                      "e.g. WhatsApp number, preferred call time, email...",
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// ─── Submit Button ────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: _isLoading
                        ? null
                        : const LinearGradient(
                            colors: [_kNavy, Color(0xFF2D2D4E)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                    color: _isLoading ? const Color(0xFFEEEFF3) : null,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: _isLoading
                        ? null
                        : [
                            BoxShadow(
                              color: _kNavy.withValues(alpha: 0.30),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: _kNavy,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Submit Enquiry",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable label with icon
  Widget _buildLabel(String text, IconData icon, {bool optional = false}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _kNavy.withValues(alpha: 0.6)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _kNavy,
            fontFamily: 'SF Pro Text',
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              "Optional",
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xFFB0B3C1),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Reusable input container styling
  Widget _buildInputContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEEEFF3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: child,
    );
  }

  /// Reusable input decoration (no border)
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 13,
        color: Color(0xFFB0B3C1),
        fontWeight: FontWeight.w400,
      ),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
    );
  }
}

/// Feature badge chip (reused from login illustration pattern)
class _BadgeChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _BadgeChip({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEEEFF3),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: _kNavy,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
