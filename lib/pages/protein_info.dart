import 'package:flutter/material.dart';
import '../Protein Project/1. proteinpeseant.dart';
import '../Protein Project/2. overconfident.dart';
import '../Protein Project/3. proteinproff.dart';
import 'protein_markdown_page.dart';

class ProteinInfoPage extends StatelessWidget {
  const ProteinInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn About Protein'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSection(
            title: 'Protein Peseant',
            icon: Icons.emoji_people,
            color: Colors.blue[100]!,
            content: 'Simple, everyday facts about protein for beginners.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProteinPeasantFlowPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Overconfident Soldier',
            icon: Icons.military_tech,
            color: Colors.blue[200]!,
            content:
                'Intermediate knowledge and common misconceptions about protein.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OverconfidentSoldierFlowPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Protein Professor',
            icon: Icons.school,
            color: Colors.blue[300]!,
            content: 'Advanced, science-backed information about protein.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProteinProfessorFlowPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required String content,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 32, color: Colors.blue[900]),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                content,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
