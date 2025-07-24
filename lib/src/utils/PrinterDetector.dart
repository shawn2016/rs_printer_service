import 'package:imin_printer/imin_printer.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:flutter/foundation.dart';
import '../enum/PrinterType.dart';
import '../models/parameter.dart';
import '../parser/template_parser.dart';
import '../printers/imin/imin_printer_v1.dart';
import '../printers/imin/imin_printer_v2.dart';
import '../printers/printer_interface.dart';
import '../printers/sunmi/sunmi_printer.dart';

/// 打印机型号检测工具类
class PrinterDetector {
  static RSPrinterInterface? _printer;

  /// 检测当前连接的打印机型号（通用入口）
  /// 返回对应的PrinterType，检测失败返回unknown
  static Future<PrinterType> detectPrinterType({int? paperSize = 58}) async {
    // 1. 先尝试检测iMin打印机
    final iminType = await _detectIMinType(paperSize: paperSize);
    if (iminType != PrinterType.unknown) {
      return iminType;
    }

    // 2. 再尝试检测Sunmi打印机
    final sunmiType = await _detectSunmiType(paperSize: paperSize);
    if (sunmiType != PrinterType.unknown) {
      return sunmiType;
    }

    // 3. 其他品牌检测...

    // 4. 所有检测失败，返回未知
    return PrinterType.unknown;
  }

  /// 检测iMin打印机型号（V1/V2）
  static Future<PrinterType> _detectIMinType({int? paperSize = 58}) async {
    try {
      final tempPrinter = IminPrinter();
      final Map<String, dynamic> status = await tempPrinter.getPrinterStatus();

      // 检查打印机状态是否正常
      if (status['code'] != '0') {
        if (kDebugMode) {
          print('iMin打印机状态异常: ${status['message'] ?? '未知错误'}');
        }
        return PrinterType.unknown;
      }

      // 获取SDK版本
      final sdkVersion = await tempPrinter.getSdkVersion() ?? '';
      if (kDebugMode) {
        print('iMin打印机SDK版本: $sdkVersion');
      }

      // 根据版本号判断型号
      if (sdkVersion.startsWith('2.')) {
        return PrinterType.iminV2;
      } else if (sdkVersion.startsWith('1.')) {
        return PrinterType.iminV1;
      }
    } catch (e) {
      if (kDebugMode) {
        print('检测iMin打印机时出错: $e');
      }
    }

    return PrinterType.unknown;
  }

  /// 检测Sunmi打印机型号
  static Future<PrinterType> _detectSunmiType({int? paperSize = 58}) async {
    try {
      final tempPrinter = SunmiPrinterPlus();
      final String? status = await tempPrinter.getStatus();

      if (status == 'READY') {
        return PrinterType.sunmi;
      } else {
        if (kDebugMode) {
          print('Sunmi打印机状态: $status');
        }
        return PrinterType.unknown;
      }
    } catch (e) {
      if (kDebugMode) {
        print('检测Sunmi打印机时出错: $e');
      }
      return PrinterType.unknown;
    }
  }

  /// 原有方法：接收明确的型号打印（保持不变，支持手动指定）
  static Future<bool> printTemplate(String templateXml, RSPrinterServiceParameter data,
    PrinterType type, {
    int? paperSize = 58,
  }) async {
    try {
      // 1. 获取打印机实例
      final printer = await getPrinter(type, paperSize!);
      // 2. 解析模板
      final elements = TemplateParser.parse(templateXml, data, paperSize);
      // 3. 执行打印
      return await printer.printElements(elements);
    } catch (e) {
      if (kDebugMode) {
        print('Print template error: $e');
      }
      return false;
    }
  }

  static Future<RSPrinterInterface> getPrinter(
    PrinterType type,
    int paperSize,
  ) async {
    if (_printer != null) {
      return _printer!;
    }

    switch (type) {
      case PrinterType.iminV1:
        _printer = IMinPrinterV1(paperSize: paperSize);
        break;
      case PrinterType.iminV2:
        _printer = IMinPrinterV2(paperSize: paperSize);
        break;
      case PrinterType.sunmi:
        _printer = SunmiPrinter(paperSize: paperSize);
        break;
      default:
        break;
    }

    await _printer?.connect();
    return _printer!;
  }

  static Future<void> disconnect() async {
    await _printer?.disconnect();
    _printer = null;
  }
}
