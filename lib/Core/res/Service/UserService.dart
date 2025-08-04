import 'dart:convert';

import 'package:hazodashborad/Core/res/Model/UserProfile.dart';
import 'package:hazodashborad/Core/res/Url.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = '${Url.baseUrl}/v1/api/user-profile/';

  Future<List<UserProfile>> getAllUsers(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl+"admin/all"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',

      },
    );
  print("Response status: ${response.statusCode}"); // طباعة حالة الاستجابة
  print("Response body: ${response.body}"); // طباعة جسم الاستجابة
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      print(response.body+"Body");
      return jsonResponse.map((user) => UserProfile.fromJson(user)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }
  /////////// User Profile
   Future<UserProfile> getUserProfile(int id, String token) async {
    final url = Uri.parse('$baseUrl$id');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      // تحليل الاستجابة إلى نموذج UserProfile
      print(response.body);
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return UserProfile.fromJson(jsonResponse); // استخدام نفس نموذج UserProfile
    } else {
      throw Exception('Failed to load user profile: ${response.statusCode}');
    }
  }
  /////////
 Future<bool> deleteUser(int id, String token) async {
    final url = Uri.parse('$baseUrl${'su/'}$id');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true; // تم الحذف بنجاح
    } else {
      // يمكنك معالجة الأخطاء هنا
      print('Error: ${response.statusCode} - ${response.body}');
      return false; // فشل الحذف
    }
 }
}