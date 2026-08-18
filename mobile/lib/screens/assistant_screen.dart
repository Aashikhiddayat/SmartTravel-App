import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../providers/app_controller.dart';
import '../widgets/status_banner.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key, required this.controller, required this.trip});
  final AppController controller;
  final Trip trip;
  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _input = TextEditingController();
  final List<(String, String)> _messages = [];
  bool _sending = false;
  @override
  void dispose() { _input.dispose(); super.dispose(); }
  Future<void> _send([String? prompt]) async {
    final text = (prompt ?? _input.text).trim();
    if (text.isEmpty || _sending) return;
    setState(() { _messages.add(('You', text)); _sending = true; _input.clear(); });
    try { final result = await widget.controller.api.post('/assistant/chat', {'trip_id': widget.trip.id, 'message': text}); if (mounted) setState(() => _messages.add(('SMART TRIP', result['answer'] as String))); } catch (error) { if (mounted) setState(() => _messages.add(('SMART TRIP', 'I could not reach the trip assistant: $error'))); }
    if (mounted) setState(() => _sending = false);
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('AI assistant')), body: Column(children: [
    const StatusBanner(message: 'The assistant uses current-trip context and provider data. Demo answers are illustrative—not live travel advice.'),
    Padding(padding: const EdgeInsets.all(10), child: Wrap(spacing: 8, runSpacing: 6, children: ['Where should I eat nearby?', 'How much budget is left?', "I'm 90 minutes late—replan", 'Find a safe alternative'].map((prompt) => ActionChip(label: Text(prompt), onPressed: () => _send(prompt))).toList())),
    Expanded(child: _messages.isEmpty ? const Center(child: Text('Ask about your itinerary, budget, food, or safety.')) : ListView.builder(padding: const EdgeInsets.all(16), itemCount: _messages.length, itemBuilder: (context, index) { final message = _messages[index]; final mine = message.$1 == 'You'; return Align(alignment: mine ? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), constraints: const BoxConstraints(maxWidth: 330), decoration: BoxDecoration(color: mine ? const Color(0xFFDDF0EB) : Colors.white, borderRadius: BorderRadius.circular(16)), child: Text(message.$2))); })),
    SafeArea(child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [Expanded(child: TextField(controller: _input, onSubmitted: (_) => _send(), decoration: const InputDecoration(hintText: 'Ask SMART TRIP…'))), const SizedBox(width: 8), IconButton.filled(onPressed: _sending ? null : _send, icon: const Icon(Icons.send), tooltip: 'Send message')]))),
  ]));
}

