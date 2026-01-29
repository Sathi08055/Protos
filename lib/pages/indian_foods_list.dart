import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testing/config/theme_config.dart';
import 'package:testing/pages/food_nutrition.dart';

class IndianFoodsListPage extends StatefulWidget {
  final String category;
  final IconData? icon;
  const IndianFoodsListPage({super.key, required this.category, this.icon});

  @override
  State<IndianFoodsListPage> createState() => _IndianFoodsListPageState();
}

class _IndianFoodsListPageState extends State<IndianFoodsListPage> {
  List<Map<String, String>> _foods = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    final csvString = await rootBundle.loadString('assets/indian_food.csv');
    final lines = const LineSplitter().convert(csvString);
    // Clean header: trim spaces
    final header = lines.first.split(',').map((h) => h.trim()).toList();
    List<String> skippedRows = [];
    final items = lines
        .skip(1)
        .where((l) => l.trim().isNotEmpty)
        .map((line) {
          final values = _parseCsvLine(line);
          if (values.length != header.length) {
            skippedRows.add(line);
            return null;
          }
          // Clean values: trim spaces
          final cleanedValues = values.map((v) => v.trim()).toList();
          return Map.fromIterables(header, cleanedValues);
        })
        .whereType<Map<String, String>>()
        .where((row) => row['Food_Category'] == widget.category)
        .toList();
    setState(() {
      _foods = items
        ..sort((a, b) => (a['Name'] ?? '').compareTo(b['Name'] ?? ''));
      _loading = false;
    });
    if (skippedRows.isNotEmpty) {
      // ignore: use_build_context_synchronously
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Skipped CSV Rows'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: skippedRows.map((row) => Text(row)).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  List<String> _parseCsvLine(String line) {
    final regex = RegExp(r'("[^"]*"|[^,]+)');
    return regex
        .allMatches(line)
        .map((m) => m.group(0)!.replaceAll('"', '').trim())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final categoryDescriptions = {
      'Mains':
          'Hearty, filling dishes that anchor your meal — biryanis, rotis, pulaos, parathas, dosas, and rich one-plate wonders.',
      'Curries (Gravy & Dry)':
          'Spicy, saucy, or masala-coated dishes — includes everything from butter chicken to palak paneer, koftas, and dry sabzis.',
      'Sides':
          'Tasty accompaniments like stir-fries, bhartas, raitas, pickles, and dry veggies that complete your thali.',
      'Soups':
          'Warm, comforting starters — from clear consommés to thick lentil broths and veggie purees.',
      'Beverages':
          'Hot and cold sips — chai, lassi, soups, squashes, smoothies, and refreshing local drinks.',
      'Snacks':
          'Quick, irresistible bites — pakoras, samosas, chaats, cutlets, murukkus, and finger foods to munch anytime.',
      'Desserts':
          'Sweet indulgences — kheers, halwas, mousses, laddus, and fusion treats to end the meal on a high.',
    };
    final categoryEmojis = {
      'Mains': '🍛',
      'Curries (Gravy & Dry)': '🍲',
      'Sides': '🥗',
      'Soups': '🍵',
      'Beverages': '🍹',
      'Snacks': '🍿',
      'Desserts': '🍮',
    };
    final emoji = categoryEmojis[widget.category] ?? '';
    final description = categoryDescriptions[widget.category] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category == "Mains" || widget.category == "Sides"
              ? (widget.category == "Mains" ? "Main Dish" : "Side Dish")
              : widget.category,
        ),
        backgroundColor: ThemeConfig.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _foods.isEmpty
            ? Center(
                child: Text(
                  'No foods found in this category.',
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 20,
                ),
                itemCount: _foods.length,
                itemBuilder: (context, index) {
                  final food = _foods[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    child: Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FoodNutritionPage(foodId: food['ID'] ?? ''),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: ThemeConfig.primary
                                    .withOpacity(0.13),
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 22),
                                ),
                                radius: 26,
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FormatFoodName(name: food['Name'] ?? ''),
                                    if ((food['Macro'] ?? '').isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'Macro: ${food['Macro']}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.black38,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class FormatFoodName extends StatelessWidget {
  final String name;

  const FormatFoodName({super.key, required this.name});

  List<String> splitNameAndTranslation(String name) {
    final match = RegExp(r'^(.*?)(\s*\(.*\))').firstMatch(name);
    if (match != null) {
      final m1 = match.group(1)!.trim();
      final m2 = match.group(2)!.trim();
      return [m1, m2];
    } else {
      return [name, ''];
    }
  }

  @override
  Widget build(BuildContext context) {
    final textList = splitNameAndTranslation(name);

    if (textList[1].isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            textList[0],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Text(
            textList[1],
            style: const TextStyle(color: Color.fromARGB(158, 18, 17, 17)),
          ),
        ],
      );
    } else {
      return Text(
        textList[0],
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      );
    }
  }
}
