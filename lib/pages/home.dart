import 'package:flutter/material.dart';
import 'package:testing/config/theme_config.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:testing/pages/calculator_items.dart';
import 'package:testing/pages/loading_page.dart';
import 'package:testing/pages/about_page.dart';
import 'package:testing/pages/bmi_calculator_page.dart';
import 'package:testing/pages/indian_ingredients.dart';
import 'package:testing/pages/protein_info.dart';
import 'package:testing/pages/indian_foods.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      // Show loading page with Lottie animation, then go to results
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoadingPage(searchQuery: query),
        ),
      ).then((_) {
        _searchController.clear();
      });
    }
  }

  // Handle back button press
  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      // If not on home tab, switch to home tab
      setState(() {
        _currentIndex = 0;
      });
      return false; // Don't exit app
    }
    return true; // Allow app exit
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleCardTap(String title) {
    if (title == 'BMI Calculator') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BMICalculatorPage()),
      );
    } else if (title == 'Indian Ingredients') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const IndianIngredientsPage()),
      );
    } else if (title == 'Learn About Protein') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProteinInfoPage()),
      );
    } else if (title == 'Indian Foods') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => IndianFoodsPage()),
      );
    }
    // Add other navigation handlers for other cards here
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Protos'),
          backgroundColor: ThemeConfig.primary,
          foregroundColor: Colors.white,
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildSearchTab(),
            const Calculator_main(),
            const AboutTab(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 8,
              ),
              child: GNav(
                rippleColor: Colors.grey[300]!,
                hoverColor: Colors.grey[100]!,
                gap: 8,
                activeColor: Colors.white,
                iconSize: 24,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                duration: const Duration(milliseconds: 400),
                tabBackgroundColor: ThemeConfig.primary,
                color: ThemeConfig.navInactive,
                tabs: const [
                  GButton(icon: Icons.home, text: 'Home'),
                  GButton(icon: Icons.calculate, text: 'Calculator'),
                  GButton(icon: Icons.info_outline, text: 'About'),
                ],
                selectedIndex: _currentIndex,
                onTabChange: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchTab() {
    final screenHeight = MediaQuery.of(context).size.height;
    const cardHeight = 250.0; // Fixed card height

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.02),
              // Search Bar
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeConfig.primary.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: TextStyle(color: ThemeConfig.secondary, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Search for foods...',
                    hintStyle: TextStyle(
                      color: ThemeConfig.navInactive,
                      fontSize: 18,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: ThemeConfig.primary,
                      size: 30,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: ThemeConfig.primary,
                              size: 26,
                            ),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: ThemeConfig.primary.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: ThemeConfig.primary.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: ThemeConfig.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                  onSubmitted: _performSearch,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              _buildFeatureCard(
                'Learn About Protein',
                'Understand proteins, amino acids, and their importance',
                Icons.science_outlined,
                const Color(0xFF2196F3),
                const Color(0xFF1976D2),
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildFeatureCard(
                'Indian Ingredients',
                'Explore nutrition values of common Indian ingredients',
                Icons.restaurant_menu_outlined,
                const Color(0xFF00BFA5),
                const Color(0xFF00796B),
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildFeatureCard(
                'Indian Foods',
                'Explore the Nutrients of Common 600+ Indian foods',
                Icons.rice_bowl_outlined,
                const Color(0xFF795548), // Brown 600
                const Color(0xFF4E342E), // Brown 800
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildFeatureCard(
                'BMI Calculator',
                'Calculate and track your Body Mass Index',
                Icons.monitor_weight_outlined,
                const Color(0xFF7C4DFF),
                const Color(0xFF512DA8),
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    String subtitle,
    IconData icon,
    Color startColor,
    Color endColor,
  ) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 250),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: startColor.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
              spreadRadius: -2,
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => _handleCardTap(title),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(icon, color: Colors.white, size: 48),
                    ),
                    SizedBox(width: 16),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withOpacity(0.7),
                      size: 32,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
