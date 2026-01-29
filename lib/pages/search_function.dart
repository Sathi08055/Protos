import 'dart:math' show min;
import 'dart:isolate';
import 'package:csv/csv.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart'; // Import Material package for navigation
import 'nutrient_details_page.dart'; // Import for Indian food nutrition page
import 'food_nutrition.dart'; // Import for Full values nutrition page
import '../services/food_data_service.dart';

class FoodItem {
  final String name;
  final String id;
  final String category;
  final String source;

  FoodItem({
    required this.name,
    required this.id,
    required this.category,
    required this.source,
  });

  // Add fromMap constructor for isolate communication
  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      name: map['name'] as String,
      id: map['id'] as String,
      category: map['category'] as String,
      source: map['source'] as String,
    );
  }

  // Add toMap method for isolate communication
  Map<String, dynamic> toMap() {
    return {'name': name, 'id': id, 'category': category, 'source': source};
  }

  @override
  String toString() {
    return 'Name: $name\nCategory: $category\nSource: $source\n';
  }
}

// Search result class for pagination
class SearchResult {
  final List<FoodItem> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  SearchResult({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });
}

// Message class for isolate communication with filters
class SearchMessage {
  final String query;
  final String csvData;
  final Set<String>? selectedCategories;
  final Set<String>? selectedSources;

  SearchMessage(
    this.query,
    this.csvData, {
    this.selectedCategories,
    this.selectedSources,
  });
}

class _SearchResult {
  final String item;
  final double score;

  _SearchResult({required this.item, required this.score});
}

class _FuzzySearcher {
  double _calculateContainsScore(String item, List<String> words) {
    var totalScore = 0.0;
    final itemWords = _tokenize(item);

    for (final searchWord in words) {
      var bestWordScore = 0.0;

      // Check each word in the item
      for (final itemWord in itemWords) {
        // Get similarity score between the words
        final similarity = itemWord.similarityTo(searchWord);

        // If words are very similar (handle typos)
        if (similarity > 0.75) {
          bestWordScore = similarity;
          break;
        }
        // If the item word contains the search word or vice versa
        else if (itemWord.contains(searchWord) ||
            searchWord.contains(itemWord)) {
          bestWordScore = 0.8;
          break;
        }
      }
      totalScore += bestWordScore;
    }

    return totalScore / words.length;
  }

  double _calculatePrefixScore(String item, List<String> words) {
    var totalScore = 0.0;
    final itemWords = _tokenize(item);

    for (final searchWord in words) {
      var bestPrefixScore = 0.0;

      for (final itemWord in itemWords) {
        // Check if either word starts with the other
        if (itemWord.startsWith(searchWord) ||
            searchWord.startsWith(itemWord)) {
          bestPrefixScore = 1.0;
          break;
        }

        // Check for similar prefixes (handle typos at start of word)
        final minLength = min(itemWord.length, searchWord.length);
        if (minLength >= 3) {
          final itemPrefix = itemWord.substring(0, minLength);
          final searchPrefix = searchWord.substring(0, minLength);
          final prefixSimilarity = itemPrefix.similarityTo(searchPrefix);

          if (prefixSimilarity > 0.8) {
            bestPrefixScore = prefixSimilarity;
            break;
          }
        }
      }
      totalScore += bestPrefixScore;
    }

    return totalScore / words.length;
  }

  double _calculateWordMatchScore(String item, List<String> words) {
    final itemWords = _tokenize(item).toSet();
    var totalScore = 0.0;

    for (final searchWord in words) {
      var bestMatchScore = 0.0;

      for (final itemWord in itemWords) {
        // Exact match
        if (itemWord == searchWord) {
          bestMatchScore = 1.0;
          break;
        }

        // Similar word match (handle typos and spelling variations)
        final similarity = itemWord.similarityTo(searchWord);
        if (similarity > bestMatchScore) {
          bestMatchScore = similarity;
        }

        // Handle plural forms and common variations
        if (itemWord.endsWith('s') &&
            itemWord.substring(0, itemWord.length - 1) == searchWord) {
          bestMatchScore = 0.9;
          break;
        }
        if (searchWord.endsWith('s') &&
            searchWord.substring(0, searchWord.length - 1) == itemWord) {
          bestMatchScore = 0.9;
          break;
        }
      }

      totalScore += bestMatchScore;
    }

    return totalScore / words.length;
  }

