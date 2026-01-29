import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:testing/config/theme_config.dart';
import 'package:testing/pages/indian_foods_list.dart';

class IndianFoodsPage extends StatelessWidget {
  IndianFoodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indian Foods'),
        backgroundColor: ThemeConfig.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          children: [
            _buildCategoryCard('Mains', '🍛 ', context),
            const SizedBox(height: 18),
            _buildCategoryCard('Curries (Gravy & Dry)', '🍲', context),
            const SizedBox(height: 18),
            _buildCategoryCard('Sides', '🥗', context),
            const SizedBox(height: 18),
            _buildCategoryCard('Snacks', '🍿', context),
            const SizedBox(height: 18),
            _buildCategoryCard('Beverages', '🍹', context),
            const SizedBox(height: 18),
            _buildCategoryCard('Soups', '🍵', context),
            const SizedBox(height: 18),
            _buildCategoryCard('Desserts', '🍮', context),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, String emoji, BuildContext context) {
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
    final categoryCounts = {
      'Mains': 118,
      'Curries (Gravy & Dry)': 109,
      'Sides': 134,
      'Soups': 25,
      'Beverages': 33,
      'Snacks': 99,
      'Desserts': 102,
    };
    int foodCount = categoryCounts[title] ?? 0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
        title: Text(
          (title == "Mains") || (title == "Sides")
              ? (title == "Mains" ? '$emoji Main Dish' : "$emoji Side Dish")
              : '$emoji $title',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: ThemeConfig.primary,
            letterSpacing: 0.2,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                categoryDescriptions[title] ?? '',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                'Foods: $foodCount',
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeConfig.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.black38,
          size: 18,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  IndianFoodsListPage(category: title, icon: null),
            ),
          );
        },
      ),
    );
  }

  final _categoryDescriptions = {
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

  final _categoryEmojis = {
    'Mains': '🍛',
    'Curries (Gravy & Dry)': '🍲',
    'Sides': '🥗',
    'Soups': '🍵',
    'Beverages': '🍹',
    'Snacks': '🍿',
    'Desserts': '🍮',
  };
}
