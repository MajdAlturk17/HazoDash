import 'package:flutter/material.dart';

class RoomTable extends StatelessWidget {
  const RoomTable({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> rooms = [
      {"name": "Room Alpha", "status": "Active", "users": 25},
      {"name": "Room Beta", "status": "Inactive", "users": 10},
      {"name": "Room Gamma", "status": "Active", "users": 30},
      {"name": "Room Delta", "status": "Active", "users": 15},
      {"name": "Room Epsilon", "status": "Inactive", "users": 5},
    ];

    return Table(
      border: TableBorder.all(color: const Color(0xFF314d68)),
      columnWidths: const {
        0: FixedColumnWidth(180),
        1: FixedColumnWidth(100),
        2: FixedColumnWidth(80),
        3: FlexColumnWidth(),
      },
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Color(0xFF182634)),
          children: [
            TableCellWidget("Room Name", bold: true),
            TableCellWidget("Status", bold: true),
            TableCellWidget("Users", bold: true),
            TableCellWidget("Actions", bold: true, color: Color(0xFF90adcb)),
          ],
        ),
        ...rooms.map((room) {
          return TableRow(
            children: [
              TableCellWidget(room['name']),
              TableCellWidget(
                room['status'],
                isButton: true,
                color: room['status'] == "Active" ? Colors.white : Colors.white70,
                bgColor: const Color(0xFF223649),
              ),
              TableCellWidget(room['users'].toString(), color: const Color(0xFF90adcb)),
              const TableCellWidget("View", color: Color(0xFF90adcb), bold: true),
            ],
          );
        }).toList(),
      ],
    );
  }
}

class TableCellWidget extends StatelessWidget {
  final String text;
  final bool bold;
  final bool isButton;
  final Color? color;
  final Color? bgColor;

  const TableCellWidget(
    this.text, {
    super.key,
    this.bold = false,
    this.isButton = false,
    this.color,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Text(
      text,
      style: TextStyle(
        color: color ?? Colors.white,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontSize: 14,
      ),
      textAlign: TextAlign.left,
    );

    if (isButton) {
      child = Container(
        decoration: BoxDecoration(
          color: bgColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 18),
        child: child,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: child,
    );
  }
}
