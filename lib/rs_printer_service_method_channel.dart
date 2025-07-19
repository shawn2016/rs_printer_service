import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'rs_printer_service_platform_interface.dart';

/// An implementation of [RsPrinterServicePlatform] that uses method channels.
class MethodChannelRsPrinterService extends RsPrinterServicePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('rs_printer_service');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
