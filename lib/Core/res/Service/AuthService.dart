import 'dart:convert';
import 'package:hazodashborad/Core/res/Url.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl = '${Url.baseUrl}/v1/api/auth';


  String? _extractRoleFromJwt(String jwt) {
    try {
      final raw = jwt.startsWith('Bearer ')
          ? jwt.substring(7).trim()
          : jwt.trim();

      final parts = raw.split('.');
      if (parts.length != 3) return null;

      String payloadB64 = parts[1];
      while (payloadB64.length % 4 != 0) {
        payloadB64 += '=';
      }
      final payloadMap = json.decode(utf8.decode(base64Url.decode(payloadB64)));

      if (payloadMap['role'] != null) return payloadMap['role'].toString();

      if (payloadMap['roles'] is List &&
          (payloadMap['roles'] as List).isNotEmpty) {
        return payloadMap['roles'][0].toString();
      }

      if (payloadMap['authorities'] is List &&
          (payloadMap['authorities'] as List).isNotEmpty) {
        return payloadMap['authorities'][0].toString();
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/login');

    final body = jsonEncode({'email': email, 'password': password});

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

    print("Response Body: ${response.body}");
    print("Response status: ${response.statusCode}");

    if (response.statusCode == 200) {
      if (response.body.startsWith('token:')) {
        var token = response.body.split(':')[1].trim();

        // استخرج الدور
        final role = _extractRoleFromJwt(token);
        final isAdmin = (role ?? '').toUpperCase().contains('ADMIN');

        print("Role: $role | is_admin: $isAdmin");
        if (!isAdmin) {
          throw Exception("Access denied: Admins only.");
        }


        await _storeToken(token);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', role ?? '');
        await prefs.setBool('is_admin', isAdmin);

        print("Token stored: $token");
        print("Role: $role | is_admin: $isAdmin");

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
