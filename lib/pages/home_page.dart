import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ai_api_service.dart';
import '../services/speech_service.dart';
import '../services/vibrate_service.dart';
import '../services/sms_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();
  String _resultText = "等待检测...";
  Color _resultColor = Colors.black;
  bool _isListening = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "AI视界 - 无障碍安全防护",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              minLines: 4,
              maxLines: 6,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(
                labelText: "请粘贴/输入可疑短信内容",
                labelStyle: TextStyle(fontSize: 18),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(15),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 80,
                    child: ElevatedButton(
                      onPressed: _toggleListen,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isListening ? Colors.red : Colors.green,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                      child: Text(
                        _isListening ? "停止录音" : "语音输入",
                        style: const TextStyle(fontSize: 22, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: SizedBox(
                    height: 80,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _checkSms,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "安全检测",
                              style: TextStyle(fontSize: 22, color: Colors.white),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                _resultText,
                style: TextStyle(
                  fontSize: 24,
                  color: _resultColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onLongPress: () async {
                setState(() {
                  _resultText = "正在发送紧急求助...";
                  _resultColor = Colors.orange;
                });
                bool res = await SmsService.sendHelpSms();
                if (res) {
                  setState(() {
                    _resultText = "求助短信发送成功！";
                    _resultColor = Colors.green;
                  });
                  await SpeechService.speak("紧急求助短信已发送");
                } else {
                  setState(() {
                    _resultText = "求助短信发送失败，请检查权限";
                    _resultColor = Colors.red;
                  });
                  await SpeechService.speak("求助短信发送失败");
                }
              },
              child: SizedBox(
                height: 120,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  child: const Text(
                    "SOS 紧急求助\n(长按3秒发送)",
                    style: TextStyle(fontSize: 28, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleListen() {
    if (_isListening) {
      SpeechService.stopListen();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      SpeechService.startListen(
        onResult: (text) {
          setState(() {
            _textController.text = text;
          });
        },
        onStop: () {
          setState(() => _isListening = false);
        },
      );
    }
  }

  Future<void> _checkSms() async {
    String content = _textController.text.trim();
    if (content.isEmpty) {
      setState(() {
        _resultText = "请输入短信内容！";
        _resultColor = Colors.orange;
      });
      await SpeechService.speak("请输入短信内容");
      return;
    }

    setState(() {
      _isLoading = true;
      _resultText = "正在AI检测中...";
      _resultColor = Colors.black;
    });

    bool isDanger = await AiApiService.checkSmsContent(content);

    if (isDanger) {
      setState(() {
        _resultText = "检测为【危险/诈骗短信】";
        _resultColor = Colors.red;
      });
      VibrateService.dangerVibrate();
      await SpeechService.speak("警告，检测到危险诈骗短信，请不要相信");
    } else {
      setState(() {
        _resultText = "检测为【安全短信】";
        _resultColor = Colors.green;
      });
      await SpeechService.speak("短信检测安全，可以放心");
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _textController.dispose();
    SpeechService.stopListen();
    SpeechService.stopSpeak();
    super.dispose();
  }
}
