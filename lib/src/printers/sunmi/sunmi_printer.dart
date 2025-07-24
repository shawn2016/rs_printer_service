import 'package:flutter/foundation.dart';
import 'package:sunmi_printer_plus/core/enums/enums.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_qrcode_style.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_text_style.dart';
import 'package:sunmi_printer_plus/core/types/sunmi_text.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

import '../../models/print_element.dart';
import '../../models/print_style.dart' as print_style;
import '../../utils/_convertFontSize.dart';
import '../printer_interface.dart';

class SunmiPrinter implements RSPrinterInterface {
  final SunmiPrinterPlus _sunmiPrinter = SunmiPrinterPlus();
  int? paperSize; // 纸张大小（58/80mm）
  PrinterStatus _printerStatus = PrinterStatus.UNKNOWN;

  // 每行字符数（用于线条打印适配纸张宽度）
  int get _charsPerLine => paperSize == 58 ? 32 : 48;

  SunmiPrinter({this.paperSize = 58});

  // 初始化纸张大小（同步硬件信息）
  Future<void> _setPageSize() async {
    try {
      final paperInfo = await _sunmiPrinter.getPaper();
      if (paperInfo is String && paperInfo.contains('80')) {
        paperSize = 80;
      } else {
        paperSize = 58;
      }
    } catch (e) {
      if (kDebugMode) {
        print('获取打印机纸张尺寸失败: $e');
      }
      // 默认使用58mm
      paperSize = 58;
    }
  }

  // 将状态字符串转换为枚举
  PrinterStatus _getStatusFromString(String? status) {
    if (status == null) return PrinterStatus.UNKNOWN;

    try {
      return PrinterStatus.values.firstWhere(
        (e) => e.toString().split('.').last == status,
      );
    } catch (e) {
      return PrinterStatus.UNKNOWN;
    }
  }

  @override
  Future<bool> connect() async {
    try {
      final statusStr = await _sunmiPrinter.getStatus();
      _printerStatus = _getStatusFromString(statusStr);

      if (_printerStatus != PrinterStatus.READY) {
        return false;
      }

      await _setPageSize();
      final version = await _sunmiPrinter.getVersion();
      return version?.isNotEmpty ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Sunmi连接错误: $e');
      }
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      // Sunmi无显式断开方法，重置状态
      _printerStatus = PrinterStatus.UNKNOWN;
    } catch (e) {
      if (kDebugMode) {
        print('Sunmi断开连接错误: $e');
      }
    }
  }

  @override
  Future<bool> printElements(List<PrintElement> elements) async {
    if (!await isConnected()) {
      if (!await connect()) {
        return false;
      }
    }

    try {
      for (var element in elements) {
        bool result = false;

        switch (element.type) {
          case ElementType.text:
            result = await printText(
              (element as TextElement).content,
              element.style,
            );
            break;
          case ElementType.qrCode:
            var qrElement = element as QrCodeElement;
            result = await printQrCode(
              qrElement.data,
              qrElement.width,
              qrElement.height,
              qrElement.style,
            );
            break;
          case ElementType.line:
            var lineElement = element as LineElement;
            result = await printLine(lineElement.lineStyle);
            break;
          case ElementType.blank:
            result = await printBlank((element as BlankElement).count);
            break;
        }

        if (!result) return false;
      }

      await _sunmiPrinter.cutPaper();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Sunmi打印元素错误: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> printText(String text, print_style.PrintStyle style) async {
    try {
      final sunmiAlign = _convertAlign(style.alignment);
      final sunmiTextStyle = SunmiTextStyle(
        align: sunmiAlign,
        fontSize: convertFontSize(style.fontSize),
        bold: style.isBold,
        italic: style.isItalic,
        reverse: style.reverseBlackWhite,
      );

      final result = await _sunmiPrinter.printCustomText(
        sunmiText: SunmiText(text: text, style: sunmiTextStyle),
      );
      return result?.toLowerCase() == 'ok';
    } catch (e) {
      if (kDebugMode) {
        print('Sunmi打印文本错误: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> printQrCode(
    String data,
    double width,
    double height,
    print_style.PrintStyle style,
  ) async {
    try {
      final sunmiAlign = _convertAlign(style.alignment);
      final qrSize = (width / 30).clamp(1, 10).toInt();

      await printBlank(1);
      final result = await _sunmiPrinter.printQrcode(
        text: data,
        style: SunmiQrcodeStyle(
          align: sunmiAlign,
          qrcodeSize: qrSize,
          errorLevel: SunmiQrcodeLevel.LEVEL_H,
        ),
      );
      await printBlank(1);
      return result?.toLowerCase() == 'ok';
    } catch (e) {
      if (kDebugMode) {
        print('Sunmi打印二维码错误: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> printLine(print_style.LineStyle style) async {
    try {
      String lineType;

      switch (style) {
        case print_style.LineStyle.solid:
          lineType = SunmiPrintLine.SOLID.name;
          break;
        case print_style.LineStyle.dotted:
          lineType = SunmiPrintLine.DOTTED.name;
          break;
        case print_style.LineStyle.boldSolid:
          await _sunmiPrinter.line(type: SunmiPrintLine.SOLID.name);
          lineType = SunmiPrintLine.SOLID.name;
          break;
      }

      final result = await _sunmiPrinter.line(type: lineType);
      return result?.toLowerCase() == 'ok';
    } catch (e) {
      if (kDebugMode) {
        print('Sunmi打印线条错误: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> printBlank(int lines) async {
    try {
      for (int i = 0; i < lines; i++) {
        final result = await _sunmiPrinter.printCustomText(
          sunmiText: SunmiText(text: " \n", style: SunmiTextStyle()),
        );
        if (result?.toLowerCase() != 'ok') return false;
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Sunmi打印空行错误: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> isConnected() async {
    try {
      final statusStr = await _sunmiPrinter.getStatus();
      _printerStatus = _getStatusFromString(statusStr);
      return _printerStatus == PrinterStatus.READY;
    } catch (e) {
      if (kDebugMode) {
        print('检查Sunmi连接错误: $e');
      }
      return false;
    }
  }

  // 辅助方法：对齐方式转换
  SunmiPrintAlign _convertAlign(print_style.Alignment alignment) {
    switch (alignment) {
      case print_style.Alignment.center:
        return SunmiPrintAlign.CENTER;
      case print_style.Alignment.right:
        return SunmiPrintAlign.RIGHT;
      default:
        return SunmiPrintAlign.LEFT;
    }
  }

  // 新增：获取打印机版本
  Future<String?> getVersion() async {
    try {
      return await _sunmiPrinter.getVersion();
    } catch (e) {
      if (kDebugMode) {
        print('获取Sunmi版本错误: $e');
      }
      return null;
    }
  }

  // 新增：获取打印机ID
  Future<String?> getId() async {
    try {
      return await _sunmiPrinter.getId();
    } catch (e) {
      if (kDebugMode) {
        print('获取Sunmi ID错误: $e');
      }
      return null;
    }
  }

  // 新增：获取打印机类型
  Future<String?> getType() async {
    try {
      return await _sunmiPrinter.getType();
    } catch (e) {
      if (kDebugMode) {
        print('获取Sunmi类型错误: $e');
      }
      return null;
    }
  }
}