  String _normalizeText(String text) {
    // Lowercase, remove diacritics, and split on spaces and special chars
    final normalized = text
        .toLowerCase()
        .replaceAll(RegExp(r'[\u0300-\u036f]'), '') // Remove diacritics
        .replaceAll(
          RegExp(r'[\[\]{}()\\/|,;\-]'),
          ' ',
        ) // Split on special chars
        .replaceAll(RegExp(r'[\s]+'), ' ') // Collapse whitespace
        .trim();
    return normalized;
  }

  List<String> _tokenize(String text) {
    // Split on spaces and special characters
    return text
        .split(RegExp(r'[\s\\/|,;\-()\[\]{}]'))
        .where((t) => t.isNotEmpty)
        .toList();
  }

  List<_SearchResult> search(String query, List<String> items) {
    if (query.isEmpty) return [];

    final normalizedQuery = _normalizeText(query);
    final queryWords = _tokenize(normalizedQuery);

    final results = items
        .map((item) {
          final normalizedItem = _normalizeText(item);

          // Calculate scores with optimized weights
          final similarityScore = normalizedItem.similarityTo(normalizedQuery);
          final containsScore = _calculateContainsScore(
            normalizedItem,
            queryWords,
          );
          final prefixScore = _calculatePrefixScore(normalizedItem, queryWords);
          final wordMatchScore = _calculateWordMatchScore(
            normalizedItem,
            queryWords,
          );

          // Combine scores with adjusted weights (favor typo tolerance)
          final finalScore =
              (similarityScore * 0.40 + // More weight for overall similarity
              containsScore * 0.20 +
              prefixScore * 0.10 +
              wordMatchScore * 0.30); // More weight for word match

          return _SearchResult(item: item, score: finalScore);
        })
        .where(
          (result) => result.score > 0.13,
        ) // Lowered threshold for typo tolerance
        .toList();

    // If no results, return top 5 closest matches regardless of threshold
    if (results.isEmpty) {
      final fallback = items.map((item) {
        final normalizedItem = _normalizeText(item);
        final similarityScore = normalizedItem.similarityTo(normalizedQuery);
        final containsScore = _calculateContainsScore(
          normalizedItem,
          queryWords,
        );
        final prefixScore = _calculatePrefixScore(normalizedItem, queryWords);
        final wordMatchScore = _calculateWordMatchScore(
          normalizedItem,
          queryWords,
        );
        final finalScore =
            (similarityScore * 0.40 +
            containsScore * 0.20 +
            prefixScore * 0.10 +
            wordMatchScore * 0.30);
        return _SearchResult(item: item, score: finalScore);
      }).toList();
      fallback.sort((a, b) => b.score.compareTo(a.score));
      return fallback.take(5).toList();
    }

    // Sort by score (descending) and then alphabetically
    results.sort((a, b) {
      final scoreDiff = b.score.compareTo(a.score);
      if (scoreDiff.abs() < 0.1) {
        return a.item.compareTo(b.item);
      }
      return scoreDiff;
    });

    return results;
  }
}

