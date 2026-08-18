import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/trip.dart';
import '../providers/app_controller.dart';
import 'trip_planner_screen.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key, required this.controller});
  final AppController controller;
  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  late Future<List<Trip>> _trips;
  @override
  void initState() {
    super.initState();
    _trips = _loadTrips();
  }

  Future<List<Trip>> _loadTrips() async {
    try {
      final trips = await widget.controller.trips.listTrips();
      if (widget.controller.activeTrip != null && !trips.any((trip) => trip.id == widget.controller.activeTrip!.id)) return [widget.controller.activeTrip!, ...trips];
      return trips;
    } catch (_) => widget.controller.activeTrip == null ? [] : [widget.controller.activeTrip!];
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('My trips')),
        floatingActionButton: FloatingActionButton.extended(onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => CreateTripScreen(controller: widget.controller))); if (mounted) setState(() => _trips = _loadTrips()); }, icon: const Icon(Icons.add), label: const Text('Create trip')),
        body: FutureBuilder<List<Trip>>(
          future: _trips,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
            final trips = snapshot.data ?? [];
            if (trips.isEmpty) return const Center(child: Text('No trips yet. Create one to begin.'));
            return ListView.builder(padding: const EdgeInsets.all(16), itemCount: trips.length, itemBuilder: (context, index) {
              final trip = trips[index];
              return Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.landscape)), title: Text(trip.title), subtitle: Text('${trip.destination}\n${DateFormat.yMMMd().format(trip.startDate)} – ${DateFormat.MMMd().format(trip.endDate)}'), isThreeLine: true, trailing: const Icon(Icons.chevron_right), onTap: () { widget.controller.activeTrip = trip; Navigator.push(context, MaterialPageRoute(builder: (_) => TripPlannerScreen(controller: widget.controller, trip: trip))); }));
            });
          },
        ),
      );
}

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key, required this.controller});
  final AppController controller;
  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController(text: '5 Day Kerala Trip');
  final _destination = TextEditingController(text: 'Munnar, Kerala');
  final _budget = TextEditingController(text: '20000');
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(days: 4));
  bool _saving = false;

  @override
  void dispose() { _title.dispose(); _destination.dispose(); _budget.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    await widget.controller.createTrip(title: _title.text.trim(), destination: _destination.text.trim(), startDate: _start, endDate: _end, budget: double.parse(_budget.text));
    if (!mounted) return;
    setState(() => _saving = false);
    if (widget.controller.activeTrip != null) Navigator.pop(context);
  }

  Future<void> _chooseDate(bool start) async {
    final selected = await showDatePicker(context: context, initialDate: start ? _start : _end, firstDate: DateTime.now().subtract(const Duration(days: 1)), lastDate: DateTime.now().add(const Duration(days: 730)));
    if (selected == null) return;
    setState(() { if (start) { _start = selected; if (_end.isBefore(_start)) _end = _start; } else { _end = selected.isBefore(_start) ? _start : selected; } });
  }

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Create trip')), body: Form(key: _form, child: ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Tell SMART TRIP where you are going. You can refine preferences in the planner.', style: TextStyle(fontSize: 16)),
    const SizedBox(height: 20),
    TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Trip title'), validator: (value) => value == null || value.trim().length < 2 ? 'Enter a title' : null),
    const SizedBox(height: 12),
    TextFormField(controller: _destination, decoration: const InputDecoration(labelText: 'Destination'), validator: (value) => value == null || value.trim().length < 2 ? 'Enter a destination' : null),
    const SizedBox(height: 12),
    TextFormField(controller: _budget, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Budget (INR)', prefixText: '₹ '), validator: (value) => double.tryParse(value ?? '') == null || double.parse(value!) <= 0 ? 'Enter a valid budget' : null),
    const SizedBox(height: 12),
    Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () => _chooseDate(true), icon: const Icon(Icons.date_range), label: Text(DateFormat.yMMMd().format(_start)))), const SizedBox(width: 10), Expanded(child: OutlinedButton.icon(onPressed: () => _chooseDate(false), icon: const Icon(Icons.event), label: Text(DateFormat.yMMMd().format(_end))))]),
    const SizedBox(height: 24),
    FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Creating…' : 'Create trip')),
    if (widget.controller.error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(widget.controller.error!, style: const TextStyle(color: Color(0xFF9A5500)))),
  ])));
}

