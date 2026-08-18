import 'package:flutter/material.dart';

import '../providers/app_controller.dart';
import '../widgets/status_banner.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.controller});
  final AppController controller;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Profile')), body: ListView(padding: const EdgeInsets.all(16), children: [
    const CircleAvatar(radius: 34, child: Icon(Icons.person, size: 36)), const SizedBox(height: 12), const Center(child: Text('SMART TRIP traveller', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))), const SizedBox(height: 20),
    const StatusBanner(message: 'Privacy controls are enforced by Supabase RLS in production. Demo-mode data is local and instructional.'), const SizedBox(height: 12),
    const Card(child: Column(children: [ListTile(leading: Icon(Icons.tune), title: Text('Travel preferences'), subtitle: Text('Balanced • Vegetarian • Nature, Food, Photography')), Divider(height: 1), ListTile(leading: Icon(Icons.contact_emergency_outlined), title: Text('Emergency contacts'), subtitle: Text('Add contacts before travel'))])),
    const SizedBox(height: 12),
    Card(child: Column(children: [SwitchListTile(value: false, onChanged: null, title: const Text('Location tracking'), subtitle: const Text('Requested contextually; disabled by default')), SwitchListTile(value: false, onChanged: null, title: const Text('Photo sharing'), subtitle: const Text('Private by default')), SwitchListTile(value: true, onChanged: null, title: const Text('Group sharing'), subtitle: const Text('Control shared timeline and expenses'))])),
    const SizedBox(height: 16),
    OutlinedButton.icon(onPressed: () => _privacy(context), icon: const Icon(Icons.privacy_tip_outlined), label: const Text('Privacy settings & data export')), const SizedBox(height: 8),
    OutlinedButton.icon(style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF9A5500)), onPressed: () async { await controller.signOut(); }, icon: const Icon(Icons.logout), label: const Text('Log out')),
  ]));

  void _privacy(BuildContext context) => showDialog<void>(context: context, builder: (context) => AlertDialog(title: const Text('Privacy and deletion'), content: const Text('In production, you can disable location use, delete a trip, delete photos, remove contacts, manage sharing, or request account deletion. Export trip JSON and photo lists before deleting. Never log detailed GPS history unnecessarily.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))]));
}

