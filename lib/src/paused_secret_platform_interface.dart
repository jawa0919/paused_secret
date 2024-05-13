import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'paused_secret_method_channel.dart';

abstract class PausedSecretPlatform extends PlatformInterface {
  /// Constructs a PausedSecretPlatform.
  PausedSecretPlatform() : super(token: _token);

  static final Object _token = Object();

  static PausedSecretPlatform _instance = MethodChannelPausedSecret();

  /// The default instance of [PausedSecretPlatform] to use.
  ///
  /// Defaults to [MethodChannelPausedSecret].
  static PausedSecretPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PausedSecretPlatform] when
  /// they register themselves.
  static set instance(PausedSecretPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> disableScreenshot(bool disable) {
    throw UnimplementedError('disableScreenshot() has not been implemented.');
  }

  Future<void> pausedSecret(bool secret) {
    throw UnimplementedError('pausedSecret() has not been implemented.');
  }

  Stream<T> onScreenshot<T>() {
    throw UnimplementedError('onScreenshot() has not been implemented.');
  }
}
