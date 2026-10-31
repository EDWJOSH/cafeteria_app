import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const GranoApp());
}

class GranoApp extends StatelessWidget {
  const GranoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grano & Co.',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      home: const HomeScreen(),
    );
  }
}
