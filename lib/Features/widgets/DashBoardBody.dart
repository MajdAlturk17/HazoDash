// --- صفحات وهمية لكل case ---
// يمكنك استبدال كل واحدة لاحقاً بملف حقيقي أو Widget حقيقي
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Dashboard Content", style: TextStyle(fontSize: 22)));
  }
}