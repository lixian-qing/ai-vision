import 'package:vibration/vibration.dart';

class VibrateService {
  // 连续震动（危险提示）
  static Future<void> dangerVibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      // 震动模式：震动500ms，暂停300ms，循环3次
      Vibration.vibrate(
        pattern: [500, 300, 500, 300, 500],
        repeat: -1,
      );
      // 2秒后停止震动
      Future.delayed(const Duration(seconds: 2), () {
        Vibration.cancel();
      });
    }
  }
}