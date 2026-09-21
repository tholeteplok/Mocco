import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/map/adventure_map_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MoccoApp()));
}

class MoccoApp extends StatelessWidget {
  const MoccoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mocco',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AdventureMapScreen(),
    );
  }
}
