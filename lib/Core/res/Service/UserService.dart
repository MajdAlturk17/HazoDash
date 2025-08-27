import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:hazodashborad/Core/res/Model/AdminUser.dart';
import 'package:hazodashborad/Core/res/Model/UserModel.dart';
import 'package:hazodashborad/Core/res/Model/UserProfile.dart';
import 'package:hazodashborad/Core/res/Url.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

class UserService {
  final String baseUrl = '${Url.baseUrl}/v1/api/';

  Future<List<UserModel>> getAllUsers(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl${"admin/users/all"}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    print(baseUrl);
    print("Response status: ${response.statusCode}"); // طباعة حالة الاستجابة
    print("Response body: ${response.body}"); // طباعة جسم الاستجابة
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      print(response.body + "Body");
      return jsonResponse.map((user) => UserModel.fromJson(user)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  /////////updateUserRole
  Future<bool> updateUserRole({
    required String token,
    required int userId,
    required String role, // USER | ADMIN | SUPER_ADMIN ...
  }) async {
    final url = Uri.parse("$baseUrl${"admin/users/"}$userId/patch");
    final res = await http.patch(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"role": role}),
    );
    if (res.statusCode == 200) return true;
    throw Exception("Update role failed: ${res.statusCode} - ${res.body}");
  }

  /////////// User Profile
  Future<UserProfile> getUserProfile(int id, String token) async {
    final url = Uri.parse('$baseUrl${'user-profile/'}$id');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    print(url);
    print(baseUrl);
    print("Response status: ${response.statusCode}"); // طباعة حالة الاستجابة
    print("Response body: ${response.body}"); // طباعة جسم الاستجابة
    if (response.statusCode == 200) {
      // تحليل الاستجابة إلى نموذج UserProfile
      print(response.body);
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return UserProfile.fromJson(
        jsonResponse,
      ); // استخدام نفس نموذج UserProfile
    } else {
      throw Exception('Failed to load user profile: ${response.statusCode}');
    }
  }

  /////////delet user
  Future<bool> deleteUser(int id, String token) async {
    final url = Uri.parse('$baseUrl${'user-profile/su/'}$id');
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

  ////////patchUserProfile
  Future<UserProfile> patchUserProfile({
    required int userId,
    required String token,
    String? displayName,
    String? country,
    String? bio,
    int? age,
    String? gender,
  }) async {
    final uri = Uri.parse('$baseUrl${'admin/user-profile'}/$userId/patch');

    // نبني الـ body ونشيل أي قيم null أو نصوص فاضية
    final Map<String, dynamic> body = {
      if (displayName != null && displayName.trim().isNotEmpty)
        'displayName': displayName.trim(),
      if (country != null && country.trim().isNotEmpty)
        'country': country.trim(),
      if (bio != null && bio.trim().isNotEmpty) 'bio': bio.trim(),
      if (age != null) 'age': age,
      if (gender != null && gender.trim().isNotEmpty) 'gender': gender.trim(),
    };

    final resp = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );
    print(uri);
    print(resp.body);
    print(resp.statusCode);
    print(body);
    if (resp.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(resp.body));
    } else if (resp.statusCode == 204) {
      return await getUserProfile(userId, token);
    } else {
      throw Exception('Patch failed: ${resp.statusCode} ${resp.body}');
    }
  }

  /// رفع عدّة صور من Uint8List (للويب)
  Future<dynamic> uploadPhotosBytes({
    required String token,
    required List<Uint8List> bytesList,
    String fieldName =
        'photos[]', // غيّرها لـ 'photos' إذا الباك-إند يتوقعها بدون []
  }) async {
    final uri = Uri.parse('$baseUrl${'admin/photos/new/list'}');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Accept'] = 'application/json';

    for (int i = 0; i < bytesList.length; i++) {
      final bytes = bytesList[i];
      final mime =
          lookupMimeType('', headerBytes: bytes) ?? 'application/octet-stream';
      final parts = mime.split('/');
      final type = parts.first;
      final subType = parts.length > 1 ? parts[1] : 'bin';
      final filename = 'image_$i.$subType';

      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: filename,
          contentType: http.MediaType(type, subType),
        ),
      );
    }

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return resp.body.isNotEmpty ? jsonDecode(resp.body) : null;
    }
    throw Exception('Upload failed: ${resp.statusCode} ${resp.body}');
  }

  ////////////createUser
  Future<AdminUser> createUser({
    required String token,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String role,
    required String password,
  }) async {
    final uri = Uri.parse("${baseUrl}auth/su/create");

    final body = jsonEncode({
      "fullName": fullName,
      "email": email,
      "phoneNumber": phoneNumber,
      "role": role,
      "password": password,
    });
    final res = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: body,
    );
    print(role);
    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      return AdminUser.fromJson(data);
    } else {
      throw Exception("Create user failed: ${res.statusCode} - ${res.body}");
    }
  }
}
