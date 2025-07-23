import 'package:flutter/foundation.dart';
import 'package:imin_printer/imin_printer.dart';
import 'package:imin_printer/enums.dart';
import 'package:imin_printer/imin_style.dart';
import '../../models/print_element.dart';
import '../../models/print_style.dart';
import '../../utils/_convertFontSize.dart';
import '../printer_interface.dart';

class IMinPrinterV1 implements RSPrinterInterface {
  final IminPrinter _iminPrinter = IminPrinter();
  int paperSize = 58; // 默认纸张大小
  IMinPrinterV1({
    this.paperSize = 58, // 默认值
  });
  int get _charsPerLine => paperSize == 58 ? 32 : 48;

  // 设置纸张大小
  Future<void> _setPageSize() async {
    await _iminPrinter.setPageFormat(style: paperSize);
  }

  @override
  Future<bool> connect() async {
    try {
      // 根据版本初始化打印机
      await _iminPrinter.initPrinter(); // v1初始化
      final isConnectedStatus = await isConnected();
      if (isConnectedStatus) {
        await _setPageSize();
      }

      return isConnectedStatus;
    } catch (e) {
      if (kDebugMode) {
        print('IMin printer connect error: $e');
      }
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
  // TODO : implement disconnect
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
      // 打印完成后走纸+切纸
      await _printAndFeedPaper(70);

        _iminPrinter.printAndLineFeed();
      return true;
    } catch (e) {
      print('IMin print elements error: $e');
      return false;
    }
  }

  @override
  Future<bool> printText(String text, PrintStyle style) async {
    try {
      // IminTextStyle 相关API:

      // 属性	说明	类型	默认值
      // √ wordWrap	打印文字内容是否加入\n, true或者不设置自动加\n, 为false不加\n	bool	无
      // √  fontSize	打印文字大小	int	无
      // x space	打印文字行间距	double	无
      // x width	打印文字宽度	int	无
      // √  typeface	打印文字字体	IminTypeface	无
      // √  fontStyle	打印文字样式	IminFontStyle	无
      // √  align	打印文字对齐方式	IminPrintAlign	无
      final align = _convertAlignment(style.alignment);
      final fontSize = convertFontSize(style.fontSize);
      final typeface = _convertTypeface(style);
      final fontStyle = _convertFontStyle(style);

      // 根据版本和 reverseBlackWhite 创建不同的样式

        final textStyle = IminTextStyle(
          align: align,
          space: 0.85,
          fontSize: fontSize,
          fontStyle: fontStyle,
          typeface: typeface,
          wordWrap: false,
        );
        if (style.reverseBlackWhite) {
          await _iminPrinter.printAntiWhiteText(text,style: textStyle);
        } else {
          await _iminPrinter.printText(text, style: textStyle);

        }

      return true;
    } catch (e) {
      print('IMin print text error: $e');
      return false;
    }
  }

  // 实现二维码打印
  @override
  Future<bool> printQrCode(
    String data,
    double width,
    double height,
    PrintStyle style,
  ) async {
    try {
      final align = _convertAlignment(style.alignment);
      final qrSize = (width / 30).clamp(1, 10).toInt();
      _iminPrinter.setTextLineSpacing(0.01);
     await _iminPrinter.printText(" ",   style: IminTextStyle(
        align: IminPrintAlign.left,
        space: 0.01,
        fontSize: convertFontSize(FontSize.normal),
        fontStyle: IminFontStyle.bold,
        typeface: IminTypeface.typefaceDefaultBold,
        wordWrap: false,
      ));
        // 直接调用方法，不获取返回值
        _iminPrinter.setQrCodeSize(qrSize);
        await _iminPrinter.printQrCode(
          data,
          qrCodeStyle: IminQrCodeStyle(
            align: align,
            qrSize: qrSize,
            leftMargin: 0,
            errorCorrectionLevel: IminQrcodeCorrectionLevel.levelH,
          ),
        );
      await _printAndFeedPaper(10);


      // 无异常则视为成功
      return true;
    } catch (e) {
      print('IMin print QR code error: $e');
      return false;
    }
  }

  // 实现实线
  Future<void> _printSolidLine() async {
    final count = 16;
    final line = ''.padRight(count, '─');
    await _iminPrinter.printText(
      line,
      style: IminTextStyle(
        align: IminPrintAlign.left,
        fontSize: convertFontSize(FontSize.normal),
        fontStyle: IminFontStyle.normal,
        typeface: IminTypeface.typefaceDefault,
        wordWrap: false,
      ),
    );
  }

