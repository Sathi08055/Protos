import 'package:flutter/material.dart';
import '../config/theme_config.dart';
import '../services/food_data_service.dart';

class IngredientExpansionTile extends StatelessWidget {
  final String name;
  final double mass;
  final Map<String, dynamic>? nutPer100g;
  final TextEditingController controller;
  final VoidCallback onDelete;
  final ValueChanged<double> onMassChanged;

  const IngredientExpansionTile({
    super.key,
    required this.name,
    required this.mass,
    required this.nutPer100g,
    required this.controller,
    required this.onDelete,
    required this.onMassChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isLong =
        name.length > 22 || name.split(' ').any((w) => w.length > 16);
    Map<String, dynamic> mainNut = {};
    if (nutPer100g != null) {
      for (final key in [
        'Energy (kcal)',
        'Protein',
        'Total lipid (fat)',
        'Carbohydrate, by difference',
        'Fiber, total dietary',
      ]) {
        final v = nutPer100g![key];
        if (v is num) {
          mainNut[key] = (v * (mass / 100.0)).toStringAsFixed(1);
        } else {
          mainNut[key] = v?.toString() ?? '0';
        }
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        backgroundColor: Colors.grey[50],
        collapsedBackgroundColor: Colors.grey[50],
        title: Container(
          constraints: BoxConstraints(
            minHeight: isLong ? 54 : 40,
            maxHeight: isLong ? 80 : 54,
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: isLong ? 2 : 1,
                  overflow: isLong
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  softWrap: isLong,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 80,
                child: GestureDetector(
                  onTap: () async {
                    final result = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (context) {
                        final dialogController = TextEditingController(
                          text: mass.toString(),
                        );
                        return AlertDialog(
                          title: const Text('Set Ingredient Mass'),
                          content: SizedBox(
                            height: 120,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: dialogController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: const InputDecoration(
                                    labelText: 'Mass (g)',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  autofocus: true,
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                final val = double.tryParse(
                                  dialogController.text,
                                );
                                if (val != null && val > 0) {
                                  Navigator.of(context).pop({'mass': val});
                                }
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                    if (result != null && result['mass'] > 0) {
                      onMassChanged(result['mass']);
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
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
                  value: mainNut['Carbohydrate, by difference'] ?? '-',
                  unit: 'g',
                ),
                _NutritionTextRow(
                  label: 'Fiber',
                  value: mainNut['Fiber, total dietary'] ?? '-',
                  unit: 'g',
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.delete, color: ThemeConfig.primary),
                    tooltip: 'Delete',
                    onPressed: onDelete,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
