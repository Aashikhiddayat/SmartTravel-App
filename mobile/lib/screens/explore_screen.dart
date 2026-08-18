import 'package:flutter/material.dart';

import '../models/place.dart';
import '../providers/app_controller.dart';
import '../widgets/status_banner.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, required this.controller});
  final AppController controller;
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String? _category;
  late Future<List<PlaceRecommendation>> _places;
  @override
  void initState() { super.initState(); _places = widget.controller.trips.nearby(); }
  void _setCategory(String? category) => setState(() { _category = category; _places = widget.controller.trips.nearby(category: category); });

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Explore')), body: Column(children: [
    const StatusBanner(message: 'Map data uses a configurable provider. The list below is clearly marked demo data.'),
    SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(12), child: Row(children: [for (final item in const <(String, String?)>[('All', null), ('Food', 'food'), ('Stay', 'stay'), ('Attractions', 'attraction'), ('Essentials', 'essential')]) Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(item.$1), selected: _category == item.$2, onSelected: (_) => _setCategory(item.$2)))])),
    Expanded(child: FutureBuilder<List<PlaceRecommendation>>(future: _places, builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError) return Center(child: Text('Could not load recommendations: ${snapshot.error}'));
      return ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: snapshot.data!.length, itemBuilder: (context, index) { final place = snapshot.data![index]; return Card(child: ListTile(leading: CircleAvatar(child: Icon(_iconFor(place.category))), title: Text(place.name), subtitle: Text('${place.address}\n${place.reason}'), isThreeLine: true, trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('★ ${place.rating}'), Text('${place.distanceMeters}m', style: Theme.of(context).textTheme.bodySmall)]), onTap: () => _details(context, place))); });
    })),
  ]));

  IconData _iconFor(String category) => switch (category) { 'food' => Icons.restaurant, 'stay' => Icons.hotel, 'essential' => Icons.local_hospital, _ => Icons.park };
  void _details(BuildContext context, PlaceRecommendation place) => showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (context) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(place.name, style: Theme.of(context).textTheme.titleLarge), Text('Score ${place.score.toStringAsFixed(1)} • ${'₹' * place.priceLevel}'), const SizedBox(height: 12), Text(place.reason), const SizedBox(height: 10), Text('Pros: ${place.pros.join(' • ')}'), Text('Concerns: ${place.cons.join(' • ')}'), const SizedBox(height: 18), const StatusBanner(message: 'Verify all live details with the venue or approved provider before travel.'), const SizedBox(height: 8)])));
}

