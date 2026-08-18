import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../providers/app_controller.dart';
import '../widgets/status_banner.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key, required this.controller, required this.trip});
  final AppController controller;
  final Trip trip;
  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  List<Map<String, dynamic>>? _itinerary;
  String? _error;
  bool _loading = false;
  Future<void> _plan() async {
    setState(() { _loading = true; _error = null; });
    try { _itinerary = await widget.controller.trips.plan(widget.trip); } catch (error) { _error = error.toString(); }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('AI Trip Planner')), body: ListView(padding: const EdgeInsets.all(16), children: [
    const StatusBanner(message: 'Demo plans rank seeded facts. Verify places, prices, opening hours, routes, weather and emergency information before travel.'),
    const SizedBox(height: 14),
    Text(widget.trip.destination, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
    Text('Balanced • Vegetarian • Nature, Food, Photography • ₹${widget.trip.budget.toStringAsFixed(0)}'),
    const SizedBox(height: 18),
    FilledButton.icon(onPressed: _loading ? null : _plan, icon: const Icon(Icons.auto_awesome), label: Text(_loading ? 'Planning…' : 'Generate itinerary')),
    if (_error != null) Padding(padding: const EdgeInsets.all(12), child: Text(_error!, style: const TextStyle(color: Color(0xFF9A5500)))),
    if (_itinerary != null) ..._itinerary!.map((day) => Card(child: ExpansionTile(title: Text('Day ${day['day_number']} — ${day['summary']}'), children: (day['items'] as List<dynamic>).map((item) => ListTile(leading: Icon(item['category'] == 'food' ? Icons.restaurant : item['category'] == 'rest' ? Icons.self_improvement : Icons.place), title: Text('${item['start_time']}  ${item['title']}'), subtitle: Text('${item['notes']}\nEstimated ₹${item['estimated_cost']}'), isThreeLine: true)).toList()))),
  ]));
}
