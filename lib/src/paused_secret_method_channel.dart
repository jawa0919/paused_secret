import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'paused_secret_platform_interface.dart';

/// An implementation of [PausedSecretPlatform] that uses method channels.
class MethodChannelPausedSecret extends PausedSecretPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final mc = const MethodChannel('paused_secret.MethodChannel');

  @visibleForTesting
  final ec = const EventChannel('paused_secret.EventChannel');

  @override
  Future<void> disableScreenshot(bool disable) async {
    final args = {"disable": disable};
    await mc.invokeMethod<String>('disableScreenshot', args);
  }

  @override
  Future<void> pausedSecret(bool secret) async {
    final args = {"secret": secret};
    await mc.invokeMethod<String>('pausedSecret', args);
  }

  @override
  Stream<T> onScreenshot<T>() {
    return ec
        .receiveBroadcastStream("onScreenshot")
        .where((event) => event["key"] == "onScreenshot")
        .cast<T>();
  }
}
