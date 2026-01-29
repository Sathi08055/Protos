import 'package:flutter/material.dart';
import 'package:testing/config/theme_config.dart';
import 'dart:math';

class BMICalculatorPage extends StatefulWidget {
  const BMICalculatorPage({super.key});

  @override
  State<BMICalculatorPage> createState() => _BMICalculatorPageState();
}

class _BMICalculatorPageState extends State<BMICalculatorPage> {
  double _height = 170.0; // cm
  double _weight = 70.0; // kg
  double? _bmi;
  String _bmiCategory = '';
  Color _categoryColor = Colors.grey;

  void _calculateBMI() {
    // BMI = weight(kg) / height(m)²
    double heightInMeters = _height / 100;
    double bmi = _weight / pow(heightInMeters, 2);
    setState(() {
      _bmi = double.parse(bmi.toStringAsFixed(1));
      _updateBMICategory();
    });
  }

  void _updateBMICategory() {
    if (_bmi == null) return;

    if (_bmi! < 18.5) {
      _bmiCategory = 'Underweight';
      _categoryColor = Colors.blue;
    } else if (_bmi! < 25) {
      _bmiCategory = 'Normal';
      _categoryColor = Colors.green;
    } else if (_bmi! < 30) {
      _bmiCategory = 'Overweight';
      _categoryColor = Colors.orange;
    } else {
      _bmiCategory = 'Obese';
      _categoryColor = Colors.red;
    }
  }

  Widget _buildCategoryCard(String category, String range, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            range,
            style: TextStyle(fontSize: 16, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        backgroundColor: ThemeConfig.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Height (cm)',
                        style: TextStyle(
                          fontSize: 18,
                          color: ThemeConfig.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _height.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            ' cm',
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                        ],
                      ),
                      Slider(
                        value: _height,
                        min: 120,
                        max: 220,
                        divisions: 100,
                        activeColor: ThemeConfig.primary,
                        onChanged: (value) {
                          setState(() {
                            _height = value;
                            _calculateBMI();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Weight (kg)',
                        style: TextStyle(
                          fontSize: 18,
                          color: ThemeConfig.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _weight.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            ' kg',
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                        ],
                      ),
                      Slider(
                        value: _weight,
                        min: 30,
                        max: 150,
                        divisions: 120,
                        activeColor: ThemeConfig.primary,
                        onChanged: (value) {
                          setState(() {
                            _weight = value;
                            _calculateBMI();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (_bmi != null)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          'Your BMI',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _bmi!.toString(),
                          style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: _categoryColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _bmiCategory,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _categoryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BMI Categories',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCategoryCard('Underweight', '<18.5', Colors.blue),
                      const SizedBox(height: 12),
                      _buildCategoryCard('Normal', '18.5–24.9', Colors.green),
                      const SizedBox(height: 12),
                      _buildCategoryCard(
                        'Overweight',
                        '25–29.9',
                        Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryCard('Obese', '≥30', Colors.red),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
