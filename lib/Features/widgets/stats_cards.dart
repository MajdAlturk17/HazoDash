import 'package:flutter/material.dart';

class StatsCards extends StatelessWidget {
  const StatsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: StatsCard(
            title: "Active Users",
            value: "1,234",
            change: "+12%",
            isPositive: true,
          ),
        ),
        SizedBox(width: 18),
        Expanded(
          child: StatsCard(
            title: "Room Activity",
            value: "567",
            change: "-5%",
            isPositive: false,
          ),
        ),
        SizedBox(width: 18),
        Expanded(
          child: StatsCard(
            title: "User Engagement",
            value: "89%",
            change: "+3%",
            isPositive: true,
          ),
        ),
      ],
    );
  }
}

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool isPositive;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = const Color(0xFF314d68);
    final Color bgColor = const Color(0xFF223649);

    return Container(
      height: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "Last 7 Days",
                style: TextStyle(color: Colors.blueGrey[200], fontSize: 15),
              ),
              const SizedBox(width: 8),
              Text(
                change,
                style: TextStyle(
                  color: isPositive ? const Color(0xFF0bda5b) : const Color(0xFFfa6238),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const Spacer(),
          // يمكن إضافة رسم بياني مصغر هنا أو SVG/صورة حسب الحاجة
          Container(
            height: 55,
            width: double.infinity,
            color: bgColor.withOpacity(0.5),
            alignment: Alignment.center,
            child: const Text("Analytics Chart", style: TextStyle(color: Colors.white38)),
          )
        ],
      ),
    );
  }
}
