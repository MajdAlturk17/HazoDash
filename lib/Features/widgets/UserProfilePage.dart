import 'package:flutter/material.dart';
import 'package:hazodashborad/Core/res/Model/UserProfile.dart';
import 'package:hazodashborad/Core/res/Service/UserService.dart';
import 'package:hazodashborad/Features/widgets/InfoRow.dart';


class UserProfilePage extends StatelessWidget {
  final int userId;
  final String token;

  const UserProfilePage({
    Key? key,
    required this.userId,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // خلفية dashboard فاتحة
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          "User Profile",
          style: TextStyle(
            color: Color(0xFF192132),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF192132)),
      ),
      body: FutureBuilder<UserProfile>(
        future: UserService().getUserProfile(userId, token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF5B8DEF),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            return Center(
              child: Card(
                color: Colors.white,
                elevation: 16,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                  side: const BorderSide(color: Color(0xFFE4E7EE), width: 2),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 38),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: const Color(0xFF5B8DEF).withOpacity(0.12),
                        backgroundImage: user.profilePictureUrl != null
                            ? NetworkImage(user.profilePictureUrl!)
                            : null,
                        child: user.profilePictureUrl == null
                            ? const Icon(Icons.person, size: 56, color: Color(0xFF5B8DEF))
                            : null,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          color: Color(0xFF192132),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        user.displayName ?? "",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                      Divider(height: 32, thickness: 1, color: Colors.grey[200]),
                      InfoRow(title: "Country", value: user.country),
                      const SizedBox(height: 12),
                      InfoRow(title: "Bio", value: user.bio),
                      const SizedBox(height: 12),
                      InfoRow(title: "Age", value: user.age.toString()),
                      const SizedBox(height: 12),
                      InfoRow(title: "Gender", value: user.gender),
                      const SizedBox(height: 28),
                      // أزرار الأكشن
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5B8DEF),
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                            label: const Text("Edit",
                                style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              // نافذة التعديل
                            },
                          ),
                          const SizedBox(width: 14),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6C8B),
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white),
                            label: const Text("Delete",
                                style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              // نافذة حذف
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(
              child: Text(
                "No user data found.",
                style: TextStyle(color: Color(0xFF90adcb)),
              ),
            );
          }
        },
      ),
    );
  }
}
