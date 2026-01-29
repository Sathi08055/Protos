import 'package:flutter/material.dart';
import 'package:testing/config/theme_config.dart';
import 'package:testing/pages/home.dart';

class SearchPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const SearchPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: currentPage > 1
              ? () => onPageChanged(currentPage - 1)
              : null,
          style: IconButton.styleFrom(
            backgroundColor: ThemeConfig.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: ThemeConfig.primary.withOpacity(0.7),
          ),
          icon: const Icon(Icons.arrow_back, size: 20),
        ),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ThemeConfig.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Page $currentPage of $totalPages',
            style: TextStyle(
              color: ThemeConfig.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),

        IconButton(
          onPressed: currentPage < totalPages
              ? () => onPageChanged(currentPage + 1)
              : null,
          style: IconButton.styleFrom(
            backgroundColor: ThemeConfig.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: ThemeConfig.primary.withOpacity(0.7),
          ),
          icon: const Icon(Icons.arrow_forward, size: 20),
        ),
      ],
    );
  }
}
