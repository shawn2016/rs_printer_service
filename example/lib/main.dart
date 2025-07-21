import 'package:flutter/material.dart';
import 'dart:async';

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

              InkWell(
                onTap: () async {
                  //               final templateXml = """
                  // <root><receipt>
                  //   <row fontSize="normal" align="left" color="black" isBold="true">
                  //     <column type="TEXT">门店名称: 测试餐厅</column>
                  //   </row>
                  //   <row>
                  //     <column type="LINE" style="boldSolid"></column>
                  //   </row>
                  //   <row fontSize="normal" align="center">
                  //     <column type="QR_CODE" width="50%" high="50%">https://example.com/queue/12345</column>
                  //   </row>
                  // </receipt></root>
                  // """;

                  final templateXml = r"""<root><receipt><#if shopName??>
<row  fontSize="normal" align="left" color="black" isBold="true" isItalic="false">
<column type = "TEXT">门店名称:${shopName}</column>
</row> 
</#if>
<#if guestCount??>
<row  fontSize="normal" align="left" color="black" isBold="false" reverseBlackWhite="true" isItalic="false">
<column type = "TEXT">用餐人数:${guestCount}</column>
</row> 
</#if>
<row>
<column type = "LINE" style = "boldSolid"></column>
</row> 
<#if queueCount??>
<row  fontSize="normal" align="center" color="black" isBold="false" isItalic="false">
<column type = "TEXT">前方需等待桌数:${queueCount}</column>
</row> 
</#if>
<row>
<column type = "BLANK" fontSize="small" count = "1"></column>
</row> 
<#if queueDateTimeStr??>
<row  fontSize="normal" align="right" color="black" isBold="false" isItalic="false">
<column type = "TEXT">取号时间:${queueDateTimeStr}</column>
</row> 
</#if>

<#if true>
<row  fontSize="normal" align="center" color="black" isBold="false" isItalic="false">
<column type = "QR_CODE"  fontSize="normal" align="center" color="black" isBold="false" width="50%" high="50%" isItalic="false"  >${queueUpQR?default('')}</column>
</row>
</#if>

<#if queueNum??>
<row  fontSize="normal" align="left" color="black" isBold="false" isItalic="false">
<column type = "TEXT">桌台类型+排队号:<#if queueTypeName??>${queueTypeName}:</#if>${queueNum}</column>
</row>
</#if>

<row>
<column type = "LINE" style = "dotted"></column>
</row>
</receipt></root>""";

                  final data = <String, dynamic>{
                    'shopName': 'hello world',
                    'guestCount': 3,
                    'queueCount': 0,
                    'queueDateTimeStr': '2025-07-19 18:30',
                    'queueUpQR': 'https://example.com/qr/12345',
                    'queueTypeName': '普通桌',
                    'queueNum': 'A12',
                  };

                  // 3. 调用打印
                  bool result = await RSPrinterService.printTemplate(
                    templateXml,
                    data,
                    PrinterType.imin,
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
