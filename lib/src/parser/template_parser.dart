import 'package:xml/xml.dart';
import '../models/print_element.dart';
import '../models/print_style.dart';
//
String renderTemplate(String tpl, Map<String, dynamic> data) {
  var xml = tpl;

  /// 先清理 <#if true/false>
  final ifTrueFalseRegex = RegExp(r'<#if\s+(true|false)\s*>([\s\S]*?)</#if>');
  while (ifTrueFalseRegex.hasMatch(xml)) {
    xml = xml.replaceAllMapped(ifTrueFalseRegex, (m) {
      final condition = m[1]!;
      final inner = m[2]!;
      return condition == 'true' ? inner : '';
    });
  }

  /// 清理 <#if key??>，只要 data 没 key 或 value == null 就删
  final ifRegex = RegExp(r'<#if\s+(\w+)\s*\?\?\s*>([\s\S]*?)</#if>');
  while (ifRegex.hasMatch(xml)) {
    xml = xml.replaceAllMapped(ifRegex, (m) {
      final key = m[1]!;
      final content = m[2]!;
      final value = data.containsKey(key) ? data[key] : null;
      return (value != null && value!='') ? content : '';
    });
  }

  /// 替换 ${key?default('xxx')}
  final defaultRegex = RegExp(r"""\$\{(\w+)\?default\('([^']*)'\)\}""");
  xml = xml.replaceAllMapped(defaultRegex, (m) {
    final key = m[1]!;
    final def = m[2]!;
    final value = data.containsKey(key) ? data[key] : null;
    return ((value != null && value!='') ? value.toString() : def);
  });

  /// 替换 ${key}
  final varRegex = RegExp(r"""\$\{(\w+)\}""");
  xml = xml.replaceAllMapped(varRegex, (m) {
    final key = m[1]!;
    final value = data.containsKey(key) ? data[key] : null;
    return (value != null && value!='') ? value.toString() : '';
  });

  return xml;
}




class TemplateParser {

  /// 解析渲染后的纯 XML
  static List<PrintElement> parse(String templateXml, Map<String, dynamic> data) {
    final rendered = renderTemplate(templateXml, data);

    final elements = <PrintElement>[];
    final document = XmlDocument.parse(rendered);

    for (var row in document.findAllElements('row')) {
      final column = row.findElements('column').firstOrNull;
      if (column == null) continue;

      switch (column.getAttribute('type')) {
        case 'TEXT':
          elements.add(_parseTextElement(row, column));
          break;
        case 'QR_CODE':
          elements.add(_parseQrCodeElement(row, column));
          break;
        case 'LINE':
          elements.add(_parseLineElement(row, column));
          break;
        case 'BLANK':
          elements.add(_parseBlankElement(row, column));
          break;
      }
    }

    return elements;
  }

  // static List<PrintElement> parse(String templateXml) {
  //   try {
  //     final elements = <PrintElement>[];
  //     final document = XmlDocument.parse(templateXml);
  //
  //     // 解析receipt节点下的所有row
  //     for (var row in document.findAllElements('row')) {
  //       final column = row
  //           .findElements('column')
  //           .firstOrNull;
  //       if (column == null) continue;
  //
  //       final type = column.getAttribute('type');
  //       switch (type) {
  //         case 'TEXT':
  //           elements.add(_parseTextElement(row, column));
  //           break;
  //         case 'QR_CODE':
  //           elements.add(_parseQrCodeElement(row, column));
  //           break;
  //         case 'LINE':
  //           elements.add(_parseLineElement(row, column));
  //           break;
  //         case 'BLANK':
  //           elements.add(_parseBlankElement(row, column));
  //           break;
  //       }
  //     }
  //
  //     return elements;
  //   } catch (e) {
  //     print('Parse template error: $e');
  //     return [];
  //   }
  // }

  static TextElement _parseTextElement(XmlElement row, XmlElement column) {
    final content = column.text.trim();
    final style = _parsePrintStyle(row, column);

    return TextElement(content: content, style: style);
  }

  static QrCodeElement _parseQrCodeElement(XmlElement row, XmlElement column) {
    final data = column.text.trim();
    final style = _parsePrintStyle(row, column);
    final width = double.tryParse(column.getAttribute('width') ?? '50%') ?? 50;
    final height = double.tryParse(column.getAttribute('high') ?? '50%') ?? 50;

    return QrCodeElement(
      data: data,
      width: width,
      height: height,
      style: style,
    );
  }

  static LineElement _parseLineElement(XmlElement row, XmlElement column) {
    final styleStr = column.getAttribute('style') ?? 'solid';
    LineStyle lineStyle;

    switch (styleStr) {
      case 'boldSolid':
        lineStyle = LineStyle.boldSolid;
        break;
      case 'dotted':
        lineStyle = LineStyle.dotted;
        break;
      default:
        lineStyle = LineStyle.solid;
    }

    // 修改这里，使用 lineStyle 参数名
    return LineElement(lineStyle: lineStyle);
  }

  static BlankElement _parseBlankElement(XmlElement row, XmlElement column) {
    final count = int.tryParse(column.getAttribute('count') ?? '1') ?? 1;
    return BlankElement(count: count);
  }

  static PrintStyle _parsePrintStyle(XmlElement row, XmlElement column) {
    // 从row和column解析样式属性
    final fontSizeStr = row.getAttribute('fontSize') ?? 'normal';
    final alignStr = row.getAttribute('align') ?? 'left';

    return PrintStyle(
      fontSize: _parseFontSize(fontSizeStr),
      alignment: _parseAlignment(alignStr),
      isBold: row.getAttribute('isBold')?.toLowerCase() == 'true',
      isItalic: row.getAttribute('isItalic')?.toLowerCase() == 'true',
      color: row.getAttribute('color') ?? 'black',
      reverseBlackWhite:
          row.getAttribute('reverseBlackWhite')?.toLowerCase() == 'true',
      lineStyle: _parseLineStyle(column.getAttribute('style')),
    );
  }

  static FontSize _parseFontSize(String value) {
    switch (value) {
      case 'small':
        return FontSize.small;
      case 'large':
        return FontSize.large;
      default:
        return FontSize.normal;
    }
  }

  static Alignment _parseAlignment(String value) {
    switch (value) {
      case 'center':
        return Alignment.center;
      case 'right':
        return Alignment.right;
      default:
        return Alignment.left;
    }
  }

  static LineStyle? _parseLineStyle(String? value) {
    if (value == null) return null;

    switch (value) {
      case 'boldSolid':
        return LineStyle.boldSolid;
      case 'dotted':
        return LineStyle.dotted;
      default:
        return LineStyle.solid;
    }
  }
}
