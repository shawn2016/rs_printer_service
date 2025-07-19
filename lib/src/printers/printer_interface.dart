import '../models/print_element.dart';
import '../models/print_style.dart';

abstract class RSPrinterInterface {
  // 链接
  Future<bool> connect();
  // 断开
  Future<void> disconnect();
  // 打印
  Future<bool> printElements(List<PrintElement> elements);
  // 打印文本
  Future<bool> printText(String text, PrintStyle style);
  // 打印二维码
  Future<bool> printQrCode(
    String data,
    double width,
    double height,
    PrintStyle style,
  );
  // 打印线
  Future<bool> printLine(LineStyle style);
  // 打印空白行
  Future<bool> printBlank(int lines);
  // 是否已连接
  Future<bool> isConnected();
}
