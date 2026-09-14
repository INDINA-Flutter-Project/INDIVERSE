import 'package:flutter/material.dart';
import 'package:indina/screens/splash/splash_screen.dart';

import 'core/constants/app_theme.dart';

void main() => runApp(const IndiverseApp());

class IndiverseApp extends StatelessWidget {
  const IndiverseApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'INDIVERSE',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark,
    home: const SplashScreen(),
  );
}
