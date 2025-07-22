import 'package:xml/xml.dart';
import '../models/print_element.dart';
import '../models/print_style.dart';
//
// String renderTemplate(String tpl, Map<String, dynamic> data) {
//   var xml = tpl;

//   /// 先清理 <#if true/false>
//   final ifTrueFalseRegex = RegExp(r'<#if\s+(true|false)\s*>([\s\S]*?)</#if>');
//   while (ifTrueFalseRegex.hasMatch(xml)) {
//     xml = xml.replaceAllMapped(ifTrueFalseRegex, (m) {
//       final condition = m[1]!;
//       final inner = m[2]!;
//       return condition == 'true' ? inner : '';
//     });
//   }

//   /// 清理 <#if key??>，只要 data 没 key 或 value == null 就删
//   final ifRegex = RegExp(r'<#if\s+(\w+)\s*\?\?\s*>([\s\S]*?)</#if>');
//   while (ifRegex.hasMatch(xml)) {
//     xml = xml.replaceAllMapped(ifRegex, (m) {
//       final key = m[1]!;
//       final content = m[2]!;
//       final value = data.containsKey(key) ? data[key] : null;
//       return (value != null && value!='') ? content : '';
//     });
//   }

//   /// 替换 ${key?default('xxx')}
//   final defaultRegex = RegExp(r"""\$\{(\w+)\?default\('([^']*)'\)\}""");
//   xml = xml.replaceAllMapped(defaultRegex, (m) {
//     final key = m[1]!;
//     final def = m[2]!;
//     final value = data.containsKey(key) ? data[key] : null;
//     return ((value != null && value!='') ? value.toString() : def);
//   });

//   /// 替换 ${key}
//   final varRegex = RegExp(r"""\$\{(\w+)\}""");
//   xml = xml.replaceAllMapped(varRegex, (m) {
//     final key = m[1]!;
//     final value = data.containsKey(key) ? data[key] : null;
//     return (value != null && value!='') ? value.toString() : '';
//   });

//   return xml;
// }

// 获取宽度属性，支持绝对值和百分比
double getWidth(XmlElement column, double totalWidth) {
  final widthAttr = column.getAttribute('width') ?? '50%';

  // 处理百分比
  if (widthAttr.endsWith('%')) {
    final percentStr = widthAttr.substring(0, widthAttr.length - 1);
    final percent = double.tryParse(percentStr) ?? 50.0;
    return totalWidth * (percent / 100); // 转换为实际宽度
  }

  // 处理绝对值
  return double.tryParse(widthAttr) ?? totalWidth / 2;
}

