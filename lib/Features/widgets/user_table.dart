import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // إضافة
import 'package:hazodashborad/Core/res/Model/UserProfile.dart';
import 'package:hazodashborad/Core/res/Service/UserService.dart';
import 'package:hazodashborad/Features/widgets/UserProfilePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserTable extends StatefulWidget {
  const UserTable({super.key});

  @override
  _UserTableState createState() => _UserTableState();
}

class _UserTableState extends State<UserTable> {
  Future<List<UserProfile>>? futureUsers;
  String token = "";

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_value') ?? "";
    if (token.isNotEmpty) {
      futureUsers = UserService().getAllUsers(token);
      setState(() {});
    } else {
      futureUsers = Future.value([]);
      setState(() {});
    }
  }

  Future<void> _deleteUser(int userId) async {
    final userService = UserService();
    final success = await userService.deleteUser(userId, token);
    if (success) {
      Fluttertoast.showToast(
        msg: "User deleted successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      // إعادة تحميل المستخدمين بعد الحذف
      _loadToken();
    } else {
      Fluttertoast.showToast(
        msg: "Failed to delete user",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserProfile>>(
      future: futureUsers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
            color: Color(0xFF5B8DEF),
          ));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final users = snapshot.data!;
          if (users.isEmpty) {
            return const Center(child: Text("No users found."));
          }
          return ListView.separated(
            shrinkWrap: true,
            // physics: const NeverScrollableScrollPhysics(),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) {
              final user = users[i];
              return Card(
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: Color(0xFFF5F6FA)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  child: Row(
                    children: [
                      // صورة البروفايل أو أيقونة افتراضية
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFF5B8DEF).withOpacity(0.13),
                        backgroundImage: user.profilePictureUrl != null
                            ? NetworkImage(user.profilePictureUrl!)
                            : null,
                        child: user.profilePictureUrl == null
                            ? const Icon(Icons.person, size: 32, color: Color(0xFF5B8DEF))
                            : null,
                      ),
                      const SizedBox(width: 18),
                      // بيانات المستخدم
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.displayName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Color(0xFF192132))),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.flag, size: 15, color: Colors.grey[500]),
                                const SizedBox(width: 3),
                                Text(
                                  user.country,
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 13),
                                ),
                                const SizedBox(width: 15),
                                Icon(Icons.info_outline, size: 15, color: Colors.grey[500]),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    user.bio.isNotEmpty ? user.bio : "No Bio",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // الأزرار
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5B8DEF),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: const TextStyle(fontSize: 14),
                            ),
                            icon: const Icon(Icons.visibility, size: 18, color: Colors.white),
                            label: const Text("View",
                                style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UserProfilePage(userId: user.id, token: token),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6C8B),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: const TextStyle(fontSize: 14),
                            ),
                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white),
                            label: const Text("Delete",
                                style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              _deleteUser(user.id); // تنفيذ حذف المستخدم
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}