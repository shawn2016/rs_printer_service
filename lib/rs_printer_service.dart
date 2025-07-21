// sunmi
import 'src/parser/template_parser.dart';
import 'src/printers/imin_printer.dart';
import 'src/printers/printer_interface.dart';

enum PrinterType { imin }

class RSPrinterService {
  static RSPrinterInterface? _printer;

  static Future<RSPrinterInterface> getPrinter(PrinterType type, int pageSize) async {
    if (_printer != null) {
      return _printer!;
    }


    switch (type) {
      case PrinterType.imin:
        _printer = IMinPrinter(
          pageSize: pageSize
        );
        break;
      // case PrinterType.sunmi:
      //   _printer = SunmiPrinter(); // 预留实现
      //   break;
    }

    await _printer?.connect();
    return _printer!;
  }

  static Future<bool> printTemplate(
    String templateXml,
    Map<String, dynamic> data,
    PrinterType type,
  ) async {
    try {

      final pageSize = 58;
      // 1. 获取打印机实例
      final printer = await getPrinter(type,pageSize);

      // 2. 解析模板
      final elements = TemplateParser.parse(templateXml, data, pageSize);

      // 3. 执行打印
      return await printer.printElements(elements);
    } catch (e) {
      print('Print template error: $e');
      return false;
    }
  }

  static Future<void> disconnect() async {
    await _printer?.disconnect();
    _printer = null;
  }
}
