import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/recipe.dart';

class RecipeService {
  static const String fileName = 'recipies.json'; // match asset spelling

  Future<String> get _writableFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, fileName);
  }

  Future<void> _ensureFileExists() async {
    final filePath = await _writableFilePath;
    final file = File(filePath);
    if (!await file.exists()) {
      // Copy from asset on first run
      final assetData = await rootBundle.loadString('assets/recipies.json');
      await file.writeAsString(assetData.isEmpty ? '[]' : assetData);
    }
  }

  Future<List<Recipe>> loadRecipes() async {
    try {
      await _ensureFileExists();
      final file = File(await _writableFilePath);
      final String contents = await file.readAsString();
      if (contents.trim().isEmpty) return [];
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      print('Error loading recipes: $e');
      return [];
    }
  }

  Future<void> saveRecipes(List<Recipe> recipes) async {
    try {
      await _ensureFileExists();
      final file = File(await _writableFilePath);
      final String jsonString = json.encode(
        recipes.map((recipe) => recipe.toJson()).toList(),
      );
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving recipes: $e');
    }
  }
}
