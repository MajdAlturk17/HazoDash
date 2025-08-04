import 'package:flutter/material.dart';
import 'package:hazodashborad/Features/widgets/CustomizSplash.dart';
import 'package:hazodashborad/Features/widgets/DashBoardBody.dart';
import 'package:hazodashborad/Features/widgets/sidebar.dart';
import 'package:hazodashborad/Features/widgets/user_table.dart';

const bgColor = Color(0xFFF5F6FA);
const sidebarColor = Color(0xFF192132);
const blueCard = Color(0xFF5B8DEF);
const purpleCard = Color(0xFFA85CF9);
const pinkCard = Color(0xFFFF6C8B);
const textMain = Color(0xFF192132);

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DashboardScreen(),
  ));
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  List<Map<String, dynamic>> pages = [
    {'icon': Icons.dashboard, 'label': 'Dashboard'},
    {'icon': Icons.people, 'label': 'Users'},
    {'icon': Icons.chat_bubble, 'label': 'Chat Rooms'},
    {'icon': Icons.business, 'label': 'Agencies'},
    {'icon': Icons.card_giftcard, 'label': 'Gifts'},
    {'icon': Icons.sports_kabaddi, 'label': 'PK Battles'},
    {'icon': Icons.report, 'label': 'Reports'},
    {'icon': Icons.workspace_premium, 'label': 'Memberships'},
    {'icon': Icons.star, 'label': 'Points System'},
    {'icon': Icons.announcement, 'label': 'Announcements'},
    {'icon': Icons.settings, 'label': 'Settings'},
    {'icon': Icons.edit, 'label': 'Customized Splash'},
  ];

  // هذه الدالة ستعيد الصفحة الصحيحة حسب الـ selectedIndex
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const DashboardPage();
      case 1:
        return const UserTable();
      case 2:
        return const ChatRoomsPage();
      case 3:
        return const AgenciesPage();
      case 4:
        return const GiftsPage();
      case 5:
        return const PKBattlesPage();
      case 6:
        return const ReportsPage();
      case 7:
        return const MembershipsPage();
      case 8:
        return const PointsSystemPage();
      case 9:
        return const AnnouncementsPage();
      case 10:
        return const SettingsPage();
              case 11:
        return const CustomSplash();
      default:
        return const Center(child: Text("Page Not Found"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Row(
        children: [
          // Sidebar - Dynamic!
          Sidebar(
            selectedIndex: selectedIndex,
            items: pages,
            onSelect: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Text(
                        pages[selectedIndex]['label'],
                        style: const TextStyle(
                          color: textMain,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade300,
                        ),
                        child: const Icon(Icons.person, color: textMain, size: 26),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Admin",
                        style: TextStyle(
                          color: textMain,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  // محتوى الصفحة
                  Expanded(child: _getPage(selectedIndex)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class UsersPage extends StatelessWidget {
  const UsersPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Users Page", style: TextStyle(fontSize: 22)));
  }
}
class ChatRoomsPage extends StatelessWidget {
  const ChatRoomsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Chat Rooms Page", style: TextStyle(fontSize: 22)));
  }
}
class AgenciesPage extends StatelessWidget {
  const AgenciesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Agencies Page", style: TextStyle(fontSize: 22)));
  }
}
class GiftsPage extends StatelessWidget {
  const GiftsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Gifts Page", style: TextStyle(fontSize: 22)));
  }
}
class PKBattlesPage extends StatelessWidget {
  const PKBattlesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("PK Battles Page", style: TextStyle(fontSize: 22)));
  }
}
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Reports Page", style: TextStyle(fontSize: 22)));
  }
}
class MembershipsPage extends StatelessWidget {
  const MembershipsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Memberships Page", style: TextStyle(fontSize: 22)));
  }
}
class PointsSystemPage extends StatelessWidget {
  const PointsSystemPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Points System Page", style: TextStyle(fontSize: 22)));
  }
}
class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Announcements Page", style: TextStyle(fontSize: 22)));
  }
}
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Settings Page", style: TextStyle(fontSize: 22)));
  }
}
