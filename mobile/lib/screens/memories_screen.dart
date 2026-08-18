import 'package:flutter/material.dart';

import '../providers/app_controller.dart';
import '../widgets/status_banner.dart';

class MemoriesScreen extends StatelessWidget {
  const MemoriesScreen({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final trip = controller.activeTrip;
    return Scaffold(appBar: AppBar(title: const Text('Memories')), body: ListView(padding: const EdgeInsets.all(16), children: [
      const StatusBanner(message: 'Photos are private by default. Upload production originals to private Supabase Storage and share only signed URLs.'),
      const SizedBox(height: 16),
      Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.photo_library_outlined, size: 38, color: Color(0xFF287E79)), const SizedBox(height: 10), Text('Travel timeline', style: Theme.of(context).textTheme.titleLarge), const Text('Photos, places, and expenses become editable moments. Recent data is cached for offline use.'), const SizedBox(height: 10), const Text('09:15  •  Tea garden\n12:30  •  Lunch  ₹450\n18:45  •  Sunset photos')])) ,
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.auto_stories_outlined, size: 38, color: Color(0xFF287E79)), const SizedBox(height: 10), Text('AI travel magazine', style: Theme.of(context).textTheme.titleLarge), const Text('Generate a layout-controlled, editable magazine from your saved trip context.'), const SizedBox(height: 16), FilledButton.icon(onPressed: trip == null ? null : () => _generate(context, trip.id), icon: const Icon(Icons.auto_awesome), label: const Text('Generate magazine'))])) ,
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: trip == null ? null : () => _analyzePhoto(context, trip.id), icon: const Icon(Icons.auto_fix_high), label: const Text('Analyze a photo metadata draft')),
    ]));
  }

  Future<void> _generate(BuildContext context, String tripId) async {
    try {
      final response = await controller.api.post('/magazines/generate', {}, query: {'trip_id': tripId});
      final magazine = response['magazine'] as Map<String, dynamic>;
      if (context.mounted) showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (context) => ListView(shrinkWrap: true, padding: const EdgeInsets.all(20), children: [Text(magazine['title'] as String, style: Theme.of(context).textTheme.headlineSmall), Text(magazine['subtitle'] as String), const SizedBox(height: 16), ...((magazine['pages'] as List<dynamic>).map((page) { final item = page as Map<String, dynamic>; return Card(child: ListTile(title: Text(item['title'] as String), subtitle: Text(item['content'] as String))); }))]));
    } catch (error) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not generate magazine: $error'))); }
  }

  Future<void> _analyzePhoto(BuildContext context, String tripId) async {
    try {
      final response = await controller.api.post('/photos/analyze', {'trip_id': tripId, 'storage_path': 'demo/$tripId/photo.jpg', 'captured_at': DateTime.now().toIso8601String(), 'latitude': 10.0889, 'longitude': 77.0595});
      if (context.mounted) showDialog<void>(context: context, builder: (context) => AlertDialog(title: const Text('Photo organization draft'), content: Text('Caption: ${response['caption']}\nTags: ${(response['ai_tags'] as List<dynamic>).join(', ')}\nConfidence: ${((response['confidence'] as num) * 100).toStringAsFixed(0)}%\n\nReview before saving—no exact landmark is claimed.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))]));
    } catch (error) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not analyze: $error'))); }
  }
}

