import 'dart:convert';
import 'package:hazodashborad/Core/res/Url.dart';
import 'package:http/http.dart' as http;
import 'package:hazodashborad/Core/res/Model/AdminPhoto.dart';
import 'package:path/path.dart';

class PhotoService {
  ///////// get photo
  Future<List<AdminPhoto>> getAllAdminPhotos(String token) async {
    final url = Uri.parse("${Url.baseUrl}/v1/api/admin/photos/all");

    final response = await http.get(
      url,
      headers: {
        // 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => AdminPhoto.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch photos: ${response.statusCode}");
    }
  }
/////////patchPhotoSelection
  Future<void> patchPhotoSelection({
    required String token,
    required int id,
    required bool selected,
  }) async {
    final url = Uri.parse(
      "${Url.baseUrl}/v1/api/admin/photos/$id/patch",
    ).replace(queryParameters: {"selected": selected.toString()});

    final response = await http.patch(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to update photo selection: ${response.statusCode} - ${response.body}",
      );
    }
    final data = jsonDecode(response.body);
    print("Photo updated: $data");
  }
}
