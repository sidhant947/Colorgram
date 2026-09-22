import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/services/hive_service.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/providers.dart';
import 'ui/features/home/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
      ],
      child: const ColorgramApp(),
    ),
  );
}

class ColorgramApp extends StatelessWidget {
  const ColorgramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Colorgram',
      theme: AppTheme.darkTheme,
      home: const HomeView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
