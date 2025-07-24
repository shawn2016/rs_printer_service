# RSPrinterService Flutter 插件使用指南

## 功能概述

本插件提供餐厅排队打印服务功能，包括：

- 打印机初始化
- 打印队列小票
- 错误处理

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  rs_printer_service: ^0.0.1
```

## 项目引入

```dart
rs_printer_service:
    version: ^0.0.1
    hosted:
        name: rs_printer_service
        url: https://pub.restosuite.cn/
```

## 头文件引入

```dart
import 'package:rs_printer_service/rs_printer_service.dart';
```

## 基本用法

### 1. 初始化打印机

```dart
// 初始化打印机
final bool initSuccess = await RSPrinterService.initPrinter();
if (!initSuccess) {
  print('打印机初始化失败');
  return;
}
```

### 2. 打印队列小票

```dart
// 打印队列小票
final params = RSPrinterServiceParameter(
  shopName: "测试店铺", // 门店名称
  guestCount: 2, // 用餐数量
  queueCount: 5, // 前方等待桌数
  queueDateTimeStr: "2023-10-01 12:00", // 取号时间
  queueUpQR: "https://example.com/qr", // 排队进程查看码
  queueTypeName: "普通队列", // 桌台类型
  queueNum: "A001", // 排队号
  printTime: "2023-10-01 12:05", // 打印时间
);

await RSPrinterService.printQueue(params);
```

## 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:rs_printer_service/rs_printer_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('打印服务示例')),
        body: Center(
          child: ElevatedButton(
            child: Text('打印测试'),
            onPressed: () async {
              final initSuccess = await RSPrinterService.initPrinter();
              if (!initSuccess) return;

              final params = RSPrinterServiceParameter(
                // 参数配置
                  shopName: "测试店铺", // 门店名称
  guestCount: 2, // 用餐数量
  queueCount: 5, // 前方等待桌数
  queueDateTimeStr: "2023-10-01 12:00", // 取号时间
  queueUpQR: "https://example.com/qr", // 排队进程查看码
  queueTypeName: "普通队列", // 桌台类型
  queueNum: "A001", // 排队号
  printTime: "2023-10-01 12:05", // 打印时间
              );

              try {
                await RSPrinterService.printQueue(params);
                print('打印成功');
              } catch (e) {
                print('打印失败: $e');
              }
            },
          ),
        ),
      ),
    );
  }
}
```
# 目前支持打印机
- imin 1.0.0+2.0.0
  - Swift 1 // 打印机类型
- sunmi
  - Qbao h1
  - sunmi v2s
  - sunmi v2s plus
# 注意事项

### local_packages/imin_printer-0.6.13

> 这个只改了一个文件,
> Swift 1 打印机使用黑底白字（printAntiWhiteText）时多输出一个换行符（sdk 1.0.0 存在 2.0.0 不存在）
> 已提出 issue，等待官方修复 [https://github.com/iminsoftware/imin_printer/issues/24]

```java
  case "printAntiWhiteText":
                String whiteText = call.argument("text");
                if (iminPrintUtils != null) {
                    if(sdkVersion.equals("1.0.0")) {
                        iminPrintUtils.printAntiWhiteText(whiteText);
                    } else {
                        iminPrintUtils.printAntiWhiteText(whiteText + "\n");
                    }
                }
                result.success(true);
                break;
```
