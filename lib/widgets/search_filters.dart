import 'package:flutter/material.dart';
import 'package:testing/services/food_data_service.dart';
import 'package:testing/config/theme_config.dart';

class SearchFilters extends StatefulWidget {
  final Function(Set<String>?) onCategoriesChanged;
  final Function(Set<String>?) onSourcesChanged;

  const SearchFilters({
    super.key,
    required this.onCategoriesChanged,
    required this.onSourcesChanged,
  });

  @override
  State<SearchFilters> createState() => _SearchFiltersState();
}

class _SearchFiltersState extends State<SearchFilters> {
  List<String> categories = [];
  List<String> sources = [];
  String? selectedCategory;
  String? selectedSource;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    try {
      final foodService = FoodDataService.instance;
      await foodService.initialize();
      final categoriesList = await foodService.getCategories();
      final sourcesList = await foodService.getSources();

      // Get the current filter state from FoodDataService
      final currentCategories = foodService.getCurrentCategories();
      final currentSources = foodService.getCurrentSources();

      setState(() {
        categories = categoriesList;
        sources = sourcesList;
        selectedCategory = currentCategories?.first;
        selectedSource = currentSources?.first;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading filters: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    final String allText = hint == 'Category'
        ? 'All Categories'
        : 'All Sources';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeConfig.primary.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            value: value,
            hint: Text(hint, style: TextStyle(color: ThemeConfig.primary)),
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: ThemeConfig.primary),
            borderRadius: BorderRadius.circular(12),
            menuMaxHeight: 300,
            dropdownColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            style: TextStyle(color: ThemeConfig.secondary, fontSize: 14),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(
                  allText,
                  style: TextStyle(
                    color: ThemeConfig.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...items.map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, maxLines: 2),
                ),
              ),
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      selectedCategory = category;
    });
    widget.onCategoriesChanged(category != null ? {category} : null);
  }

  void _onSourceChanged(String? source) {
    setState(() {
      selectedSource = source;
    });
    widget.onSourcesChanged(source != null ? {source} : null);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: ThemeConfig.primary.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown(
              hint: 'Category',
              value: selectedCategory,
              items: categories,
              onChanged: _onCategoryChanged,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDropdown(
              hint: 'Source',
              value: selectedSource,
              items: sources,
              onChanged: _onSourceChanged,
            ),
          ),
        ],
      ),
    );
  }
}
