import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_config.dart';
import 'core/theme.dart';
import 'providers/app_controller.dart';
import 'screens/app_root.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!AppConfig.demoMode && AppConfig.hasSupabase) {
    await Supabase.initialize(url: AppConfig.supabaseUrl, anonKey: AppConfig.supabaseAnonKey);
  }
  final controller = AppController();
  await controller.initialize();
  runApp(SmartTripApp(controller: controller));
}

class SmartTripApp extends StatelessWidget {
  const SmartTripApp({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) => MaterialApp(title: 'SMART TRIP', theme: AppTheme.light(), debugShowCheckedModeBanner: false, home: AppRoot(controller: controller));
}

