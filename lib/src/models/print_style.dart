// 字体大小
enum FontSize { small, normal, large, xxxxxlarge,xxxxlarge,xxxlarge,xxlarge,xlarge }

// 对齐方式
enum Alignment { left, center, right }

// 线条样式
enum LineStyle { boldSolid, dotted, solid }

// 打印样式
class PrintStyle {
  final FontSize fontSize;
  final Alignment alignment;
  final bool isBold;
  final bool isItalic;
  final String color;
  final bool reverseBlackWhite;
  final LineStyle? lineStyle; // 仅用于线条
  final double? width; // 仅用于二维码
  final double? height; // 仅用于二维码

  PrintStyle({
    this.fontSize = FontSize.normal,
    this.alignment = Alignment.left,
    this.isBold = false,
    this.isItalic = false,
    this.color = "black",
    this.reverseBlackWhite = false,
    this.lineStyle,
    this.width,
    this.height,
  });
}
