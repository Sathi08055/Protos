import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:testing/config/theme_config.dart';
import 'package:testing/pages/nutrient_details_page.dart';
import 'package:testing/pages/search_function.dart';
import 'package:testing/services/food_data_service.dart';

class AddIngredientPage extends StatefulWidget {
  const AddIngredientPage({super.key});

  @override
  State<AddIngredientPage> createState() => _AddIngredientPageState();
}

class _AddIngredientPageState extends State<AddIngredientPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<FoodItem> searchResults = [];
  int currentPage = 1;
  int totalPages = 1;
  bool isLoading = false;
  String lastQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch([String? query, int page = 1]) async {
    setState(() {
      isLoading = true;
    });
    final q = query ?? _searchController.text;
    lastQuery = q;
    await FoodDataService.instance.initialize();
    final result = await FoodDataService.instance.searchFood(q, page: page);
    setState(() {
      searchResults = result.items;
      currentPage = result.currentPage;
      totalPages = result.totalPages;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Ingredient'),
        backgroundColor: ThemeConfig.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
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
                  hintText: 'Search for ingredients...',
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
                              searchResults = [];
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
                  // Optionally, implement live search
                },
                onSubmitted: (value) => _performSearch(value),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            if (isLoading) const Center(child: CircularProgressIndicator()),
            if (!isLoading && searchResults.isNotEmpty)
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final filteredResults = searchResults
                              .where(
                                (item) =>
                                    item.source !=
                                    "Indian Nutrient Databank (INDB)",
                              )
                              .toList();
                          return ListView.builder(
                            itemCount: filteredResults.length,
                            itemBuilder: (context, index) {
                              final foodItem = filteredResults[index];
                              return Column(
                                children: [
                                  ListTile(
                                    title: Text(foodItem.name),
                                    subtitle: Text(
                                      'Category: ${foodItem.category}\nSource: ${foodItem.source}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    isThreeLine: true,
                                    onTap: () async {
                                      // Fetch real nutrient data for the selected food
                                      final nutrients = await FoodDataService
                                          .instance
                                          .getNutrientData(foodItem.id);
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              NutrientDetailsPage(
                                                food: foodItem,
                                                nutrients: nutrients,
                                                showAddButton: true,
                                              ),
                                        ),
                                      );
                                      if (result != null && result is Map) {
                                        Navigator.of(context).pop(result);
                                      }
                                    },
                                  ),
                                  const Divider(height: 1, thickness: 1),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: currentPage > 1
                              ? () => _performSearch(lastQuery, currentPage - 1)
                              : null,
                        ),
                        Text('Page $currentPage of $totalPages'),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: currentPage < totalPages
                              ? () => _performSearch(lastQuery, currentPage + 1)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 32,
                    ), // Add space after pagination row
                  ],
                ),
              ),
            if (!isLoading &&
                searchResults.isEmpty &&
                _searchController.text.isEmpty)
              const Expanded(
                child: Align(
                  alignment: Alignment.topCenter, // Align animation to the top
                  child: LottieWidget(),
                ),
              ),
            if (!isLoading &&
                searchResults.isEmpty &&
                _searchController.text.isNotEmpty)
              const Expanded(child: Center(child: Text('No results found.'))),
          ],
        ),
      ),
    );
  }
}

class LottieWidget extends StatelessWidget {
  const LottieWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/Searchanimation.json',
      width: 400, // Increased width for zoom effect
      height: 400, // Increased height for zoom effect
      repeat: true,
    );
  }
}
