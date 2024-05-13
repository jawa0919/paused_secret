import 'package:flutter/material.dart';

import 'overlay/paused_secret_manager.dart';
import 'overlay/resumed_secret_manager.dart';
import 'overlay/watermark_manager.dart';
import 'paused_secret_platform_interface.dart';

class PausedSecret {
  Future<void> disableScreenshot(bool disable) {
    return PausedSecretPlatform.instance.disableScreenshot(disable);
  }

  Future<void> pausedSecret(bool secret) {
    return PausedSecretPlatform.instance.pausedSecret(secret);
  }

  Stream<T> onScreenshot<T>() {
    return PausedSecretPlatform.instance.onScreenshot<T>();
  }

  static void addPausedSecretOverlay(BuildContext context) {
    PausedSecretManager.add(context);
  }

  static void removePausedSecretOverlay() {
    PausedSecretManager.remove();
  }

  static void addResumedSecretOverlay(
    BuildContext context, {
    Widget Function(BuildContext context, void Function() hide)? builder,
  }) {
    ResumedSecretManager.add(context, builder: builder);
  }

  static void removeResumedSecretOverlay() {
    ResumedSecretManager.remove();
  }

  static void addWatermarkOverlay(BuildContext context, String watermark) {
    WatarmarkManager.add(context, watermark);
  }

  static void removeWatermarkOverlay() {
    WatarmarkManager.remove();
  }
}
