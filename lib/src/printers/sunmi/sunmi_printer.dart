import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sunmi_printer_plus/core/enums/enums.dart';
import 'package:sunmi_printer_plus/core/helpers/sunmi_helper.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_barcode_style.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_qrcode_style.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_text_style.dart';
import 'package:sunmi_printer_plus/core/types/sunmi_column.dart';
import 'package:sunmi_printer_plus/core/types/sunmi_text.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

import '../../models/print_element.dart';
import '../../models/print_style.dart' as print_style;
import '../../utils/_convertFontSize.dart';
import 'printer_controller.dart';
import '../printer_interface.dart';
import 'status_controller.dart';


class SunmiPrinter implements RSPrinterInterface {
  final SunmiPrinterPlus _sunmiPrinter = SunmiPrinterPlus();
  late final PrinterController _printerController;
  late final StatusController _statusController;
  int paperSize; // 纸张大小（58/80mm）
  PrinterStatus _printerStatus = PrinterStatus.UNKNOWN;

  // 每行字符数（用于线条打印适配纸张宽度）
  int get _charsPerLine => paperSize == 58 ? 32 : 48;

  SunmiPrinter({
    this.paperSize = 58,
  }) {
    // 初始化控制器（与 Demo 保持一致）
    _printerController = PrinterController(printer: _sunmiPrinter);
    _statusController = StatusController(printer: _sunmiPrinter);
  }

  // 初始化纸张大小（同步硬件信息）
  Future<void> _setPageSize() async {
    final paperInfo = await _statusController.getPaper();
    if (paperInfo is String && paperInfo.contains('80')) {
      paperSize = 80;
    } else {
      paperSize = 58;
    }
  }

  @override
  Future<bool> connect() async {
    try {
      final status = await _statusController.getStatus();
      _printerStatus = status;
      if (status != PrinterStatus.READY) {
        return false;
      }
      await _setPageSize();
      final version = await _statusController.getVersion();
      return version!.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Sunmi connect error: $e');
      }
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      // Sunmi 无显式断开方法，重置状态
      _printerStatus = PrinterStatus.UNKNOWN;
    } catch (e) {
      if (kDebugMode) {
        print('Sunmi disconnect error: $e');
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
      // 批量打印前初始化
      // await _printerController.printer.initPrinter();

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

      // 打印完成后切纸
      await _printerController.cutPaper();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Sunmi print elements error: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> printText(String text, print_style.PrintStyle style) async {
    try {
      // 转换文本样式（对齐方式、字体大小、粗细等）
      final sunmiAlign = _convertAlign(style.alignment);
      final sunmiTextStyle = SunmiTextStyle(
        align: sunmiAlign,
        fontSize: convertFontSize(style.fontSize),
        bold: style.isBold,
        strikethrough: false, // 删除线
        italic: style.isItalic,
        underline: false, // 下划线
        reverse: style.reverseBlackWhite, // 反色打印
      );

      // 调用最新 API 打印文本
      await _printerController.printCustomText(
        sunmiText: SunmiText(
          text: text,
          style: sunmiTextStyle,
        ),
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Sunmi print text error: $e');
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
      // 转换对齐方式
      final sunmiAlign = _convertAlign(style.alignment);

      // 计算二维码大小（映射为 Sunmi 支持的尺寸等级）
      final qrSize = (width / 30).clamp(1, 10).toInt(); // 1-10 等级
      await printBlank(1);
      // 调用最新 API 打印二维码
      await _printerController.printQRCode(
        data,
        style: SunmiQrcodeStyle(
          align: sunmiAlign,
          qrcodeSize: qrSize,
          errorLevel: SunmiQrcodeLevel.LEVEL_H, // 高容错等级
        ),
      );
      await printBlank(1);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Sunmi print QR code error: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> printLine(print_style.LineStyle style) async {
    try {
      switch (style) {
        case print_style.LineStyle.solid:
        // 普通实线（使用 Sunmi 原生线条方法）
          await _printerController.line(style: SunmiPrintLine.SOLID);
          break;
        case print_style.LineStyle.dotted:
          // 虚线（使用 Sunmi 原生线条方法）
          await _printerController.line(style: SunmiPrintLine.DOTTED);
          break;
        case print_style.LineStyle.boldSolid:
        // 粗实线（连续打印2条原生实线）
          await _printerController.line(style: SunmiPrintLine.SOLID);
          await _printerController.line(style: SunmiPrintLine.SOLID);
          break;
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Sunmi print line error: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> printBlank(int lines) async {
    try {
      // 调用最新 API 换行
      for (int i = 0; i < lines; i++) {
        await _printerController.printCustomText(
          sunmiText: SunmiText(text: " \n", style: SunmiTextStyle()),
        );
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Sunmi print blank error: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> isConnected() async {
    try {
      // 通过最新 API 获取打印机状态
      _printerStatus = await _statusController.getStatus();
      return _printerStatus == PrinterStatus.READY;
    } catch (e) {
      if (kDebugMode) {
        print('Sunmi check connection error: $e');
      }
      return false;
    }
  }

  // 辅助方法：对齐方式转换（自定义 Alignment -> SunmiPrintAlign）
  SunmiPrintAlign _convertAlign(print_style.Alignment alignment) {
    if (alignment == print_style.Alignment.center) {
      return SunmiPrintAlign.CENTER;
    } else if (alignment == print_style.Alignment.right) {
      return SunmiPrintAlign.RIGHT;
    } else {
      return SunmiPrintAlign.LEFT;
    }
  }


}