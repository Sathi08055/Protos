import 'package:flutter/material.dart';
import 'package:testing/pages/nutrient_details_page.dart';
import 'package:testing/pages/search_function.dart';
import 'package:testing/services/food_data_service.dart';
import 'package:testing/config/theme_config.dart';
import 'package:testing/widgets/search_filters.dart';
import 'package:testing/widgets/search_pagination.dart';
import 'package:testing/pages/food_nutrition.dart';

class ResultPage extends StatefulWidget {
  final String searchQuery;
  final Set<String>? categories;
  final Set<String>? sources;

  const ResultPage({
    super.key,
    required this.searchQuery,
    this.categories,
    this.sources,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  SearchResult? searchResult;
  bool isLoading = true;
  String? error;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    // Reset any previous filters when entering the page
    FoodDataService.instance.resetFilters();
    // Set the initial filters from the widget parameters
    if (widget.categories != null) {
      FoodDataService.instance.setSelectedCategories(widget.categories);
    }
    if (widget.sources != null) {
      FoodDataService.instance.setSelectedSources(widget.sources);
    }
    _performSearch();
  }

  @override
  void dispose() {
    // Reset filters when leaving the page
    FoodDataService.instance.resetFilters();
    super.dispose();
  }

  Future<void> _performSearch() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      await FoodDataService.instance.initialize();
      final results = await FoodDataService.instance.searchFood(
        widget.searchQuery,
        page: currentPage,
        useCategories: widget.categories,
        useSources: widget.sources,
      );

      setState(() {
        searchResult = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to search for foods: ${e.toString()}';
        isLoading = false;
      });
      print('Error in ResultPage: $e');
    }
  }

  @override
  void didUpdateWidget(ResultPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      // Reset everything when search query changes
      FoodDataService.instance.resetFilters();
      setState(() {
        currentPage = 1;
      });
      _performSearch();
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      currentPage = page;
    });
    _performSearch();
  }

  void _onCategoriesChanged(Set<String>? categories) {
    FoodDataService.instance.setSelectedCategories(categories);
    setState(() {
      currentPage = 1; // Reset to first page when filter changes
    });
    _performSearch();
  }

  void _onSourcesChanged(Set<String>? sources) {
    FoodDataService.instance.setSelectedSources(sources);
    setState(() {
      currentPage = 1; // Reset to first page when filter changes
    });
    _performSearch();
  }

  void _onFoodItemTap(FoodItem food) async {
    print('FoodItem tapped: ID = \'${food.id}\''); // Debug print
    try {
      if (int.tryParse(food.id) != null && int.parse(food.id) < 10000) {
        final nutrientData = await FoodDataService.instance.getNutrientData(
          food.id,
        );
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NutrientDetailsPage(
              food: food,
              nutrients: nutrientData,
              showAddButton: false,
            ),
          ),
        );
      } else {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodNutritionPage(foodId: food.id),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading nutrient data: \'${e.toString()}\'')),
      );
    }
  }

  Widget _buildFoodItem(FoodItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.95)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: ThemeConfig.primary.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: ThemeConfig.primary, width: 4),
              ),
            ),
            child: ListTile(
              onTap: () => _onFoodItemTap(item),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              title: Text(
                '${item.name}',
                style: TextStyle(
                  color: ThemeConfig.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    'Category: ${item.category}',
                    style: TextStyle(
                      color: ThemeConfig.navInactive,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.source,
                    style: TextStyle(
                      color: ThemeConfig.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Reset filters before going back
        FoodDataService.instance.resetFilters();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Search Results: "${widget.searchQuery}"'),
          backgroundColor: ThemeConfig.primary,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Reset filters and go back
              FoodDataService.instance.resetFilters();
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Column(
          children: [
            SearchFilters(
              onCategoriesChanged: _onCategoriesChanged,
              onSourcesChanged: _onSourcesChanged,
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                  ? Center(child: Text(error!))
                  : searchResult == null || searchResult!.items.isEmpty
                  ? const Center(child: Text('No results found'))
                  : _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount:
                searchResult!.items.length +
                (searchResult!.totalPages > 1
                    ? 1
                    : 0), // Add extra item for pagination
            itemBuilder: (context, index) {
              if (index < searchResult!.items.length) {
                return _buildFoodItem(searchResult!.items[index]);
              } else {
                // Pagination at the end of the list
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Divider(
                        height: 1,
                        color: ThemeConfig.primary.withOpacity(0.1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: SearchPagination(
                          currentPage: currentPage,
                          totalPages: searchResult!.totalPages,
                          onPageChanged: _onPageChanged,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).padding.bottom),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
