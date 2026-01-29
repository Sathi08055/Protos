import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SectionData {
  final String title;
  final String Function() contentBuilder;
  SectionData(this.title, this.contentBuilder);
}

class SectionedFlowPage extends StatefulWidget {
  final List<SectionData> sections;
  final String appBarTitle;
  const SectionedFlowPage({
    super.key,
    required this.sections,
    required this.appBarTitle,
  });

  @override
  State<SectionedFlowPage> createState() => _SectionedFlowPageState();
}

class _SectionedFlowPageState extends State<SectionedFlowPage> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant SectionedFlowPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scrollController.jumpTo(0);
    _isAtBottom = false;
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final atBottom =
          _scrollController.offset >=
          _scrollController.position.maxScrollExtent - 8;
      if (atBottom != _isAtBottom) {
        setState(() {
          _isAtBottom = atBottom;
        });
      }
    }
  }

  void _nextSection() {
    if (_currentIndex < widget.sections.length - 1) {
      setState(() {
        _currentIndex++;
        _scrollController.jumpTo(0);
        _isAtBottom = false;
      });
    }
  }

  void _prevSection() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _scrollController.jumpTo(0);
        _isAtBottom = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final section = widget.sections[_currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text(section.title),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                '${_currentIndex + 1}/${widget.sections.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Markdown(
                key: ValueKey(_currentIndex),
                controller: _scrollController,
                data: section.contentBuilder(),
                styleSheet: MarkdownStyleSheet(
                  h1: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  h2: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  h3: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  p: const TextStyle(fontSize: 16),
                ),
                imageBuilder: (uri, title, alt) {
                  // Defensive: If asset not found or error, show placeholder
                  try {
                    return Image.asset(
                      uri.toString(),
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          height: 150,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.red,
                              size: 48,
                            ),
                          ),
                        );
                      },
                    );
                  } catch (e) {
                    return Container(
                      color: Colors.grey[200],
                      height: 150,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.red,
                          size: 48,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const Divider(height: 1),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _currentIndex > 0 ? _prevSection : null,
                        child: const Text('Previous'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _currentIndex < widget.sections.length - 1
                          ? ElevatedButton(
                              onPressed: _nextSection,
                              child: const Text('Next'),
                            )
                          : ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Finish'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