// Isolate entry point
Future<List<Map<String, dynamic>>> _isolateSearch(SearchMessage message) async {
  final listData = const CsvToListConverter().convert(message.csvData);
  if (listData.isEmpty) return [];

  final headers = listData[0];
  final nameIndex = headers.indexOf('Name');
  final idIndex = headers.indexOf('ID');
  final categoryIndex = headers.indexOf('Category');
  final sourceIndex = headers.indexOf('Source'); // Changed back to 'Source'

  if (nameIndex == -1 ||
      idIndex == -1 ||
      categoryIndex == -1 ||
      sourceIndex == -1) {
    return [];
  }

  // Pre-filter items based on category and source
  final filteredItems = listData.skip(1).where((row) {
    if (message.selectedCategories != null &&
        message.selectedCategories!.isNotEmpty &&
        !message.selectedCategories!.contains(row[categoryIndex].toString())) {
      return false;
    }
    if (message.selectedSources != null &&
        message.selectedSources!.isNotEmpty &&
        !message.selectedSources!.contains(row[sourceIndex].toString())) {
      return false;
    }
    return true;
  }).toList();

  // If there's no search query, return filtered items directly (paginated)
  if (message.query.trim().isEmpty) {
    return filteredItems
        .take(40)
        .map(
          (row) => {
            'name': row[nameIndex].toString(),
            'id': row[idIndex].toString(),
            'category': row[categoryIndex].toString(),
            'source': row[sourceIndex].toString(),
            'matchHighlight': '',
            'score': 1.0,
          },
        )
        .toList();
  }

  // Prepare items for fuzzy search
  final cleanedItems = filteredItems
      .map((row) => row[nameIndex].toString())
      .where((desc) => desc.isNotEmpty)
      .toList();

  final searcher = _FuzzySearcher();
  final searchResults = searcher
      .search(message.query.trim(), cleanedItems)
      .map((result) {
        final index = cleanedItems.indexOf(result.item);
        if (index >= 0 && index < filteredItems.length) {
          // Highlight the matching part for UI
          final name = filteredItems[index][nameIndex].toString();
          final query = message.query.trim().toLowerCase();
          final nameLower = name.toLowerCase();
          int matchStart = nameLower.indexOf(query);
          String highlight = '';
          if (matchStart >= 0) {
            highlight = name.substring(matchStart, matchStart + query.length);
          }
          return {
            'name': name,
            'id': filteredItems[index][idIndex].toString(),
            'category': filteredItems[index][categoryIndex].toString(),
            'source': filteredItems[index][sourceIndex].toString(),
            'matchHighlight': highlight,
            'score': result.score,
          };
        }
        return null;
      })
      .where((item) => item != null)
      .cast<Map<String, dynamic>>()
      .toList();

  // Deduplicate by ID, keeping the highest score
  final Map<String, Map<String, dynamic>> deduped = {};
  for (final item in searchResults) {
    final id = item['id'] as String;
    if (!deduped.containsKey(id) ||
        (item['score'] as double) > (deduped[id]!['score'] as double)) {
      deduped[id] = item;
    }
  }

  // Sort by score (descending), then alphabetically
  final sorted = deduped.values.toList()
    ..sort((a, b) {
      final scoreDiff = (b['score'] as double).compareTo(a['score'] as double);
      if (scoreDiff.abs() < 0.1) {
        return (a['name'] as String).compareTo(b['name'] as String);
      }
      return scoreDiff;
    });

  // Return top 50 for pagination
  return sorted.take(50).toList();
}

class _CsvCache {
  static String? fullValuesCsv;
  static String? indianFoodCsv;
  static bool loaded = false;

  static Future<void> load() async {
    if (!loaded) {
      fullValuesCsv = await rootBundle.loadString('assets/Full values.csv');
      indianFoodCsv = await rootBundle.loadString('assets/indian_food.csv');
      loaded = true;
    }
  }
}

