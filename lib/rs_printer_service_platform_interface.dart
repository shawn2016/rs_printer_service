import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'rs_printer_service_method_channel.dart';

abstract class RsPrinterServicePlatform extends PlatformInterface {
  /// Constructs a RsPrinterServicePlatform.
  RsPrinterServicePlatform() : super(token: _token);

  static final Object _token = Object();

  static RsPrinterServicePlatform _instance = MethodChannelRsPrinterService();

  /// The default instance of [RsPrinterServicePlatform] to use.
  ///
  /// Defaults to [MethodChannelRsPrinterService].
  static RsPrinterServicePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [RsPrinterServicePlatform] when
  /// they register themselves.
  static set instance(RsPrinterServicePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
