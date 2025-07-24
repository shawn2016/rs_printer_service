import 'package:imin_printer/enums.dart';
import '../../models/print_style.dart';
// 转换对齐方式（自定义Align -> IminPrintAlign）

IminPrintAlign convertAlignment(Alignment alignment) {
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
convertTypeface(PrintStyle style) {
  IminTypeface typeface = IminTypeface.typefaceDefaultBold;
  return typeface;
}

// 设置文字样式
convertFontStyle(PrintStyle style) {
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