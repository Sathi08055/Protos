import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:testing/config/theme_config.dart';
import 'package:fl_chart/fl_chart.dart';

class FoodNutritionPage extends StatefulWidget {
  final String foodId;
  const FoodNutritionPage({super.key, required this.foodId});

  @override
  State<FoodNutritionPage> createState() => _FoodNutritionPageState();
}

class _FoodNutritionPageState extends State<FoodNutritionPage> {
  Map<String, String>? food;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _loadFood();
  }

  Future<void> _loadFood() async {
    // Always use indian_food.csv, assume only IDs > 10000 are passed
    final csvString = await rootBundle.loadString('assets/indian_food.csv');
    final lines = const LineSplitter().convert(csvString);
    final header = lines.first.split(',').map((h) => h.trim()).toList();
    final items = lines
        .skip(1)
        .where((l) => l.trim().isNotEmpty)
        .map((line) {
          final values = _parseCsvLine(line);
          if (values.length != header.length) return null;
          final cleanedValues = values.map((v) => v.trim()).toList();
          return Map.fromIterables(header, cleanedValues);
        })
        .whereType<Map<String, String>>()
        .toList();
    final found = items.firstWhere(
      (row) => row['ID']?.trim().toString() == widget.foodId.trim(),
      orElse: () => {},
    );
    setState(() {
      food = found.isNotEmpty ? found : null;
      _loading = false;
    });
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (food == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Nutrition Details'),
          backgroundColor: ThemeConfig.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Food not found.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(food!['Name'] ?? 'Nutrition Details'),
        backgroundColor: ThemeConfig.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.grey[50],
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPieChart(),
                _buildMainNutrients(),
                _buildMicronutrients(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    double parse(String? v) => double.tryParse(v ?? '') ?? 0.0;
    final nutrientData = [
      _NutrientData(
        'Protein',
        parse(food!['protein_g']),
        const Color(0xFF4CAF50),
      ),
      _NutrientData('Fat', parse(food!['fat_g']), const Color(0xFFFFC107)),
      _NutrientData('Carbs', parse(food!['carb_g']), const Color(0xFFE91E63)),
      _NutrientData('Fibre', parse(food!['fibre_g']), const Color(0xFF2196F3)),
      _NutrientData('Water', parse(food!['Water']), const Color(0xFF00BCD4)),
    ];
    final total = nutrientData.fold(0.0, (sum, item) => sum + item.value);
    final sections = nutrientData
        .map(
          (item) => PieChartSectionData(
            value: item.value,
            title: '',
            color: item.color,
            radius: 70,
            showTitle: false,
            borderSide: const BorderSide(width: 0.5, color: Colors.white),
          ),
        )
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final chartSize = constraints.maxWidth * 0.7;
              return SizedBox(
                height: chartSize,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: chartSize * 0.2,
                    sectionsSpace: 2,
                    pieTouchData: PieTouchData(enabled: false),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Total: ${total.toStringAsFixed(1)}g',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text(
                'Composition Breakdown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: nutrientData
                    .map(
                      (item) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: item.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  '${item.value.toStringAsFixed(1)}g (${total > 0 ? (item.value / total * 100).toStringAsFixed(1) : '0'}%)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainNutrients() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Main Nutrients',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ThemeConfig.primary,
            ),
          ),
          const SizedBox(height: 16),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            children: [
              _mainNutrientCard(
                'Calories',
                food!['Energy Kcal'],
                'kcal',
                Icons.local_fire_department,
                Colors.deepOrange,
              ),
              _mainNutrientCard(
                'Protein',
                food!['protein_g'],
                'g',
                Icons.fitness_center,
                Colors.blue,
              ),
              _mainNutrientCard(
                'Carbs',
                food!['carb_g'],
                'g',
                Icons.grain,
                Colors.amber,
              ),
              _mainNutrientCard(
                'Total Fat',
                food!['fat_g'],
                'g',
                Icons.opacity,
                Colors.pink,
              ),
              _mainNutrientCard(
                'Fibre',
                food!['fibre_g'],
                'g',
                Icons.grass,
                Colors.green,
              ),
              _mainNutrientCard(
                'Water',
                food!['Water'],
                'g',
                Icons.water_drop,
                Colors.cyan,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mainNutrientCard(
    String name,
    String? value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${(value ?? '-').toString()} $unit',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicronutrients() {
    final minerals = [
      ['Calcium', food!['calcium_mg'], 'mg'],
      ['Phosphorus', food!['phosphorus_mg'], 'mg'],
      ['Magnesium', food!['magnesium_mg'], 'mg'],
      ['Sodium', food!['sodium_mg'], 'mg'],
      ['Potassium', food!['potassium_mg'], 'mg'],
      ['Iron', food!['iron_mg'], 'mg'],
      ['Copper', food!['copper_mg'], 'mg'],
      ['Selenium', food!['selenium_ug'], 'μg'],
      ['Manganese', food!['manganese_mg'], 'mg'],
      ['Zinc', food!['zinc_mg'], 'mg'],
    ];
    final vitamins = [
      ['Vitamin A', food!['Vitamin A ug'], 'μg'],
      ['Vitamin E', food!['Vitamin E_mg'], 'mg'],
      ['Vitamin D3', food!['Vitamin d3_ug'], 'μg'],
      ['Vitamin K1', food!['Vitamin k1_ug'], 'μg'],
      ['Vitamin B9', food!['Vitamin B9_ug'], 'μg'],
      ['Vitamin B1', food!['Vitamin B1 mg'], 'mg'],
      ['Vitamin B2', food!['Vitamin B2 mg'], 'mg'],
      ['Vitamin B3', food!['Vitamin B3 mg'], 'mg'],
      ['Vitamin B5', food!['Vitamin B5 mg'], 'mg'],
      ['Vitamin B6', food!['Vitamin B6 mg'], 'mg'],
      ['Vitamin B9', food!['Vitamin B9 ug'], 'μg'],
      ['Vitamin C', food!['Vitamin c mg'], 'mg'],
    ];
    double sumMineralsMg = minerals
        .where((n) => n[2] == 'mg')
        .fold(0.0, (sum, n) => sum + (double.tryParse(n[1] ?? '') ?? 0.0));
    double sumMineralsUg = minerals
        .where((n) => n[2] == 'μg')
        .fold(0.0, (sum, n) => sum + (double.tryParse(n[1] ?? '') ?? 0.0));
    double sumVitaminsMg = vitamins
        .where((n) => n[2] == 'mg')
        .fold(0.0, (sum, n) => sum + (double.tryParse(n[1] ?? '') ?? 0.0));
    double sumVitaminsUg = vitamins
        .where((n) => n[2] == 'μg')
        .fold(0.0, (sum, n) => sum + (double.tryParse(n[1] ?? '') ?? 0.0));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Material(
            elevation: 1,
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                childrenPadding: EdgeInsets.zero,
                iconColor: ThemeConfig.primary,
                collapsedIconColor: ThemeConfig.primary,
                title: Text(
                  'Vitamins',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: ThemeConfig.primary,
                  ),
                ),
                children: [
                  ...vitamins.map(
                    (n) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            n[0] ?? '-',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: ThemeConfig.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${(n[1] ?? '-').toString()} ${n[2]}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ThemeConfig.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeConfig.primary.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Vitamins',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${sumVitaminsMg.toStringAsFixed(2)} mg + ${sumVitaminsUg.toStringAsFixed(2)} μg',
                            style: TextStyle(
                              color: ThemeConfig.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Material(
            elevation: 1,
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                childrenPadding: EdgeInsets.zero,
                iconColor: ThemeConfig.primary,
                collapsedIconColor: ThemeConfig.primary,
                title: Text(
                  'Minerals',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: ThemeConfig.primary,
                  ),
                ),
                children: [
                  ...minerals.map(
                    (n) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            n[0] ?? '-',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: ThemeConfig.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${(n[1] ?? '-').toString()} ${n[2]}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ThemeConfig.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeConfig.primary.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Minerals',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${sumMineralsMg.toStringAsFixed(2)} mg + ${sumMineralsUg.toStringAsFixed(2)} μg',
                            style: TextStyle(
                              color: ThemeConfig.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NutrientData {
  final String name;
  final double value;
  final Color color;
  _NutrientData(this.name, this.value, this.color);
}
