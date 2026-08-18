import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/app_controller.dart';
import '../widgets/status_banner.dart';
import 'assistant_screen.dart';
import 'budget_screen.dart';
import 'safety_screen.dart';
import 'trip_planner_screen.dart';
import 'trips_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final trip = controller.activeTrip;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Good journey', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      const Text('Your travel command centre'),
      const SizedBox(height: 16),
      if (controller.error != null) StatusBanner(message: controller.error!, color: const Color(0xFF9A5500)),
      if (trip == null) _NoTrip(onCreate: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateTripScreen(controller: controller)))) else ...[
        Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Icon(Icons.location_on, color: Color(0xFF287E79)), const SizedBox(width: 8), Expanded(child: Text(trip.destination, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 8),
          Text(trip.title),
          const SizedBox(height: 12),
          Text('${DateFormat.MMMd().format(trip.startDate)} – ${DateFormat.MMMd().format(trip.endDate)}  •  ${trip.currency} ${trip.budget.toStringAsFixed(0)} budget'),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TripPlannerScreen(controller: controller, trip: trip))), icon: const Icon(Icons.auto_awesome), label: const Text('Generate AI itinerary')),
        ])),
        const SizedBox(height: 10),
        Row(children: [Expanded(child: _QuickCard(icon: Icons.account_balance_wallet_outlined, title: 'Budget', subtitle: 'Track spending', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BudgetScreen(controller: controller, trip: trip))))), const SizedBox(width: 10), Expanded(child: _QuickCard(icon: Icons.shield_outlined, title: 'Safety', subtitle: 'Check location', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SafetyScreen(controller: controller, trip: trip)))))]),
        const SizedBox(height: 18),
        Text('Today', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const Card(child: ListTile(leading: Icon(Icons.event_note), title: Text('Your itinerary is ready to plan'), subtitle: Text('Generate a plan with verified-provider boundaries and demo fallbacks.'))),
      ],
      const SizedBox(height: 18),
      FilledButton.icon(style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)), onPressed: trip == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => AssistantScreen(controller: controller, trip: trip))), icon: const Icon(Icons.auto_awesome), label: const Text('Ask AI')),
      const SizedBox(height: 12),
      OutlinedButton.icon(style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFAD2323), minimumSize: const Size.fromHeight(52)), onPressed: trip == null ? null : () => _sos(context, trip.id), icon: const Icon(Icons.sos), label: const Text('SOS')),
    ]);
  }

  Future<void> _sos(BuildContext context, String tripId) async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Send SOS?'), content: const Text('SMART TRIP will prepare an emergency message with your current location. Confirm before continuing.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), style: FilledButton.styleFrom(backgroundColor: const Color(0xFFAD2323)), child: const Text('Prepare SOS'))]));
    if (confirmed != true || !context.mounted) return;
    try {
      final response = await controller.api.post('/emergency/sos', {'trip_id': tripId, 'latitude': 10.0889, 'longitude': 77.0595, 'share_location': true});
      if (context.mounted) showDialog<void>(context: context, builder: (context) => AlertDialog(title: const Text('SOS prepared'), content: Text('${response['message']}\n\n${response['notice']}'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))]));
    } catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not prepare SOS: $error')));
    }
  }
}

class _NoTrip extends StatelessWidget {
  const _NoTrip({required this.onCreate});
  final VoidCallback onCreate;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.luggage, size: 42, color: Color(0xFF287E79)), const SizedBox(height: 12), Text('Start your next journey', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8), const Text('Create a trip to plan an itinerary, manage a budget, explore recommendations and build memories.'), const SizedBox(height: 18), FilledButton(onPressed: onCreate, child: const Text('Create trip'))])));
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(child: InkWell(borderRadius: BorderRadius.circular(18), onTap: onTap, child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: const Color(0xFF287E79)), const SizedBox(height: 16), Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(subtitle, style: Theme.of(context).textTheme.bodySmall)]))));
}

