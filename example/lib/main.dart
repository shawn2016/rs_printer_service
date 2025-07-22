import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:rs_printer_service/rs_printer_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  String formatXml(String xml) {
                    // 简单的格式化逻辑：在标签结束后添加换行
                    return xml
                        .replaceAll('><', '>\n<') // 标签之间换行
                        .replaceAll('<row', '\n<row') // row标签前换行
                        .replaceAll('</row>', '</row>\n') // row标签后换行
                        .replaceAll(RegExp(r'\s+'), ' ') // 合并多余空格
                        .trim(); // 去除首尾空格
                  }

                  // String templateXml = r'''<root><receipt><#if shopName??>\n<row  fontSize=\"normal\" align=\"left\" color=\"black\" isBold=\"false\" reverseBlackWhite=\"true\" isItalic=\"false\">\n<column type = \"TEXT\">门店名称:${shopName}</column>\n</row> \n</#if>\n<row>\n<column type = \"LINE\" style = \"boldSolid\"></column>\n</row> \n<#if queueNum??>\n<row  fontSize=\"normal\" align=\"left\" color=\"black\" isBold=\"false\" isItalic=\"false\">\n<column type = \"TEXT\">桌台类型+排队号:<#if queueTypeName??>${queueTypeName}:</#if>${queueNum}</column>\n</row> \n</#if>\n<row>\n<column type = \"LINE\" style = \"dotted\"></column>\n</row> \n<#if guestCount??>\n<row  fontSize=\"normal\" align=\"left\" color=\"black\" isBold=\"false\" isItalic=\"false\">\n<column type = \"TEXT\">用餐人数:${guestCount}</column>\n</row> \n</#if>\n<#if queueCount??>\n<row  fontSize=\"normal\" align=\"left\" color=\"black\" isBold=\"false\" isItalic=\"false\">\n<column type = \"TEXT\">前方需等待桌数:${queueCount}</column>\n</row> \n</#if>\n<#if queueDateTimeStr??>\n<row  fontSize=\"normal\" align=\"left\" color=\"black\" isBold=\"false\" isItalic=\"false\">\n<column type = \"TEXT\">取号时间:${queueDateTimeStr}</column>\n</row> \n</#if>\n<row>\n<column type = \"BLANK\" fontSize=\"small\" count = \"1\"></column>\n</row> \n<row>\n<column type = \"LINE\" style = \"boldSolid\"></column>\n</row> \n<#if true>\n<row  fontSize=\"normal\" align=\"center\" color=\"black\" isBold=\"false\" isItalic=\"false\">\n<column type = \"QR_CODE\"  fontSize=\"normal\" align=\"center\" color=\"black\" isBold=\"false\" width=\"50%\" high=\"50%\" isItalic=\"false\"  >${queueUpQR?default('')}</column>\n</row> \n</#if>\n<row>\n<column type = \"BLANK\" fontSize=\"small\" count = \"1\"></column>\n</row> \n<#if printTime??>\n<row  fontSize=\"normal\" align=\"left\" color=\"black\" isBold=\"false\" isItalic=\"false\">\n<column type = \"TEXT\">打印时间:${printTime}</column>\n</row> \n</#if>\n<row  fontSize=\"normal\" align=\"right\" color=\"black\" isBold=\"false\" isItalic=\"false\">\n<column>这是一段测试自定义</column>\n</row> \n<row>\n<column type = \"LINE\" style = \"dotted\"></column>\n</row> \n</receipt></root>''';

                  String templateXml = "";
                  Future<dynamic> fetchPrintTemplate() async {
                    final headers = {
                      'vulcan-token':
                          'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsb2dpblR5cGUiOiJsb2dpbiIsImxvZ2luSWQiOiJob25neXVhbiIsInJuU3RyIjoiVW9GbGtlRkxyQ21qeXZYbEtYVzFMTDY5bE9wQlNUc3UiLCJ1c2VyTmFtZSI6Iui1tea0qua6kCJ9.RxXSeKpPikj3rAxA4b8wNrZS8zgpEspm82dpcfmvpRE',
                      'corporation-id': '256',
                      'organization-id': '1768172655514521601',
                      'organization-type': '7',
                      'language-code': 'zh_CN',
                      'shop-id': '77397952',
                      'brand-id': '1768172123735494660',
                      'content-type': 'application/json',
                    };

                    final body = json.encode({
                      "isArchived": true,
                      "billTypeUid": "1725071474879318379",
                      "language": "zh_CN",
                    });

                    try {
                      final response = await http.post(
                        Uri.parse(
                          'https://bo.test.restosuite.ai/api/print/template/management/query/freemarker',
                        ),
                        headers: headers,
                        body: body,
                      );

                      if (response.statusCode == 200) {
                        final responseBody = utf8.decode(response.bodyBytes);
                        return json.decode(responseBody);
                      } else {
                        print(
                          '请求失败: ${response.statusCode}, ${response.reasonPhrase}',
                        );
                        throw Exception('HTTP错误: ${response.statusCode}');
                      }
                    } catch (e) {
                      print('网络异常: $e');
                      rethrow;
                    }
                  }

                  final result2 = await fetchPrintTemplate();
                  templateXml = result2['data'];

                  templateXml = templateXml.replaceAll(r'\n', '');
                  templateXml = templateXml.replaceAll(r'\"', '"');

                  templateXml = formatXml(templateXml);

                  final data = <String, dynamic>{
                    'shopName': '还是啥哈市撒哈市撒谎萨哈萨哈',
                    'guestCount': 3,
                    'queueCount': 0,
                    'queueDateTimeStr': '2025-07-19 18:30:00',
                    'queueUpQR': 'https://www.baidu.com',
                    'queueTypeName': '普通桌',
                    'queueNum': 'A12',
                    'printTime': DateFormat(
                      'yyyy-MM-dd HH:mm:ss',
                    ).format(DateTime.now()),
                  };

                  // 3. 调用打印
                  bool result = await RSPrinterService.autoPrintTemplate(
                    templateXml,
                    data,
                    paperSize: 58,
                  );

                  if (result) {
                    print('打印成功');
                  } else {
                    print('打印失败');
                  }
                },
                child: Text('执行打印'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
