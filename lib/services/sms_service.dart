import 'package:flutter_sms/flutter_sms.dart';
import 'package:geolocator/geolocator.dart';

class SmsService {
  // 预设求助联系人手机号（自行修改）
  static const String emergencyPhone = "13800138000";

  // 获取当前位置 + 发送求助短信
  static Future<bool> sendHelpSms() async {
    try {
      // 获取经纬度位置
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String content = """
【AI视界紧急求助】
我现在遇到危险，请尽快赶来！
当前位置：
经度：${position.longitude}
纬度：${position.latitude}
""";

      // 发送短信
      await sendSMS(
        message: content,
        recipients: [emergencyPhone],
        sendDirect: true, // 直接发送，不跳转短信界面
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}