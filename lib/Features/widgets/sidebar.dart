// Sidebar Widget - dynamic navigation
import 'package:flutter/material.dart';
import 'package:hazodashborad/dashboard_screen.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final List<Map<String, dynamic>> items;
  final Function(int) onSelect;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: sidebarColor,
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: blueCard,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mic, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                "Hazo",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              )
            ],
          ),
          const SizedBox(height: 36),
          // Sidebar Navigation
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                return _SidebarItem(
                  icon: items[i]['icon'],
                  label: items[i]['label'],
                  selected: selectedIndex == i,
                  onTap: () => onSelect(i),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: selected
          ? BoxDecoration(
              color: const Color(0xFF314d68),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: ListTile(
        leading: Icon(icon, color: Colors.white.withOpacity(selected ? 1 : 0.8)),
        title: Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(selected ? 1 : 0.8),
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        onTap: onTap,
      ),
    );
  }
}

