import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/mastery_local_datasource.dart';
import 'presentation/screens/journey/journey_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive CE untuk penyimpanan lokal progres
  await Hive.initFlutter();
  await Hive.openBox(HiveMasteryLocalDataSource.boxName);

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
      themeMode: ThemeMode.light,
      home: const JourneyScreen(),
    );
  }
}