// 获取高度属性，支持绝对值和百分比
double getHeight(XmlElement column, double totalHeight) {
  final heightAttr = column.getAttribute('high') ?? '50%';

  // 处理百分比
  if (heightAttr.endsWith('%')) {
    final percentStr = heightAttr.substring(0, heightAttr.length - 1);
    final percent = double.tryParse(percentStr) ?? 50.0;
    return totalHeight * (percent / 100); // 转换为实际高度
  }

  // 处理绝对值
  return double.tryParse(heightAttr) ?? totalHeight / 2;
}
//
// // 处理模版
// String renderTemplate(String tpl, Map<String, dynamic> data) {
//   var xml = tpl;
//
//   // 0. 原始：先处理 <#if true/false>（全局有效）
//   final ifTrueFalse = RegExp(r'<#if\s+(true|false)\s*>([\s\S]*?)</#if>');
//   while (ifTrueFalse.hasMatch(xml)) {
//     xml = xml.replaceAllMapped(ifTrueFalse, (m) =>
//     m[1] == 'true' ? m[2]! : ''
//     );
//   }
//
//   // 1. **行级**: 剔除包着整行<row>的 <#if key??>…</#if>
//   final rowIf = RegExp(
//       r'<#if\s+(\w+)\s*\?\?\s*>\s*(<row[\s\S]*?<\/row>)\s*<\/#if>'
//   );
//   while (rowIf.hasMatch(xml)) {
//     xml = xml.replaceAllMapped(rowIf, (m) {
//       final key = m[1]!;
//       final rowBlock = m[2]!;
//       final value = data.containsKey(key) ? data[key] : null;
//       // key 存在且非空，保留整个 <row> … </row>；否则一并删掉
//       return (value != null && value.toString().trim().isNotEmpty)
//           ? rowBlock
//           : '';
//     });
//   }
//
//   // 2. **列级**: 剔除在 <column> 内部的 <#if key??>…</#if>，只删内部内容
//   //    先拆出每个 column，再对子串做替换，最后再拼回去
//   xml = xml.replaceAllMapped(
//       RegExp(r'<column\b([^>]*)>([\s\S]*?)<\/column>'),
//           (m) {
//         final attrs = m[1]!;
//         var inner = m[2]!;
//
//         // 删除 column 里因 key 缺失或空导致的 if 块
//         final colIf = RegExp(r'<#if\s+(\w+)\s*\?\?\s*>([\s\S]*?)<\/#if>');
//         while (colIf.hasMatch(inner)) {
//           inner = inner.replaceAllMapped(colIf, (cm) {
//             final key = cm[1]!;
//             final content = cm[2]!;
//             final value = data.containsKey(key) ? data[key] : null;
//             // key 存在且非空，保留内部；否则删内部
//             return (value != null && value.toString().trim().isNotEmpty)
//                 ? content
//                 : '';
//           });
//         }
//
//         return '<column$attrs>$inner</column>';
//       }
//   );
//
//   // 3. 默认值占位 ${key?default('xxx')}
//   final defaultRe = RegExp(r"""\$\{(\w+)\?default\('([^']*)'\)\}""");
//   xml = xml.replaceAllMapped(defaultRe, (m) {
//     final key = m[1]!;
//     final def = m[2]!;
//     final value = data.containsKey(key) ? data[key] : null;
//     return (value != null && value.toString().trim().isNotEmpty)
//         ? value.toString()
//         : def;
//   });
//
//   // 4. 普通占位 ${key}
//   final varRe = RegExp(r"""\$\{(\w+)\}""");
//   xml = xml.replaceAllMapped(varRe, (m) {
//     final key = m[1]!;
//     final value = data.containsKey(key) ? data[key] : null;
//     return (value != null && value.toString().trim().isNotEmpty)
//         ? value.toString()
//         : '';
//   });
//
//   // （可选）清理空行、空标签
//   xml = xml.replaceAll(RegExp(r'\s*<column[^>]*>\s*</column>\s*'), '');
//   xml = xml.replaceAll(RegExp(r'\s*<row[^>]*>\s*</row>\s*'), '');
//   xml = xml.replaceAll(RegExp(r'\n\s*\n'), '\n');
//
//   return xml.trim();
// }

