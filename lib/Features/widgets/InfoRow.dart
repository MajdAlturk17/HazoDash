// يمكنك نقل هذا إلى ملف منفصل إذا أردت
import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final String title;
  final String value;
  const InfoRow({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("$title: ",
          style: const TextStyle(
            color: Color(0xFF5B8DEF),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF192132),
              fontSize: 17,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
