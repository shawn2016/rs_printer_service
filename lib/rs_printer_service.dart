// sunmi
import 'package:flutter/foundation.dart';

import 'src/parser/template_parser.dart';
import 'src/printers/imin/imin_printer_v1.dart';
import 'src/printers/imin/imin_printer_v2.dart';
import 'src/printers/printer_interface.dart';
import 'src/printers/sunmi/sunmi_printer.dart';
import 'src/utils/PrinterDetector.dart';

enum PrinterType { // iMin系列
  iminV1,
  iminV2,
  // Sunmi系列（示例）
  sunmi,
  unknown, // 未知型号
   }

class RSPrinterService {
  static RSPrinterInterface? _printer;


  /// 通用入口：先检测型号，再打印
  static Future<bool> autoPrintTemplate(
      String templateXml,
      Map<String, dynamic> data, {
        int paperSize = 58,
      }) async {
    // 1. 检测打印机型号
    final printerType = await PrinterDetector.detectPrinterType(paperSize: paperSize);
    if (printerType == PrinterType.unknown) {
      if (kDebugMode) {
        print('无法识别打印机型号，打印失败');
      }
      return false;
    }

    // 2. 根据型号打印
    return printTemplate(templateXml, data, printerType, paperSize: paperSize);
  }

  /// 原有方法：接收明确的型号打印（保持不变，支持手动指定）
  static Future<bool> printTemplate(
      String templateXml,
      Map<String, dynamic> data,
      PrinterType type, {
        int paperSize = 58,
      }) async {
    try {
      // 1. 获取打印机实例
      final printer = await getPrinter(type, paperSize);
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

  static Future<RSPrinterInterface> getPrinter(PrinterType type, int paperSize) async {
    if (_printer != null) {
      return _printer!;
    }


    switch (type) {
      case PrinterType.iminV1:
        _printer = IMinPrinterV1(
          paperSize: paperSize
        );
        break;
      case PrinterType.iminV2:
        _printer = IMinPrinterV2(
            paperSize: paperSize
        );
        break;
      case PrinterType.sunmi:
        _printer = SunmiPrinter(
            paperSize: paperSize
            );
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
