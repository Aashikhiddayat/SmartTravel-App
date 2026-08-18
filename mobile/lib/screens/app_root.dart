import 'package:flutter/material.dart';

import '../providers/app_controller.dart';
import 'app_shell.dart';
import 'login_screen.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          if (controller.loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
          return controller.signedIn ? AppShell(controller: controller) : LoginScreen(controller: controller);
        },
      );
}

