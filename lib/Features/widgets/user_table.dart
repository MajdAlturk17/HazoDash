import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hazodashborad/Core/res/Model/UserModel.dart';
import 'package:hazodashborad/Core/res/Service/UserService.dart';
import 'package:hazodashborad/Core/res/bloc/bloc/user_profile_bloc.dart';
import 'package:hazodashborad/Core/res/bloc/bloc/user_profile_event.dart';
import 'package:hazodashborad/Features/widgets/UserProfilePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserTable extends StatefulWidget {
  const UserTable({super.key});

  @override
  _UserTableState createState() => _UserTableState();
}

class _UserTableState extends State<UserTable> {
  Future<List<UserModel>>? futureUsers;
  String token = "";
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  bool _hasAdminRole(String? role) {
    if (role == null) return false;
    final r = role.toUpperCase();
    return r.contains('ADMIN'); // ADMIN أو SUPER_ADMIN
  }

  /// محاولة استخراج الدور من الـ JWT payload: { "role": "ADMIN" } مثلاً
  String? _decodeRoleFromToken(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final map = jsonDecode(payload) as Map<String, dynamic>;
      final role = map['role'] ?? map['authorities'] ?? map['roles'];
      if (role is String) return role;
      if (role is List && role.isNotEmpty) return role.first.toString();
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_value') ?? "";
    // لو عندك مفتاح للدور مخزن مسبقًا استعمله، وإلا جرّب نفك الـ JWT:
    String? rolePref = prefs.getString('user_role');
    rolePref ??= _decodeRoleFromToken(token);

    _isAdmin = _hasAdminRole(rolePref);

    if (token.isNotEmpty) {
      futureUsers = UserService().getAllUsers(token);
    } else {
      futureUsers = Future.value([]);
    }
    setState(() {});
  }

  void _confirmDelete(int userId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B8DEF).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: Color(0xFF5B8DEF),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Delete user?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF192132),
                      letterSpacing: -0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Are you sure you want to delete this user? This action cannot be undone.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF5B8DEF)),
                            foregroundColor: const Color(0xFF5B8DEF),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6C8B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            context.read<UserProfileBloc>().add(
                              DeleteUserProfile(userId: userId, token: token),
                            );
                            setState(() => _loadToken());
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 👇 BottomSheet لتغيير الدور
  void _openChangeRoleSheet(UserModel user) {
    final roles = const ['USER', 'ADMIN', 'SUPER_ADMIN'];
    String currentRole = (user.role ?? 'USER').toUpperCase();
    String tempRole = currentRole;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        bool saving = false;

        return StatefulBuilder(
          builder: (ctx, setM) {
            Future<void> save() async {
              if (tempRole == currentRole) {
                Navigator.pop(ctx);
                return;
              }
              setM(() => saving = true);
              try {
                final ok = await UserService().updateUserRole(
                  token: token,
                  userId: user.id!,
                  role: tempRole,
                );
                if (ok && mounted) {
                  Fluttertoast.showToast(
                    msg: "Role updated to $tempRole",
                    backgroundColor: Colors.green,
                  );
                  Navigator.pop(ctx);
                  // حدّث القائمة
                  setState(
                    () => futureUsers = UserService().getAllUsers(token),
                  );
                }
              } catch (e) {
                Fluttertoast.showToast(
                  msg: "Update failed: $e",
                  backgroundColor: Colors.red,
                );
                setM(() => saving = false);
              }
            }

            final bottom = MediaQuery.of(ctx).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 4,
                    width: 44,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    "Change Role",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      user.fullName ?? "User",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF192132),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: tempRole,
                    items: roles
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) => setM(() => tempRole = v ?? tempRole),
                    decoration: InputDecoration(
                      labelText: 'Role',
                      filled: true,
                      fillColor: const Color(0xFFF5F6FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE4E7EE)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE4E7EE)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF5B8DEF)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: saving ? null : save,
                      icon: saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.save_outlined,
                              color: Colors.white,
                            ),
                      label: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B8DEF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: futureUsers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF5B8DEF)),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final users = snapshot.data ?? [];
          if (users.isEmpty)
            return const Center(child: Text("No users found."));
          return ListView.separated(
            shrinkWrap: true,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName ?? "N/A",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Color(0xFF192132),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.email_outlined,
                                  size: 15,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  user.email ?? "N/A",
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  user.role ?? "N/A",
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Icon(
                                  Icons.phone_outlined,
                                  size: 15,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    (user.phoneNumber ?? "").isNotEmpty
                                        ? user.phoneNumber!
                                        : "Phone",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          // 👇 إذا أدمن: زر تغيير الدور، غير ذلك: زر العرض
                          if (user.role == "ADMIN")
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5B8DEF),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: const TextStyle(fontSize: 14),
                              ),
                              icon: const Icon(
                                Icons.manage_accounts,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Change Role",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () => _openChangeRoleSheet(user),
                            )
                          else
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5B8DEF),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: const TextStyle(fontSize: 14),
                              ),
                              icon: const Icon(
                                Icons.visibility,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "View",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UserProfilePage(
                                      userId: user.id!,
                                      token: token,
                                    ),
                                  ),
                                );
                              },
                            ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6C8B),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: const TextStyle(fontSize: 14),
                            ),
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () => _confirmDelete(user.id!),
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
