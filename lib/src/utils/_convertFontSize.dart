// 辅助方法：字体大小转换（自定义 FontSize -> Sunmi 字体大小值）
import '../models/print_style.dart';

// 转换字体大小（自定义FontSize -> 数值）
int convertFontSize(FontSize fontSize) {
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