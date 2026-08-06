import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateHelper {
  static bool _isDialogShowing = false;
  static const String currentAppVersion = '1.0.0';

  /// Compares semantic version strings (e.g., '1.0.0' < '1.1.0')
  static bool isVersionBelow(String current, String target) {
    final List<int> currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final List<int> targetParts = target.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      final int c = i < currentParts.length ? currentParts[i] : 0;
      final int t = i < targetParts.length ? targetParts[i] : 0;
      if (c < t) return true;
      if (c > t) return false;
    }
    return false;
  }

  /// Evaluates update payload and triggers mandatory non-dismissible update dialog if needed.
  static void evaluateAndShowUpdateNotice(Map<String, dynamic> updateData) {
    if (_isDialogShowing) return;

    final String latestVersion = updateData['latest_version']?.toString() ?? '1.0.0';
    final String minVersion = updateData['min_version']?.toString() ?? '1.0.0';
    final bool forceUpdateFlag = updateData['force_update'] == true ||
        updateData['force_update']?.toString() == '1' ||
        updateData['force_update']?.toString() == 'true';
    final String updateUrl = (GetPlatform.isIOS ? updateData['url_ios'] : updateData['url_android'])?.toString() ??
        updateData['update_url']?.toString() ??
        '';
    final String title = updateData['title']?.toString() ?? 'New Update Available!';
    final String message = updateData['message']?.toString() ??
        'A new version of Indicab Driver is available. Please update the app to continue using our services.';

    final bool updateAvailable = updateData['update_available'] == true || isVersionBelow(currentAppVersion, latestVersion);
    final bool isBelowMin = isVersionBelow(currentAppVersion, minVersion);

    // If update is available or forced or version is below minimum required, show non-dismissible dialog!
    if (updateAvailable || isBelowMin || forceUpdateFlag) {
      _isDialogShowing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMandatoryUpdateDialog(
          title: title,
          message: message,
          latestVersion: latestVersion,
          updateUrl: updateUrl,
        );
      });
    }
  }

  /// Renders a mandatory, non-dismissible update modal dialog that prevents using the app.
  static void _showMandatoryUpdateDialog({
    required String title,
    required String message,
    required String latestVersion,
    required String updateUrl,
  }) {
    Get.dialog(
      PopScope(
        canPop: false, // Prevents closing using system back button
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A8B4C).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.system_update_rounded,
                    color: Color(0xFF1A8B4C),
                    size: 38,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5B800).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'v$latestVersion Available',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8C6200),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A8B4C),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.download_rounded, size: 20),
                    label: const Text(
                      'Update Now',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      if (updateUrl.isNotEmpty) {
                        final uri = Uri.parse(updateUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          Get.snackbar(
                            'Update Error',
                            'Could not open store link: $updateUrl',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      } else {
                        Get.snackbar(
                          'Update Link Unavailable',
                          'Please search for Indicab Driver in Play Store/App Store to update.',
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false, // Prevents tapping outside to dismiss
    );
  }
}
