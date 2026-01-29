import 'dart:convert';
import 'package:flutter/services.dart';

class FoodDataCache {
  static final FoodDataCache instance = FoodDataCache._internal();
  FoodDataCache._internal();

  List<Map<String, String>>? indianFoods;
  List<Map<String, String>>? fullValues;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    // Load indian_food.csv
    final indianCsv = await rootBundle.loadString('assets/indian_food.csv');
    final indianLines = const LineSplitter().convert(indianCsv);
    final indianHeader = indianLines.first.split(',').map((h) => h.trim()).toList();
    indianFoods = indianLines
        .skip(1)
        .where((l) => l.trim().isNotEmpty)
        .map((line) {
          final values = _parseCsvLine(line);
          if (values.length != indianHeader.length) return null;
          final cleanedValues = values.map((v) => v.trim()).toList();
          return Map.fromIterables(indianHeader, cleanedValues);
        })
        .whereType<Map<String, String>>()
        .toList();
    // Load Full values.csv
    final fullCsv = await rootBundle.loadString('assets/Full values.csv');
    final fullLines = const LineSplitter().convert(fullCsv);
    final fullHeader = fullLines.first.split(',').map((h) => h.trim()).toList();
    fullValues = fullLines
        .skip(1)
        .where((l) => l.trim().isNotEmpty)
        .map((line) {
          final values = _parseCsvLine(line);
          if (values.length != fullHeader.length) return null;
          final cleanedValues = values.map((v) => v.trim()).toList();
          return Map.fromIterables(fullHeader, cleanedValues);
        })
        .whereType<Map<String, String>>()
        .toList();
    _initialized = true;
  }

  List<String> _parseCsvLine(String line) {
    final regex = RegExp(r'("[^"]*"|[^,]+)');
    return regex
        .allMatches(line)
        .map((m) => m.group(0)!.replaceAll('"', '').trim())
        .toList();
  }
}
