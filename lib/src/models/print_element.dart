import 'print_style.dart';

enum ElementType { text, qrCode, line, blank }

abstract class PrintElement {
  final ElementType type;
  final PrintStyle style;

  PrintElement({required this.type, required this.style});
}

class TextElement extends PrintElement {
  final String content;

  TextElement({required this.content, required PrintStyle style})
    : super(type: ElementType.text, style: style);
}

class QrCodeElement extends PrintElement {
  final String data;
  final double width;
  final double height;

  QrCodeElement({
    required this.data,
    required this.width,
    required this.height,
    required PrintStyle style,
  }) : super(type: ElementType.qrCode, style: style);
}

class LineElement extends PrintElement {
  LineElement({required LineStyle lineStyle})
    : super(type: ElementType.line, style: PrintStyle(lineStyle: lineStyle));

  // 获取线条样式的便捷方法
  LineStyle get lineStyle => style.lineStyle ?? LineStyle.solid;
}

class BlankElement extends PrintElement {
  final int count;

  BlankElement({required this.count})
    : super(
        type: ElementType.blank,
        style: PrintStyle(fontSize: FontSize.small),
      );
}
