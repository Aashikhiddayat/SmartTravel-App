import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../providers/app_controller.dart';
import '../widgets/status_banner.dart';

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key, required this.controller, required this.trip});
  final AppController controller;
  final Trip trip;
  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  Map<String, dynamic>? _result;
  bool _checking = false;
  Future<void> _check({bool enterDanger = false}) async {
    setState(() => _checking = true);
    try { _result = await widget.controller.api.post('/safety/check-location', {'trip_id': widget.trip.id, 'latitude': enterDanger ? 10.1185 : 10.0889, 'longitude': enterDanger ? 77.1025 : 77.0595}); } catch (error) { _result = {'status': 'error', 'message': error.toString()}; }
    if (mounted) setState(() => _checking = false);
  }
  Future<void> _route() async {
    try { final response = await widget.controller.api.post('/safety/safe-route', {'points': [[10.0889, 77.0595], [10.1185, 77.1025]]}); if (mounted) setState(() => _result = {'status': response['is_safer_route'] == true ? 'clear' : 'caution', 'message': response['recommendation']}); } catch (_) {}
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Safety map')), body: ListView(padding: const EdgeInsets.all(16), children: [
    const StatusBanner(message: 'DEMO ZONES — instructional only, not live government or emergency data.', color: Color(0xFF9A5500)), const SizedBox(height: 16),
    Card(color: const Color(0xFFE6F2EF), child: SizedBox(height: 200, child: Stack(children: [const Center(child: Icon(Icons.map_outlined, size: 86, color: Color(0xFF287E79))), Positioned(left: 75, top: 70, child: _ZoneDot(color: Colors.amber, label: 'Caution')), Positioned(right: 60, bottom: 45, child: _ZoneDot(color: const Color(0xFFAD2323), label: 'High risk'))]))),
    const SizedBox(height: 16),
    Text('Geofence simulation', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8),
    FilledButton.icon(onPressed: _checking ? null : () => _check(), icon: const Icon(Icons.my_location), label: const Text('Check current demo location')), const SizedBox(height: 8),
    OutlinedButton.icon(onPressed: _checking ? null : () => _check(enterDanger: true), icon: const Icon(Icons.warning_amber), label: const Text('Simulate approaching demo danger zone')), const SizedBox(height: 8), OutlinedButton.icon(onPressed: _route, icon: const Icon(Icons.alt_route), label: const Text('Check demo route')),
    if (_checking) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
    if (_result != null) Card(color: _result!['status'] == 'danger' ? const Color(0xFFFFE7E7) : const Color(0xFFFFF4DE), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text((_result!['status'] as String).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text(_result!['message'] as String)]))),
  ]));
}

class _ZoneDot extends StatelessWidget { const _ZoneDot({required this.color, required this.label}); final Color color; final String label; @override Widget build(BuildContext context) => Column(children: [CircleAvatar(radius: 16, backgroundColor: color, child: const Icon(Icons.warning, color: Colors.white, size: 18)), Text(label, style: const TextStyle(fontSize: 11))]); }

