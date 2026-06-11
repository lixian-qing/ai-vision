import 'package:vibration/vibration.dart';

class VibrateService {
  static Future<void> dangerVibrate() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator ?? false) {
      Vibration.vibrate(
        pattern: [500, 300, 500, 300, 500],
        repeat: -1,
      );
      Future.delayed(const Duration(seconds: 2), () {
        Vibration.cancel();
      });
    }
  }
}
