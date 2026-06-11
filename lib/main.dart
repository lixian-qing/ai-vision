import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化申请所有必要权限
  await _requestAllPermissions();
  runApp(const MyApp());
}

// 统一申请APP所需全部权限
Future<void> _requestAllPermissions() async {
  await [
    Permission.microphone,
    Permission.sms,
    Permission.location,
    Permission.videos,
    Permission.audio,
  ].request();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI视界',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}