String renderTemplate(String tpl, Map<String, dynamic> data) {
  var xml = tpl;

  // 0. 处理 <#if true/false>
  final ifTrueFalse = RegExp(r'<#if\s+(true|false)\s*>([\s\S]*?)</#if>');
  while (ifTrueFalse.hasMatch(xml)) {
    xml = xml.replaceAllMapped(ifTrueFalse, (m) => m[1] == 'true' ? m[2]! : '');
  }

  // 1. 行级：剔除包着整行<row>的 <#if key??>…</#if>
  final rowIf = RegExp(
    r'<#if\s+(\w+)\s*\?\?\s*>\s*(<row[\s\S]*?<\/row>)\s*<\/#if>',
  );
  while (rowIf.hasMatch(xml)) {
    xml = xml.replaceAllMapped(rowIf, (m) {
      final key = m[1]!;
      final rowBlock = m[2]!;
      final value = data.containsKey(key) ? data[key] : null;
      return (value != null && value.toString().trim().isNotEmpty)
          ? rowBlock
          : '';
    });
  }

  // 2. 列级：剔除 column 内部的 <#if key??>…</#if>
  xml = xml.replaceAllMapped(RegExp(r'<column\b([^>]*)>([\s\S]*?)<\/column>'), (
    m,
  ) {
    final attrs = m[1]!;
    var inner = m[2]!;

    final colIf = RegExp(r'<#if\s+(\w+)\s*\?\?\s*>([\s\S]*?)<\/#if>');
    while (colIf.hasMatch(inner)) {
      inner = inner.replaceAllMapped(colIf, (cm) {
        final key = cm[1]!;
        final content = cm[2]!;
        final value = data.containsKey(key) ? data[key] : null;
        return (value != null && value.toString().trim().isNotEmpty)
            ? content
            : '';
      });
    }

    return '<column$attrs>$inner</column>';
  });

  // 3. 处理默认值占位 ${key?default('xxx')}
  final defaultRe = RegExp(r"""\$\{(\w+)\?default\('([^']*)'\)\}""");
  xml = xml.replaceAllMapped(defaultRe, (m) {
    final key = m[1]!;
    final def = m[2]!;
    final value = data.containsKey(key) ? data[key] : null;
    return (value != null && value.toString().trim().isNotEmpty)
        ? value.toString()
        : def;
  });

  // 4. 处理普通占位 ${key}
  final varRe = RegExp(r"""\$\{(\w+)\}""");
  xml = xml.replaceAllMapped(varRe, (m) {
    final key = m[1]!;
    final value = data.containsKey(key) ? data[key] : null;
    return (value != null && value.toString().trim().isNotEmpty)
        ? value.toString()
        : '';
  });

  // 修复：清理空标签时保留 LINE/BLANK 类型的 column
  // xml = xml.replaceAll(
  //   RegExp(r'\s*<column(?![^>]*type=["\'](LINE|BLANK)["\'])[^>]*>\s*</column>\s*'),
  //   '');

  // xml = xml.replaceAll(RegExp(r'\s*<column(?![^>]*type=["\"](LINE|BLANK)["\"])[^>]*>\s*</column>\s*'), '');
  // // 清理空 row 标签
  // // 清理空 row 标签（如果有必要，可同样添加排除逻辑）
  // xml = xml.replaceAll(RegExp(r'\s*<row[^>]*>\s*</row>\s*'), '');
  // 清理多余空行
  xml = xml.replaceAll(RegExp(r'\n\s*\n'), '\n');

  return xml.trim();
}

class TemplateParser {
  static double totalWidth = 0;
  static double totalHeight = 0;

  /// 解析渲染后的纯 XML
  static List<PrintElement> parse(
    String templateXml,
    Map<String, dynamic> data,
    int pageSize,
  ) {
    totalWidth = pageSize.toDouble();
    totalHeight = pageSize.toDouble();
    final rendered = renderTemplate(templateXml, data);

    final elements = <PrintElement>[];
    final document = XmlDocument.parse(rendered);
    for (var row in document.findAllElements('row')) {
      final column = row.findElements('column').firstOrNull;
      if (column == null) continue;
      // 自定义文字
      if (column.getAttribute('type') == null) {
        elements.add(_parseTextElement(row, column));
        continue;
      }

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


  static TextElement _parseTextElement(XmlElement row, XmlElement column) {
    final content = column.text.trim();
    final style = _parsePrintStyle(row, column);

    return TextElement(content: content, style: style);
  }

  static QrCodeElement _parseQrCodeElement(XmlElement row, XmlElement column) {
    final data = column.text.trim();
    final style = _parsePrintStyle(row, column);

    final width = getWidth(column, totalWidth);
    final height = getHeight(column, totalHeight);

    return QrCodeElement(
      data: data,
      width: width * 10,
      height: height * 10,
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
      case 'small': // 1
        return FontSize.small;
      case 'xxxxxlarge': // 8
        return FontSize.xxxxxlarge;
      case 'xxxxlarge': // 7
        return FontSize.xxxxlarge;
      case 'xxxlarge': // 6
        return FontSize.xxxlarge;
      case 'xxlarge': // 5
        return FontSize.xxlarge;
      case 'xlarge': // 4
        return FontSize.xlarge;
      case 'large': // 3
        return FontSize.large;
      default:
        return FontSize.normal; // 2
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