  // 实现粗实线（使用等宽符号或加粗样式）
  Future<void> _printBoldSolidLine() async {
    final count =  16;
    final line = ''.padRight(count, '━'); // 可改成'━'等字符
    await _iminPrinter.printText(
      line,
      style: IminTextStyle(
        align: IminPrintAlign.left,
        fontSize: convertFontSize(FontSize.normal),
        fontStyle: IminFontStyle.bold,
        typeface: IminTypeface.typefaceDefaultBold,
        wordWrap: false,
      ),
    );
  }
//  实线（细）：─ (U+2500)
//
//  实线（粗）：━ (U+2501)
//
//  虚线（细）：┄ (U+2504) 或 ┈ (U+2508)
//
//  虚线（粗）：┅ (U+2505) 或 ┉ (U+2509)
//
//  双线：═ (U+2550)，竖线双：║ (U+2551)
  // 实现虚线
  Future<void> _printDottedLine() async {
    // final count =16;
    // final buffer = StringBuffer();
    // for (int i = 0; i < count; i++) {
    //   buffer.write('┄');
    // }
    final count =  16;
    final line = ''.padRight(count, '┄'); // 可改成'━'等字符
    await _iminPrinter.printText(
      line,
      style: IminTextStyle(
        align: IminPrintAlign.left,
        fontSize: convertFontSize(FontSize.normal),
        fontStyle: IminFontStyle.normal,
        typeface: IminTypeface.typefaceDefault,
        wordWrap: false,
      ),
    );
  }


  @override
  Future<bool> printLine(LineStyle style) async {
    try {
      // 根据纸张宽度计算填充字符数量（不同字体宽度不同，需调整）
      switch (style) {
        case LineStyle.boldSolid:
          _printBoldSolidLine();
          break;
        case LineStyle.dotted:
          _printDottedLine();
          break;
        default:
          _printSolidLine();
      }
      return true;
    } catch (e) {
      print('IMin print line error: $e');
      return false;
    }
  }

  @override
  Future<bool> printBlank(int lines) async {
    try {
      await _iminPrinter.printAndFeedPaper(lines * 30);

      // 无异常则视为成功
      return true;
    } catch (e) {
      print('IMin print blank error: $e');
      return false;
    }
  }

  // @override
  // Future<bool> printBlank(int lines) async {
  //   try {
  //     if (_isV2) {
  //       // v2版本打印空白行（每行约30单位高度）
  //       return await _iminPrinter.printAndFeedPaper(lines * 30) ?? false;
  //     } else {
  //       // v1版本打印空白行
  //       return await _iminPrinter.printBlankLines(lines) ?? false;
  //     }
  //   } catch (e) {
  //     print('IMin print blank error: $e');
  //     return false;
  //   }
  // }
  //  检查打印机是否连接
  @override
  Future<bool> isConnected() async {
    try {
      // 通过获取打印机状态判断是否连接
      final status = await _iminPrinter.getPrinterStatus();
      if (status['code'] == '0') {
        _setPageSize();
      }
      return status['code'] == '0'; // 假设code=0为正常状态
    } catch (e) {
      print('IMin check connection error: $e');
      return false;
    }
  }

  // 辅助方法：走纸
  Future<void> _printAndFeedPaper(int distance) async {
    await _iminPrinter.printAndFeedPaper(distance);
  }


  // 转换对齐方式（自定义Align -> IminPrintAlign）
  IminPrintAlign _convertAlignment(Alignment alignment) {
    switch (alignment) {
      case Alignment.center:
        return IminPrintAlign.center;
      case Alignment.right:
        return IminPrintAlign.right;
      default:
        return IminPrintAlign.left;
    }
  }


  // 设置文字字体
  _convertTypeface(PrintStyle style) {
    IminTypeface typeface = IminTypeface.typefaceDefaultBold;
    return typeface;
  }

  // 设置文字样式
  _convertFontStyle(PrintStyle style) {
    IminFontStyle fontStyle = IminFontStyle.normal;
    if (style.isItalic && style.isBold) {
      fontStyle = IminFontStyle.boldItalic;
    } else if (style.isItalic) {
      fontStyle = IminFontStyle.italic;
    } else if (style.isBold) {
      fontStyle = IminFontStyle.bold;
    } else {
      fontStyle = IminFontStyle.normal;
    }
    return fontStyle;
  }
}
