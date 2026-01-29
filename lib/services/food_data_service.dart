import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../pages/search_function.dart';

class FoodDataService {
  static FoodDataService? _instance;
  bool _isInitialized = false;

  // Filter settings
  Set<String>? _selectedCategories;
  Set<String>? _selectedSources;
  List<String>? _allCategories;
  List<String>? _allSources;

  FoodDataService._();

  static FoodDataService get instance {
    _instance ??= FoodDataService._();
    return _instance!;
  }

  // Add getters for current filter state
  Set<String>? getCurrentCategories() => _selectedCategories;
  Set<String>? getCurrentSources() => _selectedSources;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load both CSVs
      final rawData1 = await rootBundle.loadString('assets/Full values.csv');
      final rawData2 = await rootBundle.loadString('assets/indian_food.csv');
      final listData1 = const CsvToListConverter().convert(rawData1);
      final listData2 = const CsvToListConverter().convert(rawData2);

      final categories = <String>{};
      final sources = <String>{};

      // Helper to extract from a CSV
      void extract(List<List<dynamic>> listData) {
        if (listData.isEmpty) return;
        final headers = listData[0];
        final categoryIndex = headers.indexOf('Category');
        final sourceIndex = headers.indexOf('Source');
        if (categoryIndex != -1 && sourceIndex != -1) {
          for (var i = 1; i < listData.length; i++) {
            final row = listData[i];
            if (row.length > categoryIndex) {
              categories.add(row[categoryIndex].toString());
            }
            if (row.length > sourceIndex) {
              sources.add(row[sourceIndex].toString());
            }
          }
        }
      }
      extract(listData1);
      extract(listData2);

      _allCategories = categories.toList()..sort();
      _allSources = sources.toList()..sort();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing FoodDataService: $e');
      rethrow;
    }
  }

  void setSelectedCategories(Set<String>? categories) {
    _selectedCategories = categories?.isEmpty == true ? null : categories;
  }

  void setSelectedSources(Set<String>? sources) {
    _selectedSources = sources?.isEmpty == true ? null : sources;
  }

  void resetFilters() {
    _selectedCategories = null;
    _selectedSources = null;
  }

  bool hasActiveFilters() {
    return (_selectedCategories?.isNotEmpty ?? false) ||
        (_selectedSources?.isNotEmpty ?? false);
  }

  Future<bool> _testFilter(
    String query, {
    bool testCategory = false,
    bool testSource = false,
  }) async {
    final tempCategories = testCategory ? null : _selectedCategories;
    final tempSources = testSource ? null : _selectedSources;

    final results = await searchFood(
      query,
      page: 1,
      useCategories: tempCategories,
      useSources: tempSources,
    );

    return results.items.isNotEmpty;
  }

  Future<void> autoAdjustFilters(String query) async {
    if (!hasActiveFilters()) return;

    // Test if removing category filter would give results
    if (_selectedCategories != null) {
      final hasResultsWithoutCategory = await _testFilter(
        query,
        testCategory: true,
      );
      if (hasResultsWithoutCategory) {
        _selectedCategories = null;
      }
    }

    // Test if removing source filter would give results
    if (_selectedSources != null) {
      final hasResultsWithoutSource = await _testFilter(
        query,
        testSource: true,
      );
      if (hasResultsWithoutSource) {
        _selectedSources = null;
      }
    }
  }

  // Updated search method with pagination
  Future<SearchResult> searchFood(
    String query, {
    int page = 1,
    Set<String>? useCategories,
    Set<String>? useSources,
  }) async {
    if (!_isInitialized) {
      await initialize(); // Auto-initialize if not already
    }

    // Use override filters if provided, otherwise use instance filters
    final categories = useCategories ?? _selectedCategories;
    final sources = useSources ?? _selectedSources;

    final items = await searchFoodItems(
      query,
      selectedCategories: categories,
      selectedSources: sources,
    );

    final itemsPerPage = 25;
    final totalItems = items.length;
    final totalPages = (totalItems / itemsPerPage).ceil();
    final startIndex = (page - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;

    return SearchResult(
      items: items.skip(startIndex).take(itemsPerPage).toList(),
      currentPage: page,
      totalPages: totalPages,
      totalItems: totalItems,
    );
  }

  Future<Map<String, dynamic>> getNutrientData(String foodId) async {
    if (!_isInitialized) {
      await initialize(); // Auto-initialize if not already
    }
    try {
      print('Loading CSV data for food ID: $foodId');
      final String csvData = await rootBundle.loadString(
        'assets/Full values.csv',
      );
      print('CSV data loaded successfully');

      final List<List<dynamic>> csvTable = const CsvToListConverter().convert(
        csvData,
      );
      print('CSV converted to table. Header row length: ${csvTable[0].length}');
      // Find the row with matching food ID
      final headerRow = csvTable[0];
      final idIndex = headerRow.indexOf('ID');
      if (idIndex == -1) throw Exception('ID column not found in CSV');

      print('Found ID column at index: $idIndex');
      print('First few headers: ${headerRow.take(5)}');
      print('Searching for food ID: $foodId');

      final foodRow = csvTable.firstWhere(
        (row) => row[idIndex].toString() == foodId,
        orElse: () => throw Exception('Food not found: $foodId'),
      ); // Create a map of nutrient name to value
      final nutrientData = <String, dynamic>{};

      if (foodRow.length != headerRow.length) {
        throw Exception(
          'Food row has ${foodRow.length} columns but header has ${headerRow.length} columns',
        );
      }

      print('Found food row. Converting values to map...');
      for (var i = 0; i < headerRow.length; i++) {
        final header = headerRow[i].toString();
        final value = foodRow[i];

        // Convert numeric values to double
        if (value != null && value.toString().isNotEmpty) {
          try {
            nutrientData[header] = double.parse(value.toString());
          } catch (e) {
            nutrientData[header] = value.toString();
          }
        }
      }

      print(
        'Successfully created nutrient data map with ${nutrientData.length} entries',
      );
      return nutrientData;
    } catch (e) {
      print('Error in getNutrientData: $e');
      throw Exception('Failed to get nutrient data: ${e.toString()}');
    }
  }

  Future<List<String>> getCategories() async {
    await initialize();
    return _allCategories ?? [];
  }

  Future<List<String>> getSources() async {
    await initialize();
    return _allSources ?? [];
  }

  // Add a cache clearing method
  void clearCache() {
    // Reset any cached filter or data state
    _selectedCategories = null;
    _selectedSources = null;
    _allCategories = null;
    _allSources = null;
    _isInitialized = false;
  }
}
