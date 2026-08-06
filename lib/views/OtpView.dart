import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/constants/Colors.dart';
import 'package:indicab_driver/controllers/AuthController.dart';
import 'package:indicab_driver/layout/app.dart';
import 'package:indicab_driver/routes/names.dart';
import 'package:indicab_driver/views/components/otp_illustration.dart';

class OtpView extends StatefulWidget {
  const OtpView({super.key});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  final AuthController controller = Get.find<AuthController>();
  late final List<TextEditingController> _digitControllers;
  late final List<FocusNode> _focusNodes;

  Timer? _resendTimer;
  int _secondsRemaining = 60;

  @override
  void initState() {
    super.initState();
    _digitControllers = List.generate(4, (_) => TextEditingController());
    _focusNodes = List.generate(4, (_) => FocusNode());
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _secondsRemaining = 60;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0 && mounted) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final node in _focusNodes) {
      node.unfocus();
      node.dispose();
    }
    for (final digitController in _digitControllers) {
      digitController.dispose();
    }
    super.dispose();
  }

  /// Safe back navigation to Login screen ensuring gestures complete before pop
  void _goBackToLogin() {
    FocusManager.instance.primaryFocus?.unfocus();
    for (final node in _focusNodes) {
      node.unfocus();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          Get.offAllNamed(RouteNames.login);
        }
      }
    });
  }

  String _maskedMobile() {
    final mobile = controller.mobileController.text.trim();
    if (mobile.isEmpty) {
      return controller.selectedCountryCode.value;
    }
    if (mobile.length < 4) {
      return "${controller.selectedCountryCode.value} $mobile";
    }

    final visiblePart = mobile.substring(mobile.length - 4);
    return "${controller.selectedCountryCode.value} ••••••$visiblePart";
  }

  void _syncOtpValue() {
    controller.otpController.text = _digitControllers
        .map((digitController) => digitController.text)
        .join();
  }

  void _onDigitChanged(String value, int index) {
    if (value.isEmpty) {
      _syncOtpValue();
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
      return;
    }

    _digitControllers[index].text = value;
    _digitControllers[index].selection = const TextSelection.collapsed(
      offset: 1,
    );

    _syncOtpValue();

    if (index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      backgroundColor: AppColors.authBackground,
      resizeToAvoidBottomInset: true,
      child: SafeArea(
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
                        /// Top Row: Back Button
                        Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0C000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: AppColors.textPrimary,
                                  size: 20,
                                ),
                                onPressed: _goBackToLogin,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// Top Hero Banner Card with Edit Action Callback
                        OtpIllustration(
                          maskedMobile: _maskedMobile(),
                          onEditMobile: _goBackToLogin,
                        ),

                        const SizedBox(height: 16),

                        /// Main Form Card (Stretches to fill full available vertical height)
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.borderSoft,
                                width: 1.2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0C000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "One-Time Password",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                        fontFamily: 'SF Pro Text',
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    /// 4 OTP Digit Input Row
                                    Row(
                                      children: List.generate(
                                        4,
                                        (index) => Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              right: index == 3 ? 0 : 8,
                                            ),
                                            child: _OtpDigitField(
                                              controller:
                                                  _digitControllers[index],
                                              focusNode: _focusNodes[index],
                                              onChanged: (value) =>
                                                  _onDigitChanged(value, index),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Column(
                                  children: [
                                    const SizedBox(height: 20),

                                    /// Verify & Proceed Button
                                    Obx(
                                      () => SizedBox(
                                        width: double.infinity,
                                        height: 48,
                                        child: ElevatedButton(
                                          onPressed: controller.isLoading.value
                                              ? null
                                              : () {
                                                  _syncOtpValue();
                                                  controller.verifyOtp();
                                                },
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            elevation: 0,
                                            backgroundColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                          ),
                                          child: Ink(
                                            decoration: BoxDecoration(
                                              gradient: controller.isLoading.value
                                                  ? null
                                                  : const LinearGradient(
                                                      colors: [
                                                        Color(0xFFF5B800),
                                                        Color(0xFFE6A700),
                                                      ],
                                                      begin: Alignment.centerLeft,
                                                      end:
                                                          Alignment.centerRight,
                                                    ),
                                              color: controller.isLoading.value
                                                  ? AppColors.border
                                                  : null,
                                              borderRadius: BorderRadius.circular(
                                                24,
                                              ),
                                              boxShadow: controller
                                                      .isLoading.value
                                                  ? null
                                                  : [
                                                      BoxShadow(
                                                        color: const Color(
                                                          0xFFF5B800,
                                                        ).withValues(alpha: 0.35),
                                                        blurRadius: 12,
                                                        offset: const Offset(
                                                          0,
                                                          4,
                                                        ),
                                                      ),
                                                    ],
                                            ),
                                            child: Container(
                                              alignment: Alignment.center,
                                              child: controller.isLoading.value
                                                  ? const SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2.2,
                                                            color:
                                                                AppColors.black,
                                                          ),
                                                    )
                                                  : const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .verified_user_rounded,
                                                          color: Colors.black,
                                                          size: 18,
                                                        ),
                                                        SizedBox(width: 6),
                                                        Text(
                                                          "Verify & Proceed",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color: Colors.black,
                                                            letterSpacing: 0.3,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    /// Interactive Resend Countdown Box
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFBF0),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(0xFFF7E6B8),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 32,
                                            width: 32,
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFFF5B800,
                                              ).withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(
                                                10,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.timer_outlined,
                                              color: AppColors.primaryDark,
                                              size: 17,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Didn't receive code?",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(height: 1),
                                                Text(
                                                  _secondsRemaining > 0
                                                      ? "Resend available in 00:${_secondsRemaining.toString().padLeft(2, '0')}"
                                                      : "You can resend a new OTP now",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: _secondsRemaining > 0
                                                        ? AppColors.textSecondary
                                                        : const Color(0xFF00C853),
                                                    fontWeight:
                                                        _secondsRemaining > 0
                                                            ? FontWeight.w400
                                                            : FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: _secondsRemaining == 0
                                                ? () {
                                                    _startResendTimer();
                                                    controller.sendOtp();
                                                  }
                                                : null,
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              backgroundColor:
                                                  _secondsRemaining == 0
                                                      ? const Color(0xFFF5B800)
                                                      : AppColors.border
                                                          .withValues(
                                                            alpha: 0.5,
                                                          ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text(
                                              "Resend",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                color: _secondsRemaining == 0
                                                    ? Colors.black
                                                    : AppColors.textMuted,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
    );
  }
}

class _OtpDigitField extends StatelessWidget {
  const _OtpDigitField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        fontFamily: 'SF Pro Display',
      ),
      maxLength: 1,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(1),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        counterText: "",
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
      ),
    );
  }
}
