import 'dart:convert';
import 'package:hazodashborad/Core/res/Url.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl = '${Url.baseUrl}/v1/api/auth';

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/login');

    // إنشاء الجسم
    final body = jsonEncode({
      'email': email,
      'password': password,
    });

    // طباعة الجسم قبل الإرسال
    print("Request Body: $body");
    print("Request URL: $url");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body,
    );

    // طباعة الاستجابة للتحقق منها
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      // إذا كانت الاستجابة نصًا غير صالح لـ JSON
      if (response.body.startsWith('token:')) {
        final String token = response.body.split(':')[1].trim(); // استخراج التوكن
        await _storeToken(token); // تخزين التوكن
        print("Token stored: $token");
        return token;
      } else {
        throw Exception('Unexpected response format: ${response.body}');
      }
    } else {
      print("Login Error: ${response.statusCode}");
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_value', token); // تخزين التوكن بدون أي نص إضافي
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_value'); // استخدام المفتاح الصحيح
  }
}