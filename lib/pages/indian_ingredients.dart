import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testing/pages/nutrient_details_page.dart';
import 'package:testing/services/food_data_service.dart';
import 'package:testing/pages/search_function.dart';
import 'package:testing/config/theme_config.dart';

class IndianIngredientsPage extends StatefulWidget {
  const IndianIngredientsPage({super.key});

  @override
  State<IndianIngredientsPage> createState() => _IndianIngredientsPageState();
}

class _IndianIngredientsPageState extends State<IndianIngredientsPage> {
  List<Map<String, String>> _ingredients = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  Future<void> _loadIngredients() async {
    final csvString = await rootBundle.loadString(
      'assets/Indian_Ingredients.csv',
    );
    final lines = const LineSplitter().convert(csvString);
    final header = lines.first.split(',');
    final items = lines.skip(1).where((l) => l.trim().isNotEmpty).map((line) {
      final values = _parseCsvLine(line);
      return {header[0]: values[0], header[1]: values[1]};
    }).toList();
    setState(() {
      _ingredients = items;
      _loading = false;
    });
  }

  List<String> _parseCsvLine(String line) {
    // Handles quoted values and commas inside quotes
    final regex = RegExp(r'("[^"]*"|[^,]+)');
    return regex
        .allMatches(line)
        .map((m) => m.group(0)!.replaceAll('"', '').trim())
        .toList();
  }

  void _onIngredientTap(Map<String, String> ingredient) async {
    final id = ingredient['ID'];
    final name = ingredient['Name'] ?? '';
    if (id == null) return;
    try {
      await FoodDataService.instance.initialize();
      final food = FoodItem(id: id, name: name, category: '', source: '');
      final nutrients = await FoodDataService.instance.getNutrientData(id);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NutrientDetailsPage(
            food: food,
            nutrients: nutrients,
            showAddButton: false,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading nutrient data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indian Ingredients'),
        backgroundColor: ThemeConfig.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.grey[100],
              child: SafeArea(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  itemCount: _ingredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = _ingredients[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      margin: const EdgeInsets.only(bottom: 18),
                      color: Colors.white,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: ThemeConfig.primary.withOpacity(
                            0.12,
                          ),
                          child: Icon(
                            Icons.restaurant,
                            color: ThemeConfig.primary,
                            size: 28,
                          ),
                        ),
                        title: Text(
                          ingredient['Name'] ?? '',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Colors.black38,
                        ),
                        onTap: () => _onIngredientTap(ingredient),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
