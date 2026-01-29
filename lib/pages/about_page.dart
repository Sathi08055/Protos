import 'package:flutter/material.dart';
import 'package:testing/config/theme_config.dart';

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppDescription(),
            const SizedBox(height: 24),
            _buildFoodCategories(),
            const SizedBox(height: 24),
            _buildDataSources(),
            const SizedBox(height: 24),
            _buildSection('Educational Content', [
              _buildFeature(
                'Protein Basics',
                'What is protein, its importance, and how it benefits the body.',
                Icons.science_outlined,
              ),
              _buildFeature(
                'Amino Acids Guide',
                'Complete vs. incomplete proteins, essential amino acids, and their roles.',
                Icons.biotech_outlined,
              ),
              _buildFeature(
                'Nutrition Science',
                'Macronutrients (carbs, fats, protein), micronutrients, and balanced diets.',
                Icons.psychology_outlined,
              ),
              _buildFeature(
                'Indian Ingredients',
                'Comprehensive nutrition data about Indian ingredients.',
                Icons.restaurant_menu_outlined,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection('Features', [
              _buildFeature(
                'Search Database',
                'Look up thousands of foods to see their protein, carbs, fats, vitamins, and minerals.',
                Icons.search_outlined,
              ),
              _buildFeature(
                'Nutrition Calculator',
                'Log meals to track protein and nutrient intake.',
                Icons.calculate_outlined,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection('Target Audience', [
              _buildFeature(
                'Students & Health Enthusiasts',
                'Perfect for students and health-conscious individuals.',
                Icons.school_outlined,
              ),
              _buildFeature(
                'Fitness Enthusiasts',
                'Ideal for those focused on fitness and nutrition.',
                Icons.fitness_center_outlined,
              ),
              _buildFeature(
                'Weight Management',
                'Helpful for people looking to build muscle or lose weight.',
                Icons.monitor_weight_outlined,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildAppDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ThemeConfig.primary, ThemeConfig.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeConfig.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Protos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'An educational app designed to help users understand protein, amino acids, and overall nutrition. It provides science-backed information, a food nutrition calculator, and personalized recommendations to improve dietary habits.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCategories() {
    return Builder(
      builder: (context) {
        final categories = [
          'Baked Products',
          'Sweets & Snacks',
          'Vegetables and Vegetable Products',
          'Others',
          'Fats and Oils',
          'Poultry and Dairy Products',
          'Meat and Meat Products',
          'Fishes and Seafoods',
          'Fruits and Fruits Products',
          'Pulses, Nuts and Oilseeds',
          'Cereals, Grains Products',
          'Beverages',
          'Condiments & Sauces',
        ];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ThemeConfig.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.category_outlined,
                        color: ThemeConfig.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Food Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '13 categories',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.fiber_manual_record,
                          size: 8,
                          color: ThemeConfig.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            category,
                            style: const TextStyle(fontSize: 15, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataSources() {
    return Builder(
      builder: (context) {
        final sources = [
          'USDA(SR Legacy)',
          'Frida Database(DK)',
          'Standard Food Composition Table (Korean)',
          "Indian Diet Data Portal",
          'Indian Food Composition Table',
          'Canadian Nutritient File',
          'FAO/INFOODS',
          'Kenyan Food Composition Table',
        ];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ThemeConfig.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.source_outlined,
                        color: ThemeConfig.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Data Sources',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '8 sources',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...sources.map((source) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Icon(
                            Icons.fiber_manual_record,
                            size: 8,
                            color: ThemeConfig.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            source,
                            style: const TextStyle(fontSize: 15, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> features) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...features,
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeConfig.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: ThemeConfig.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
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
