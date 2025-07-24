// sunmi
import 'package:flutter/foundation.dart';

import 'src/enum/PrinterType.dart';
import 'src/models/parameter.dart';
import 'src/parser/formatXml.dart';
import 'src/utils/PrinterDetector.dart';

export 'src/models/parameter.dart';
class RSPrinterService {
  /// 判断是否有可用打印机连接
  /// 返回true表示至少检测到一种打印机，false表示未检测到任何打印机
  static Future<bool> initPrinter({int? paperSize = 58}) async {
    final printerType = await PrinterDetector.detectPrinterType(
      paperSize: paperSize,
    );
    return printerType != PrinterType.unknown;
  }

  /// 通用入口：先检测型号，再打印
  static Future<bool> printContent(Map<String, dynamic> templateXml, RSPrinterServiceParameter data, {
    int? paperSize = 58,
  }) async {
    // 1. 检测打印机型号
    final printerType = await PrinterDetector.detectPrinterType(
      paperSize: paperSize,
    );
    if (printerType == PrinterType.unknown) {
      if (kDebugMode) {
        print('无法识别打印机型号，打印失败');
      }
      return false;
    }

    // 2. 根据型号打印
    return PrinterDetector.printTemplate(
      formatXml(templateXml),
      data,
      printerType,
      paperSize: paperSize,
    );
  }
}
