# rs_printer_service

### local_packages/imin_printer-0.6.13
> 这个只改了一个文件,
> Swift 1 打印机使用黑底白字（printAntiWhiteText）时多输出一个换行符（sdk 1.0.0存在 2.0.0 不存在）
> 已提出issue，等待官方修复 [https://github.com/iminsoftware/imin_printer/issues/24]
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