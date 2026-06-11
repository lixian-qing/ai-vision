import 'package:url_launcher/url_launcher.dart';
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
经度：\${position.longitude}
纬度：\${position.latitude}
""";

      // 使用 url_launcher 打开短信界面
      final smsUri = Uri(
        scheme: 'sms',
        path: emergencyPhone,
        queryParameters: {'body': content},
      );
      
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
