import 'package:flutter/material.dart';

class StatusBanner extends StatelessWidget {
  const StatusBanner({super.key, required this.message, this.color = const Color(0xFF715B00)});
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(width: double.infinity, color: color.withOpacity(.12), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), child: Row(children: [Icon(Icons.info_outline, color: color), const SizedBox(width: 8), Expanded(child: Text(message, style: TextStyle(color: color, fontWeight: FontWeight.w600)))]));
}
