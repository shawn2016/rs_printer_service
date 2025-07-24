import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
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
                  final bool initSuccess = await RSPrinterService.initPrinter();
                  if (initSuccess == false) {
                    return;
                  }
                  ;
                  Future<dynamic> fetchPrintTemplate() async {
                    final headers = {
                      'vulcan-token':
                          'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsb2dpblR5cGUiOiJsb2dpbiIsImxvZ2luSWQiOiJob25neXVhbiIsInJuU3RyIjoiVWhIVHc1ZnJYRmQ2WFdFZEdUeDFZQXZEVzRwVTZEVVMiLCJ1c2VyTmFtZSI6Iui1tea0qua6kCJ9.qdZ3vB56evQgM8Ogt6WLpmpBXiS_GQh1-vK6cY5ew84',
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

                  final data = RSPrinterServiceParameter(
                    shopName: '还是啥哈市撒哈市撒谎萨哈萨哈',
                    guestCount: 3,
                    queueCount: 0,
                    queueDateTimeStr: '2025-07-19 18:30:00',
                    queueUpQR: 'https://www.baidu.com',
                    queueTypeName: '普通桌',
                    queueNum: 'A12',
                    printTime: DateFormat(
                      'yyyy-MM-dd HH:mm:ss',
                    ).format(DateTime.now()),
                  );

                  // 3. 调用打印
                  bool result = await RSPrinterService.printContent(
                    result2,
                    data,
                    paperSize: 58, // 默认58 80mm需后期兼容
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
