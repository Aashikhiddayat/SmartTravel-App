import 'package:flutter/material.dart';

import '../providers/app_controller.dart';
import '../widgets/status_banner.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller});
  final AppController controller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _busy = true);
    await widget.controller.signIn(email: _email.text.trim(), password: _password.text);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 38),
                  const Icon(Icons.explore_rounded, size: 64, color: Color(0xFF287E79), semanticLabel: 'SMART TRIP'),
                  const SizedBox(height: 16),
                  Text('SMART TRIP', textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Plan, travel, protect, and remember.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 32),
                  if (widget.controller.demoMode) const StatusBanner(message: 'DEMO MODE — seeded Munnar data. Never use demo safety or alert data as real guidance.'),
                  const SizedBox(height: 16),
                  TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
                  const SizedBox(height: 12),
                  TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline))),
                  const SizedBox(height: 20),
                  FilledButton.icon(onPressed: _busy ? null : _signIn, icon: const Icon(Icons.login), label: Text(_busy ? 'Signing in…' : 'Sign in')),
                  if (widget.controller.demoMode) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(onPressed: _busy ? null : () async { setState(() => _busy = true); await widget.controller.signInDemo(); if (mounted) setState(() => _busy = false); }, icon: const Icon(Icons.play_circle_outline), label: const Text('Enter SIH demo')),
                  ],
                  const SizedBox(height: 10),
                  TextButton(onPressed: () => _showInfo(context), child: const Text('Sign up / reset password')),
                  if (widget.controller.error != null) Text(widget.controller.error!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF9A5500))),
                ],
              ),
            ),
          ),
        ),
      );

  void _showInfo(BuildContext context) => showDialog<void>(context: context, builder: (context) => AlertDialog(title: const Text('Account setup'), content: const Text('In production, configure Supabase Auth and its email redirect URL. The API then verifies the Supabase access token. Demo mode intentionally uses a local demo account.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]));
}

