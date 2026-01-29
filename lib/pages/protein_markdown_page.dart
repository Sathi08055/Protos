import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ProteinMarkdownPage extends StatelessWidget {
  final String title;
  final String markdownContent;

  const ProteinMarkdownPage({
    super.key,
    required this.title,
    required this.markdownContent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Markdown(
        data: markdownContent,
        styleSheet: MarkdownStyleSheet(
          h1: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          h2: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          p: const TextStyle(fontSize: 16),
        ),
        imageBuilder: (uri, title, alt) {
          // You may want to handle asset images here if needed
          return Image.asset(uri.toString());
        },
      ),
    );
  }
}
