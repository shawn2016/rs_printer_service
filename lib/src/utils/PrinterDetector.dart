import 'package:imin_printer/imin_printer.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

import '../../rs_printer_service.dart';

/// 打印机型号检测工具类
class PrinterDetector {
  /// 检测当前连接的打印机型号（通用入口）
  /// 返回对应的PrinterType，检测失败返回unknown
  static Future<PrinterType> detectPrinterType({int paperSize = 58}) async {
    // 1. 先尝试检测iMin打印机
    final iminType = await _detectIMinType(paperSize: paperSize);
    if (iminType != PrinterType.unknown) {
      return iminType;
    }

    // 2. 再尝试检测Sunmi打印机（未来实现）
    final sunmiType = await _detectSunmiType(paperSize: paperSize);
    if (sunmiType != PrinterType.unknown) {
      return sunmiType;
    }

    // 3. 其他品牌检测...

    // 4. 所有检测失败，返回未知
    return PrinterType.unknown;
  }

  /// 检测iMin打印机型号（V1/V2）
  static Future<PrinterType> _detectIMinType({int paperSize = 58}) async {
    final tempPrinter = IminPrinter(); // 临时实例

    // 1. 尝试V2初始化方法（优先）
    try {
      await tempPrinter.initPrinterParams(); // V2初始化
      final sdkVersion = await tempPrinter.getSdkVersion() ?? '';
      if (sdkVersion.startsWith('2.')) {
        return PrinterType.iminV2;
      } else if (sdkVersion.startsWith('1.')) {
        return PrinterType.iminV1; // 特殊情况：V2 SDK返回1.x版本
      }
    } catch (e) {
      // V2初始化失败，尝试V1
    }

    // 2. 尝试V1初始化方法
    try {
      await tempPrinter.initPrinter(); // V1初始化
      final sdkVersion = await tempPrinter.getSdkVersion() ?? '';
      if (sdkVersion.startsWith('1.')) {
        return PrinterType.iminV1;
      } else if (sdkVersion.startsWith('2.')) {
        return PrinterType.iminV2; // 特殊情况：V1 SDK返回2.x版本
      }
    } catch (e) {
      // V1初始化失败，说明不是iMin打印机
      return PrinterType.unknown;
    }

    // 3. 版本号不明确，默认返回unknown
    return PrinterType.unknown;
  }

  /// 检测Sunmi打印机型号（示例，未来实现）
  static Future<PrinterType> _detectSunmiType({int paperSize = 58}) async {
    final tempPrinter = SunmiPrinterPlus(); // Sunmi临时实例
    try {
      // Sunmi特有检测逻辑（如获取型号标识）
      final model = await tempPrinter.getType();
      if (model == 'Sunmi') {
        return PrinterType.sunmi;
      }  else {
        return PrinterType.unknown;
      }
    } catch (e) {
      // 初始化失败，说明不是Sunmi打印机
      return PrinterType.unknown;
    } finally {
      // await tempPrinter.disconnect(); // 断开临时连接
    }
  }
}