/// 参数模型类，用于表示打印队列的参数
class RSPrinterServiceParameter {
  /// 店铺名称
  final String? shopName;

  /// 客人数量
  final int? guestCount;

  /// 队列数量
  final int? queueCount;

  /// 队列日期时间字符串
  final String? queueDateTimeStr;

  /// 排队二维码链接
  final String? queueUpQR;

  /// 队列类型名称
  final String? queueTypeName;

  /// 队列编号
  final String? queueNum;

  /// 打印时间
  final String? printTime;

  /// 构造函数
  RSPrinterServiceParameter({
    this.shopName,
    this.guestCount,
    this.queueCount,
    this.queueDateTimeStr,
    this.queueUpQR,
    this.queueTypeName,
    this.queueNum,
    this.printTime,
  });
  bool containsKey(String key) {
    return getValue(key) != null;
  }

  dynamic getValue(String key) {
    switch (key) {
      case 'shopName':
        return shopName;
      case 'guestCount':
        return guestCount;
      case 'queueCount':
        return queueCount;
      case 'queueDateTimeStr':
        return queueDateTimeStr;
      case 'queueUpQR':
        return queueUpQR;
      case 'queueTypeName':
        return queueTypeName;
      case 'queueNum':
        return queueNum;
      case 'queueNum':
        return queueNum;
      case 'printTime':
        return printTime;
      default:
        return null;
    }
  }



  /// 从 JSON 数据创建 RSPrinterServiceParameter 实例
  factory RSPrinterServiceParameter.fromJson(Map<String, dynamic> json) {
    return RSPrinterServiceParameter(
      shopName: json['shopName'] as String?,
      guestCount: json['guestCount'] as int?,
      queueCount: json['queueCount'] as int?,
      queueDateTimeStr: json['queueDateTimeStr'] as String?,
      queueUpQR: json['queueUpQR'] as String?,
      queueTypeName: json['queueTypeName'] as String?,
      queueNum: json['queueNum'] as String?,
      printTime: json['printTime'] as String?,
    );
  }

  /// 将 RSPrinterServiceParameter 实例转换为 JSON 数据
  Map<String, dynamic> toJson() {
    return {
      'shopName': shopName,
      'guestCount': guestCount,
      'queueCount': queueCount,
      'queueDateTimeStr': queueDateTimeStr,
      'queueUpQR': queueUpQR,
      'queueTypeName': queueTypeName,
      'queueNum': queueNum,
      'printTime': printTime,
    };
  }
}
