import 'package:flutter/material.dart';
import 'package:indina/screens/splash/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wifydarxzssyqdodbcsd.supabase.co',
    publishableKey: 'sb_publishable_FuhpeRcKmDa8e7YEoYyo9g__zRFxmJ0',
  );

  runApp(const IndiverseApp());
}

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
