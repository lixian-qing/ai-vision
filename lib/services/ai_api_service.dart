import 'dart:convert';
import 'package:dio/dio.dart';

class AiApiService {
  // ========== 请替换为你自己的文心一言 API 密钥 ==========
  static const String apiKey = "你的文心一言API_KEY";
  static const String secretKey = "你的文心一言SECRET_KEY";
  // =====================================================

  static final Dio _dio = Dio();
  static String? _accessToken;

  // 1. 获取文心一言 AccessToken
  static Future<String?> _getAccessToken() async {
    if (_accessToken != null) return _accessToken;
    try {
      final res = await _dio.post(
        "https://aip.baidubce.com/oauth/2.0/token",
        queryParameters: {
          "grant_type": "client_credentials",
          "client_id": apiKey,
          "client_secret": secretKey,
        },
      );
      final data = res.data;
      _accessToken = data["access_token"];
      return _accessToken;
    } catch (e) {
      return null;
    }
  }

  // 2. 调用文心一言检测短信是否为诈骗/危险内容
  // 返回值：true=危险  false=安全
  static Future<bool> checkSmsContent(String content) async {
    final token = await _getAccessToken();
    if (token == null) return false;

    final prompt = """
请检测以下短信内容是否为诈骗、钓鱼、危险信息。
仅回复【安全】或【危险】两个字，不要多余内容。
短信内容：$content
""";

    try {
      final res = await _dio.post(
        "https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/completions",
        queryParameters: {"access_token": token},
        data: {
          "messages": [
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.1,
        },
      );

      final String result = res.data["result"] ?? "";
      return result.contains("危险");
    } catch (e) {
      return false;
    }
  }
}