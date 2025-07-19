import 'package:flutter_test/flutter_test.dart';
import 'package:rs_printer_service/rs_printer_service.dart';
import 'package:rs_printer_service/rs_printer_service_platform_interface.dart';
import 'package:rs_printer_service/rs_printer_service_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockRsPrinterServicePlatform
    with MockPlatformInterfaceMixin
    implements RsPrinterServicePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final RsPrinterServicePlatform initialPlatform = RsPrinterServicePlatform.instance;

  test('$MethodChannelRsPrinterService is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelRsPrinterService>());
  });

  test('getPlatformVersion', () async {
    RsPrinterService rsPrinterServicePlugin = RsPrinterService();
    MockRsPrinterServicePlatform fakePlatform = MockRsPrinterServicePlatform();
    RsPrinterServicePlatform.instance = fakePlatform;

    expect(await rsPrinterServicePlugin.getPlatformVersion(), '42');
  });
}