Future<List<FoodItem>> searchFoodItems(
  String query, {
  Set<String>? selectedCategories,
  Set<String>? selectedSources,
}) async {
  if (query.trim().isEmpty &&
      selectedCategories == null &&
      selectedSources == null) {
    return [];
  }

  try {
    // Load both CSVs into cache if not already loaded
    await _CsvCache.load();
    final rawData1 = _CsvCache.fullValuesCsv!;
    final rawData2 = _CsvCache.indianFoodCsv!;

    // Helper to parse CSV to list of maps
    List<Map<String, String>> parseCsv(String raw) {
      final rows = const CsvToListConverter().convert(raw);
      if (rows.isEmpty) return [];
      final headers = rows[0].map((h) => h.toString().trim()).toList();
      return rows.skip(1).where((row) => row.length == headers.length).map((
        row,
      ) {
        return Map<String, String>.fromIterables(
          headers,
          row.map((v) => v.toString().trim()),
        );
      }).toList();
    }

    final list1 = parseCsv(rawData1);
    final list2 = parseCsv(rawData2);
    final mergedList = [...list1, ...list2];

    // Convert mergedList back to CSV string for the search logic
    final allHeaders = ['Name', 'ID', 'Category', 'Source'];
    final mergedCsvRows = [
      allHeaders,
      ...mergedList.map((row) => allHeaders.map((h) => row[h] ?? '').toList()),
    ];
    final mergedCsv = const ListToCsvConverter().convert(mergedCsvRows);

    // Create receive port for isolate communication
    final receivePort = ReceivePort();

    // Spawn isolate
    await Isolate.spawn(
      (message) async {
        final SendPort sendPort = message[0] as SendPort;
        final SearchMessage searchMessage = message[1] as SearchMessage;

        // Perform search in isolate
        final results = await _isolateSearch(searchMessage);

        // Send results back
        sendPort.send(results);
      },
      [
        receivePort.sendPort,
        SearchMessage(
          query,
          mergedCsv,
          selectedCategories: selectedCategories,
          selectedSources: selectedSources,
        ),
      ],
    );

    // Wait for isolate to complete and send results
    final List<Map<String, dynamic>> results = await receivePort.first;

    // Convert results back to FoodItem objects
    return results.map((map) => FoodItem.fromMap(map)).toList();
  } catch (e) {
    print('Error searching food items: $e');
    return [];
  }
}

class ResultPage extends StatelessWidget {
  final List<FoodItem> results;
  const ResultPage({Key? key, required this.results}) : super(key: key);

  void _onFoodItemTap(BuildContext context, FoodItem food) async {
    final idNum = int.tryParse(food.id);
    if (idNum != null && idNum > 10000) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoodNutritionPage(foodId: food.id),
        ),
      );
    } else if (idNum != null && idNum <= 10000) {
      // Load nutrients for Indian food from CSV and map to expected keys
      try {
        final csvString = await DefaultAssetBundle.of(
          context,
        ).loadString('assets/indian_food.csv');
        final lines = csvString
            .split('\n')
            .where((l) => l.trim().isNotEmpty)
            .toList();
        final headers = lines.first.split(',').map((h) => h.trim()).toList();
        final row = lines
            .skip(1)
            .map((line) => line.split(','))
            .firstWhere(
              (cols) => cols.length > 1 && cols[1].trim() == food.id,
              orElse: () => [],
            );
        if (row.isEmpty) throw Exception('Food not found');
        final map = Map<String, String>.fromIterables(
          headers,
          row.map((v) => v.trim()),
        );
        // Map Indian food CSV fields to expected keys for NutrientDetailsPage
        final nutrients = <String, dynamic>{
          'Protein': double.tryParse(map['protein_g'] ?? '') ?? 0.0,
          'Total lipid (fat)': double.tryParse(map['fat_g'] ?? '') ?? 0.0,
          'Carbohydrate, by difference':
              double.tryParse(map['carb_g'] ?? '') ?? 0.0,
          'Fiber, total dietary': double.tryParse(map['fibre_g'] ?? '') ?? 0.0,
          'Water': double.tryParse(map['Water'] ?? '') ?? 0.0,
          'Energy (kcal)': double.tryParse(map['Energy Kcal'] ?? '') ?? 0.0,
          'Ash,Alcohol and others': 0.0, // Not available in Indian CSV
          // Add more mappings as needed
        };
        // Add amino acids if present
        for (final acid in [
          'Tryptophan',
          'Threonine',
          'Methionine',
          'Phenylalanine',
          'Tyrosine',
          'Valine',
          'Glycine',
          'Proline',
          'Alanine',
          'Glutamic acid',
          'Lysine',
          'Isoleucine',
          'Leucine',
          'Cystine',
          'Serine',
          'Aspartic acid',
          'Histidine',
          'Arginine',
        ]) {
          if (map.containsKey(acid)) {
            nutrients[acid] = double.tryParse(map[acid] ?? '') ?? 0.0;
          }
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                NutrientDetailsPage(food: food, nutrients: nutrients),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading nutrient data: \\${e.toString()}'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid food item.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final food = results[index];
        return ListTile(
          title: Text(food.name),
          subtitle: Text('Category: ${food.category}\nSource: ${food.source}'),
          onTap: () => _onFoodItemTap(context, food),
        );
      },
    );
  }
}
