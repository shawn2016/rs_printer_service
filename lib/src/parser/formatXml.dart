String formatXml(Map<String, dynamic> xmlData) {
  // 从输入数据中获取原始XML字符串
  final rawXml = xmlData['data'] as String? ?? '';

  // 移除转义字符并格式化XML
  return _formatXmlContent(rawXml);
}

String _formatXmlContent(String xml) {
  // 移除换行符转义并处理引号
  final cleanedXml = xml.replaceAll(r'\n', '').replaceAll(r'\"', '"');

  // 应用格式化规则
  return _applyFormattingRules(cleanedXml);
}

String _applyFormattingRules(String xml) {
  // 格式化规则：
  // 1. 在相邻标签间添加换行
  // 2. 每个row标签前后添加换行
  // 3. 合并多余空格
  // 4. 去除首尾空白字符
  return xml
      .replaceAll('><', '>\n<')
      .replaceAll('<row', '\n<row')
      .replaceAll('</row>', '</row>\n')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
