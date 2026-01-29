import 'package:testing/pages/home.dart';
import "package:flutter/material.dart";
import 'package:testing/services/food_data_service.dart';
import 'package:testing/services/food_data_cache.dart';
import 'package:testing/config/theme_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load both CSVs at app start
  try {
    await FoodDataCache.instance.initialize();
  } catch (e) {
    print('Warning: Failed to initialize food data cache: $e');
  }

  try {
    await FoodDataService.instance.initialize();
  } catch (e) {
    print('Warning: Failed to initialize food data: $e');
  }

  runApp(
    MaterialApp(
      title: "Protos",
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 33, 150, 243),
        colorScheme: ColorScheme.fromSeed(
          seedColor: ThemeConfig.primary,
          primary: ThemeConfig.primary,
          secondary: ThemeConfig.secondary,
        ),
      ),
    ),
  );
}
