import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/trip.dart';
import '../providers/app_controller.dart';
import '../widgets/status_banner.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key, required this.controller, required this.trip});
  final AppController controller;
  final Trip trip;
  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late Future<Map<String, dynamic>> _summary;
  @override
  void initState() { super.initState(); _summary = _load(); }
  Future<Map<String, dynamic>> _load() => widget.controller.api.get('/expenses/summary', {'trip_id': widget.trip.id});
  void _refresh() => setState(() => _summary = _load());

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Budget dashboard')), floatingActionButton: FloatingActionButton.extended(onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => AddExpenseScreen(controller: widget.controller, trip: widget.trip))); if (mounted) _refresh(); }, icon: const Icon(Icons.add), label: const Text('Add expense')), body: FutureBuilder<Map<String, dynamic>>(future: _summary, builder: (context, snapshot) {
    if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
    if (snapshot.hasError) return Center(child: Text('Could not load budget: ${snapshot.error}'));
    final summary = snapshot.data!['summary'] as Map<String, dynamic>;
    final total = (summary['total_spent'] as num).toDouble();
    final remaining = (summary['remaining_budget'] as num).toDouble();
    final percent = (summary['budget_percentage'] as num).toDouble();
    final categories = Map<String, dynamic>.from(summary['by_category'] as Map<dynamic, dynamic>);
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(color: const Color(0xFFE1F0EA), child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Remaining budget', style: Theme.of(context).textTheme.titleMedium), Text('₹${remaining.toStringAsFixed(0)}', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 10), LinearProgressIndicator(value: (percent / 100).clamp(0, 1)), Text('₹${total.toStringAsFixed(0)} spent • ${percent.toStringAsFixed(1)}% of ₹${widget.trip.budget.toStringAsFixed(0)}')])) ,
      const SizedBox(height: 12),
      Text('Category breakdown', style: Theme.of(context).textTheme.titleLarge),
      if (categories.isEmpty) const Card(child: ListTile(title: Text('No expenses recorded'), subtitle: Text('Add an expense or scan a receipt draft.'))),
      ...categories.entries.map((entry) => Card(child: ListTile(leading: const Icon(Icons.pie_chart_outline), title: Text(entry.key), trailing: Text('₹${(entry.value as num).toStringAsFixed(0)}')))),
      const SizedBox(height: 10),
      StatusBanner(message: 'Forecast ₹${(summary['forecast_total'] as num).toStringAsFixed(0)}. Receipt drafts always need user confirmation.'),
    ]);
  }));
}

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key, required this.controller, required this.trip});
  final AppController controller;
  final Trip trip;
  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amount = TextEditingController();
  final _description = TextEditingController();
  final _merchant = TextEditingController();
  String _category = 'Food';
  bool _saving = false;
  @override
  void dispose() { _amount.dispose(); _description.dispose(); _merchant.dispose(); super.dispose(); }
  Future<void> _save() async {
    final amount = double.tryParse(_amount.text);
    if (amount == null || amount <= 0 || _description.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter an amount and description.'))); return; }
    setState(() => _saving = true);
    try {
      await widget.controller.api.post('/expenses', {'category': _category, 'amount': amount, 'currency': 'INR', 'description': _description.text.trim(), 'merchant': _merchant.text.trim().isEmpty ? null : _merchant.text.trim(), 'expense_date': DateFormat('yyyy-MM-dd').format(DateTime.now())}, query: {'trip_id': widget.trip.id});
      if (mounted) Navigator.pop(context);
    } catch (error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save: $error'))); }
    if (mounted) setState(() => _saving = false);
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Add expense')), body: ListView(padding: const EdgeInsets.all(20), children: [
    const StatusBanner(message: 'Expenses remain private to the user by default.'), const SizedBox(height: 14),
    DropdownButtonFormField<String>(value: _category, decoration: const InputDecoration(labelText: 'Category'), items: const ['Transport', 'Accommodation', 'Food', 'Tickets', 'Shopping', 'Emergency', 'Other'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) => setState(() => _category = value!)), const SizedBox(height: 12),
    TextField(controller: _amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹ ')), const SizedBox(height: 12), TextField(controller: _merchant, decoration: const InputDecoration(labelText: 'Merchant (optional)')), const SizedBox(height: 12), TextField(controller: _description, decoration: const InputDecoration(labelText: 'Description')), const SizedBox(height: 20),
    FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Saving…' : 'Save expense')),
    TextButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReceiptScannerScreen(controller: widget.controller, trip: widget.trip))), icon: const Icon(Icons.document_scanner), label: const Text('Receipt scanner demo')),
  ]));
}

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({super.key, required this.controller, required this.trip});
  final AppController controller;
  final Trip trip;
  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  final _ocr = TextEditingController(text: 'Tea Tales Cafe\nTotal INR 450');
  Map<String, dynamic>? _draft;
  @override
  void dispose() { _ocr.dispose(); super.dispose(); }
  Future<void> _scan() async { try { final response = await widget.controller.api.post('/expenses/receipt-scan', {'trip_id': widget.trip.id, 'ocr_text': _ocr.text}); if (mounted) setState(() => _draft = response['draft'] as Map<String, dynamic>); } catch (error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Scan failed: $error'))); } }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Receipt scanner')), body: ListView(padding: const EdgeInsets.all(20), children: [const StatusBanner(message: 'Demo OCR accepts pasted text. A production adapter uses on-device ML Kit, then requires confirmation before saving.'), const SizedBox(height: 12), TextField(controller: _ocr, minLines: 4, maxLines: 8, decoration: const InputDecoration(labelText: 'Recognized receipt text')), const SizedBox(height: 16), FilledButton.icon(onPressed: _scan, icon: const Icon(Icons.document_scanner), label: const Text('Extract receipt draft')), if (_draft != null) Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Merchant: ${_draft!['merchant']}'), Text('Detected total: ${_draft!['currency']} ${_draft!['total_amount'] ?? 'unknown'}'), Text('Confidence: ${((_draft!['confidence'] as num) * 100).toStringAsFixed(0)}%'), const SizedBox(height: 8), const Text('Please verify the detected amount before saving.', style: TextStyle(fontWeight: FontWeight.bold))])))]));
}
