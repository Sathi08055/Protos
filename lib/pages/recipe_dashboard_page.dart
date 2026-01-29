import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../config/theme_config.dart';
import 'add_ingredient_page.dart';
import '../services/food_data_service.dart';
import 'nutrient_details_page.dart';
import '../pages/search_function.dart';

class RecipeDashboardPage extends StatefulWidget {
  final Recipe recipe;
  final List<Recipe> allRecipes;
  final RecipeService recipeService;

  const RecipeDashboardPage({
    super.key,
    required this.recipe,
    required this.allRecipes,
    required this.recipeService,
  });

  @override
  State<RecipeDashboardPage> createState() => _RecipeDashboardPageState();
}

class _RecipeDashboardPageState extends State<RecipeDashboardPage> {
  String? selectedIngredient;
  final Map<String, String> ingredientNames = {};
  bool _isLoadingNutrition = false;
  final Map<String, TextEditingController> _massControllers = {};
  bool _hasUnsavedChanges = false;

  // Store a copy of the original ingredients for revert
  late Map<String, Map<String, dynamic>> _originalIngredients;

  // Track unsaved changes for any ingredient add, remove, or mass change
  void _setUnsaved() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Save a deep copy of the original ingredients
    _originalIngredients = Map<String, Map<String, dynamic>>.fromEntries(
      widget.recipe.ingredients.entries.map(
        (e) => MapEntry(e.key, Map<String, dynamic>.from(e.value)),
      ),
    );
    // Listen for changes in ingredient mass
    widget.recipe.ingredients.forEach((key, value) {
      _massControllers[key] =
          TextEditingController(text: value['mass'].toString())
            ..addListener(() {
              _setUnsaved();
            });
    });
  }

  @override
  void dispose() {
    for (final c in _massControllers.values) {
      c.dispose();
    }
    if (_hasUnsavedChanges) {
      FoodDataService.instance.clearCache();
    }
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      final shouldLeave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
            'You have unsaved changes. Do you want to leave without saving?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FoodDataService.instance.clearCache();
                // Restore ingredients from the original saved state
                setState(() {
                  widget.recipe.ingredients
                    ..clear()
                    ..addAll(_originalIngredients);
                });
                Navigator.of(context).pop(true);
              },
              child: const Text('Leave'),
            ),
          ],
        ),
      );
      return shouldLeave ?? false;
    }
    return true;
  }

  void _markUnsaved() {
    setState(() {
      _hasUnsavedChanges = true;
    });
  }

  void _resetUnsaved() {
    setState(() {
      _hasUnsavedChanges = false;
    });
  }

  Future<Map<String, dynamic>> _getTotalNutrition() async {
    final ingredients = widget.recipe.ingredients;
    final Map<String, dynamic> total = {};
    if (ingredients.isEmpty) return total;

    for (final entry in ingredients.entries) {
      final mass = entry.value['mass'] as double;
      final nutPer100g = entry.value['nut_per_100g'] as Map<String, dynamic>?;
      if (nutPer100g == null) continue;
      nutPer100g.forEach((key, value) {
        if (value is num) {
          final scaled = value * (mass / 100.0);
          total[key] = (total[key] ?? 0) + scaled;
        } else {
          total[key] ??= value;
        }
      });
    }
    return total;
  }

  void _showTotalNutrition() async {
    setState(() => _isLoadingNutrition = true);
    try {
      final nutrition = await _getTotalNutrition();
      if (!mounted) return;
      // Create a dummy FoodItem for total nutrition
      final totalFood = FoodItem(
        name: 'Total Nutrition',
        id: 'total',
        category: 'Summary',
        source: 'Calculated',
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NutrientDetailsPage(
            food: totalFood,
            nutrients: nutrition,
            showAddButton: false,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to calculate nutrition: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoadingNutrition = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter out any ingredients with ID > 10000
    final filteredIngredients = Map<String, Map<String, dynamic>>.fromEntries(
      widget.recipe.ingredients.entries.where((e) {
        final id = int.tryParse(e.key);
        return id != null && id < 10000;
      }),
    );
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.recipe.name,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: ThemeConfig.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              tooltip: 'Save',
              onPressed: () async {
                await widget.recipeService.saveRecipes(widget.allRecipes);
                setState(() {
                  _hasUnsavedChanges = false;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modernized Nutrient Dashboard Card
              FutureBuilder<Map<String, dynamic>>(
                future: _getTotalNutrition(),
                builder: (context, snapshot) {
                  final nutrition = snapshot.data ?? {};
                  String getVal(String key) {
                    final v = nutrition[key];
                    if (v is num) return v.toStringAsFixed(1);
                    return v?.toString() ?? '0';
                  }

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 32),
                    padding: const EdgeInsets.symmetric(
                      vertical: 36,
                      horizontal: 22,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeConfig.primary.withOpacity(0.10),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              color: ThemeConfig.primary,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Overall Nutrition',
                              style: TextStyle(
                                color: ThemeConfig.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _SummaryNutritionTile(
                              icon: Icons.local_fire_department,
                              label: 'Calories',
                              value: getVal('Energy (kcal)'),
                              unit: 'kcal',
                              color: Colors.deepOrange,
                            ),
                            _SummaryNutritionTile(
                              icon: Icons.fitness_center,
                              label: 'Protein',
                              value: getVal('Protein'),
                              unit: 'g',
                              color: Colors.blue,
                            ),
                            _SummaryNutritionTile(
                              icon: Icons.opacity,
                              label: 'Fat',
                              value: getVal('Total lipid (fat)'),
                              unit: 'g',
                              color: Colors.pink,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SummaryNutritionTile(
                              icon: Icons.grain,
                              label: 'Carbs',
                              value: getVal('Carbohydrate, by difference'),
                              unit: 'g',
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 32),
                            _SummaryNutritionTile(
                              icon: Icons.grass,
                              label: 'Fiber',
                              value: getVal('Fiber, total dietary'),
                              unit: 'g',
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              // Grouped header: 'Current Ingredients' and Add button in a Row
              if (filteredIngredients.isNotEmpty || true) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ingredients',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: ThemeConfig.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add', style: TextStyle(fontSize: 15)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConfig.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddIngredientPage(),
                          ),
                        );
                        if (result != null && result is Map) {
                          final food = result['food'];
                          final foodId = food.id;
                          final foodName = food.name;
                          final double defaultMass = 100.0;
                          final foodDataService = FoodDataService.instance;
                          final nut = await foodDataService.getNutrientData(
                            foodId,
                          );
                          setState(() {
                            final updated =
                                Map<String, Map<String, dynamic>>.from(
                                  widget.recipe.ingredients,
                                );
                            updated[foodId] = {
                              'mass': defaultMass,
                              'name': foodName,
                              'nut_per_100g': nut,
                            };
                            widget.recipe.ingredients
                              ..clear()
                              ..addAll(updated);
                            if (_massControllers.containsKey(foodId)) {
                              _massControllers[foodId]!.text = defaultMass
                                  .toString();
                            } else {
                              _massControllers[foodId] = TextEditingController(
                                text: defaultMass.toString(),
                              );
                            }
                            _setUnsaved();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              if (filteredIngredients.isNotEmpty) ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredIngredients.length,
                    itemBuilder: (context, idx) {
                      final e = filteredIngredients.entries.elementAt(idx);
                      final controller = _massControllers.putIfAbsent(
                        e.key,
                        () => TextEditingController(
                          text: e.value['mass'].toString(),
                        ),
                      );
                      if (controller.text != e.value['mass'].toString()) {
                        controller.text = e.value['mass'].toString();
                      }
                      final mass = e.value['mass'] as double;
                      final nutPer100g =
                          e.value['nut_per_100g'] as Map<String, dynamic>?;
                      Map<String, dynamic> mainNut = {};
                      if (nutPer100g != null) {
                        for (final key in [
                          'Energy (kcal)',
                          'Protein',
                          'Total lipid (fat)',
                          'Carbohydrate, by difference',
                          'Fiber, total dietary',
                        ]) {
                          final v = nutPer100g[key];
                          if (v is num) {
                            mainNut[key] = (v * (mass / 100.0)).toStringAsFixed(
                              1,
                            );
                          } else {
                            mainNut[key] = v?.toString() ?? '0';
                          }
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: Colors.grey[50],
                          collapsedBackgroundColor: Colors.grey[50],
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  e.value['name'] ?? e.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 80,
                                child: GestureDetector(
                                  onTap: () async {
                                    final result =
                                        await showDialog<Map<String, dynamic>>(
                                          context: context,
                                          builder: (context) {
                                            final dialogController =
                                                TextEditingController(
                                                  text: e.value['mass']
                                                      .toString(),
                                                );
                                            return AlertDialog(
                                              title: const Text(
                                                'Set Ingredient Mass',
                                              ),
                                              content: SizedBox(
                                                height: 120,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      e.value['name'] ?? e.key,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    TextFormField(
                                                      controller:
                                                          dialogController,
                                                      keyboardType:
                                                          const TextInputType.numberWithOptions(
                                                            decimal: true,
                                                          ),
                                                      decoration:
                                                          const InputDecoration(
                                                            labelText:
                                                                'Mass (g)',
                                                            border:
                                                                OutlineInputBorder(),
                                                            isDense: true,
                                                          ),
                                                      autofocus: true,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                    context,
                                                  ).pop(),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    final val = double.tryParse(
                                                      dialogController.text,
                                                    );
                                                    if (val != null &&
                                                        val > 0) {
                                                      final foodDataService =
                                                          FoodDataService
                                                              .instance;
                                                      final nut =
                                                          await foodDataService
                                                              .getNutrientData(
                                                                e.key,
                                                              );
                                                      final Map<String, dynamic>
                                                      scaledNut = {};
                                                      nut.forEach((key, value) {
                                                        if (value is num) {
                                                          scaledNut[key] =
                                                              value *
                                                              (val / 100.0);
                                                        } else {
                                                          scaledNut[key] =
                                                              value;
                                                        }
                                                      });
                                                      Navigator.of(
                                                        context,
                                                      ).pop({
                                                        'mass': val,
                                                        'total_nut': scaledNut,
                                                      });
                                                      _setUnsaved();
                                                    }
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                    if (result != null && result['mass'] > 0) {
                                      setState(() {
                                        widget.recipe.ingredients[e
                                                .key]!['mass'] =
                                            result['mass'];
                                        widget.recipe.ingredients[e
                                                .key]!['nut_per_100g'] =
                                            widget.recipe.ingredients[e
                                                .key]!['nut_per_100g']; // keep per-100g nutrition
                                        // Update the controller text as well
                                        _massControllers[e.key]?.text =
                                            result['mass'].toString();
                                      });
                                    }
                                  },
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      controller: controller,
                                      enabled: false,
                                      decoration: InputDecoration(
                                        labelText: 'g',
                                        labelStyle: TextStyle(
                                          color: ThemeConfig.primary,
                                          fontSize: 13,
                                        ),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 8,
                                            ),
                                      ),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: 8,
                                top: 2,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _NutritionTextRow(
                                    label: 'Calories',
                                    value: mainNut['Energy (kcal)'] ?? '-',
                                    unit: 'kcal',
                                  ),
                                  _NutritionTextRow(
                                    label: 'Protein',
                                    value: mainNut['Protein'] ?? '-',
                                    unit: 'g',
                                  ),
                                  _NutritionTextRow(
                                    label: 'Fat',
                                    value: mainNut['Total lipid (fat)'] ?? '-',
                                    unit: 'g',
                                  ),
                                  _NutritionTextRow(
                                    label: 'Carbs',
                                    value:
                                        mainNut['Carbohydrate, by difference'] ??
                                        '-',
                                    unit: 'g',
                                  ),
                                  _NutritionTextRow(
                                    label: 'Fiber',
                                    value:
                                        mainNut['Fiber, total dietary'] ?? '-',
                                    unit: 'g',
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: ThemeConfig.primary,
                                      ),
                                      tooltip: 'Delete',
                                      onPressed: () {
                                        setState(() {
                                          widget.recipe.ingredients.remove(
                                            e.key,
                                          );
                                          _setUnsaved();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: _isLoadingNutrition
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.analytics),
                      label: const Text('Show Total Nutrition'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConfig.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _isLoadingNutrition
                          ? null
                          : _showTotalNutrition,
                    ),
                  ],
                ),
                const SizedBox(height: 35),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryNutritionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;
  const _SummaryNutritionTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          '$value $unit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ],
    );
  }
}

// Add this widget at the bottom of the file:
class _NutritionTextRow extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  const _NutritionTextRow({
    required this.label,
    required this.value,
    required this.unit,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Text(unit, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
