import 'dart:typed_data';

import 'package:imin_printer/imin_printer.dart';
import 'package:imin_printer/enums.dart';
import 'package:imin_printer/imin_style.dart';
import '../models/print_element.dart';
import '../models/print_style.dart';
import 'printer_interface.dart';

class IMinPrinterV2 implements RSPrinterInterface {
  final IminPrinter _iminPrinter = IminPrinter();
  int paperSize = 58; // 默认纸张大小
  IMinPrinterV2({
    this.paperSize = 58, // 默认值
  });

  // 设置纸张大小
  Future<void> _setPageSize() async {
    await _iminPrinter.setPageFormat(style: paperSize);
  }


  @override
  Future<bool> connect() async {
    try {
      // 根据版本初始化打印机
      await _iminPrinter.initPrinterParams();
      final isConnectedStatus = await isConnected();
      if (isConnectedStatus) {
        await _setPageSize();
      }

      return isConnectedStatus;
    } catch (e) {
      print('IMin printer connect error: $e');
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
      await _iminPrinter.unBindService(); // v2断开服务
    // v1无明确disconnect方法，仅初始化相反操作
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
        print('result: $result');
        if (!result) return false;
      }
      // 打印完成后走纸+切纸
      await _printAndFeedPaper(70);
      await _partialCut();
      return true;
    } catch (e) {
      print('IMin print elements error: $e');
      return false;
    }
  }

  @override
  Future<bool> printText(String text, PrintStyle style) async {
    try {
      // IminTextPictureStyle 相关API:

      // 属性	说明	类型	默认值
      // √ wordWrap	打印文字内容是否加入\n, true或者不设置自动加\n, 为false不加\n	bool	无
      // √  fontSize	打印文字大小	int	无
      // x space	打印文字行间距	double	无
      // x width	打印文字宽度	int	无
      // √  typeface	打印文字字体	IminTypeface	无
      // √  fontStyle	打印文字样式	IminFontStyle	无
      // √  align	打印文字对齐方式	IminPrintAlign	无
      final align = _convertAlignment(style.alignment);
      final fontSize = _convertFontSize(style.fontSize);
      final typeface = _convertTypeface(style);
      final fontStyle = _convertFontStyle(style);

      // 根据版本和 reverseBlackWhite 创建不同的样式
        // v2 版本：包含 space 属性
        final textStyle = IminTextPictureStyle(
          align: align,
          fontSize: fontSize,
          // letterSpacing: 1.0,
          typeface: typeface,
          fontStyle: fontStyle,
          wordWrap: true,
          reverseWhite: style.reverseBlackWhite,
        );
        await _iminPrinter.printTextBitmap(text, style: textStyle);


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
      await _printAndFeedPaper(20);

        // 直接调用方法，不获取返回值
        await _iminPrinter.printQrCode(
          data,
          qrCodeStyle: IminQrCodeStyle(
            align: align,
            qrSize: qrSize,
            errorCorrectionLevel: IminQrcodeCorrectionLevel.levelH,
          ),
        );

      await _printAndFeedPaper(20);

      // 无异常则视为成功
      return true;
    } catch (e) {
      print('IMin print QR code error: $e');
      return false;
    }
  }

  _printSolidLine() async {
      const List<int> ESC = [0x1B];
      List<int> openUnderline = [...ESC, 0x2D, 0x01];
      List<int> spaces = List.filled(32, 0x20); // 32 个空格
      List<int> closeUnderline = [...ESC, 0x2D, 0x00];
      List<int> lineFeed = [0x0A];
      Uint8List data = Uint8List.fromList([
        ...openUnderline,
        ...spaces,
        ...closeUnderline,
        ...lineFeed,
      ]);
      _iminPrinter.sendRAWData(data);
  }

  _printDottedLine() async {
    const List<int> ESC = [0x1B];

    // 1. 开启双倍高度和宽度模式
    List<int> setDoubleSize = [...ESC, 0x21, 0x00]; // ESC ! 0x11 (双倍高度+宽度)

    // 2. 打印一条由连字符组成的粗线
    List<int> lineChars = List.filled(32, 0x2D); // 32个连字符（-）

    // 3. 关闭双倍大小模式
    List<int> resetDoubleSize = [...ESC, 0x21, 0x00]; // ESC ! 0x00 (重置)

    // 4. 换行
    List<int> lineFeed = [0x0A];

    Uint8List data = Uint8List.fromList([
      ...setDoubleSize,
      ...lineChars,
      ...resetDoubleSize,
      ...lineFeed,
    ]);

    _iminPrinter.sendRAWData(data);
  }

  _printBoldSolidLine() async {
    const List<int> ESC = [0x1B];

    List<int> data = [];

    // 开启双线下划线
    data.addAll([...ESC, 0x2D, 0x02]);

    // 打印一整排空格（按打印机纸宽调整，一般是 32、42、48、64）
    data.addAll(List.filled(32, 0x20)); // 比如 48 字符宽度打印机

    // 关闭下划线
    data.addAll([...ESC, 0x2D, 0x00]);

    // 换行
    data.add(0x0A);

    await _iminPrinter.sendRAWData(Uint8List.fromList(data));
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

  // 辅助方法：部分切纸
  Future<void> _partialCut() async {
    await _iminPrinter.partialCut();
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

  // 转换字体大小（自定义FontSize -> 数值）
  int _convertFontSize(FontSize fontSize) {
    switch (fontSize) {
      case FontSize.small:
        return 20;
      case FontSize.large:
        return 28;
      case FontSize.xlarge:
        return 36;
      case FontSize.xxlarge:
        return 42;
      case FontSize.xxxlarge:
        return 56;
      case FontSize.xxxxlarge:
        return 64;
      case FontSize.xxxxxlarge:
        return 72;
      default: // normal
        return 24;
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
