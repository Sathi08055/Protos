import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:testing/pages/search_function.dart';
import 'package:testing/config/theme_config.dart';

class NutrientDetailsPage extends StatelessWidget {
  final FoodItem food;
  final Map<String, dynamic> nutrients;
  final bool showAddButton;

  const NutrientDetailsPage({
    Key? key,
    required this.food,
    required this.nutrients,
    this.showAddButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: ThemeConfig.primary,
          title: Text(food.name, style: const TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(
          color: Colors.grey[50], // Light background
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nutrient Composition',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: ThemeConfig.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildPieChart(),
                    ],
                  ),
                ),
                _buildMainNutrients(),
                _buildAminoAcids(context),
                const SizedBox(height: 24),
                if (showAddButton)
                  Center(
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Ingredient'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeConfig.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pop({'food': food, 'nutrients': nutrients});
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final nutrientData = [
      _NutrientData(
        'Protein',
        nutrients['Protein'] ?? 0.0,
        const Color(0xFF4CAF50),
      ),
      _NutrientData(
        'Water',
        nutrients['Water'] ?? 0.0,
        const Color(0xFF2196F3),
      ),
      _NutrientData(
        'Fat',
        nutrients['Total lipid (fat)'] ?? 0.0,
        const Color(0xFFFFC107),
      ),
      _NutrientData(
        'Carbs',
        nutrients['Carbohydrate, by difference'] ?? 0.0,
        const Color(0xFFE91E63),
      ),
      _NutrientData(
        'Other',
        nutrients['Ash,Alcohol and others'] ?? 0.0,
        const Color(0xFF9E9E9E),
      ),
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
                                  '${item.value.toStringAsFixed(1)}g (${(item.value / total * 100).toStringAsFixed(1)}%)',
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
    final mainNutrients = [
      _MainNutrient(
        'Calories',
        (nutrients['Energy (kcal)'] is num)
            ? (nutrients['Energy (kcal)'] as num).toStringAsFixed(1)
            : (nutrients['Energy (kcal)']?.toString() ?? '0'),
        'kcal',
        Icons.local_fire_department,
        Colors.deepOrange,
      ),
      _MainNutrient(
        'Protein',
        (nutrients['Protein'] is num)
            ? (nutrients['Protein'] as num).toStringAsFixed(1)
            : (nutrients['Protein']?.toString() ?? '0'),
        'g',
        Icons.fitness_center,
        Colors.blue,
      ),
      _MainNutrient(
        'Carbs',
        (nutrients['Carbohydrate, by difference'] is num)
            ? (nutrients['Carbohydrate, by difference'] as num).toStringAsFixed(
                1,
              )
            : (nutrients['Carbohydrate, by difference']?.toString() ?? '0'),
        'g',
        Icons.grain,
        Colors.amber,
      ),
      _MainNutrient(
        'Total Fat',
        (nutrients['Total lipid (fat)'] is num)
            ? (nutrients['Total lipid (fat)'] as num).toStringAsFixed(1)
            : (nutrients['Total lipid (fat)']?.toString() ?? '0'),
        'g',
        Icons.opacity,
        Colors.pink,
      ),
      _MainNutrient(
        'Fiber',
        (nutrients['Fiber, total dietary'] is num)
            ? (nutrients['Fiber, total dietary'] as num).toStringAsFixed(1)
            : (nutrients['Fiber, total dietary']?.toString() ?? '0'),
        'g',
        Icons.grass,
        Colors.green,
      ),
      _MainNutrient(
        'Water',
        (nutrients['Water'] is num)
            ? (nutrients['Water'] as num).toStringAsFixed(1)
            : (nutrients['Water']?.toString() ?? '0'),
        'g',
        Icons.water_drop,
        Colors.lightBlue,
      ),
    ];

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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: mainNutrients.length,
            itemBuilder: (context, index) {
              final nutrient = mainNutrients[index];
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
                        Icon(nutrient.icon, color: nutrient.color, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          nutrient.name,
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
                      '${nutrient.value} ${nutrient.unit}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAminoAcids(BuildContext context) {
    final essentialAminoAcids = [
      'Histidine',
      'Isoleucine',
      'Leucine',
      'Lysine',
      'Methionine',
      'Phenylalanine',
      'Threonine',
      'Tryptophan',
      'Valine',
    ];

    final nonEssentialAminoAcids = [
      'Alanine',
      'Arginine',
      'Aspartic acid',
      'Cystine',
      'Glutamic acid',
      'Glycine',
      'Proline',
      'Serine',
      'Tyrosine',
    ];

    double calculateTotal(List<String> acids) {
      return acids.fold(0.0, (sum, acid) => sum + (nutrients[acid] ?? 0.0));
    }

    final essentialTotal = calculateTotal(essentialAminoAcids);
    final nonEssentialTotal = calculateTotal(nonEssentialAminoAcids);

    return Container(
      margin: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Amino Acids',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ThemeConfig.primary,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Essential Section ---
              _buildAminoExpansionTile(
                context,
                title: 'Essential',
                data: essentialAminoAcids,
                total: essentialTotal,
              ),
              Divider(thickness: 1),
              _buildAminoExpansionTile(
                context,
                title: 'Non-Essential',
                data: nonEssentialAminoAcids,
                total: nonEssentialTotal,
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAminoExpansionTile(
    BuildContext context, {
    required String title,
    required List<String> data,
    required double total,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            unselectedWidgetColor: Colors.transparent,
            cardColor: Colors.transparent,
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: EdgeInsets.zero,
            iconColor: ThemeConfig.primary,
            collapsedIconColor: ThemeConfig.primary,
            title: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ThemeConfig.primary,
              ),
            ),
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) =>
                    _buildAminoAcidRow(data[index]),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 8,
                  right: 14,
                  left: 14,
                  top: 2,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeConfig.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total ${title.split(' ').first}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${(total / 1000).toStringAsFixed(3)}g',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ThemeConfig.primary,
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
    );
  }

  Widget _buildAminoAcidRow(String acid) {
    final value = nutrients[acid] ?? 0.0;
    return Padding(
      padding: (acid != "Valine" && acid != "Thyrosine")
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
          : const EdgeInsets.only(top: 8, right: 16, left: 16, bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            acid,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ThemeConfig.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${value.toStringAsFixed(2)} mg',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ThemeConfig.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutrientData {
  final String name;
  final double value;
  final Color color;

  _NutrientData(this.name, this.value, this.color);
}

class _MainNutrient {
  final String name;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  _MainNutrient(this.name, this.value, this.unit, this.icon, this.color);
}
