import 'package:flutter/material.dart';
import '../widgets/sectioned_flow.dart';
import '../Protein Project/mark_overconfident.dart';

void main() {}

class OverconfidentSoldierFlowPage extends StatelessWidget {
  const OverconfidentSoldierFlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionedFlowPage(
      appBarTitle: 'Overconfident Soldier',
      sections: [
        SectionData('Introduction', overconfidentSoldierIntro),
        SectionData('History', history),
        SectionData('Amino Acids', aminoacids),
        SectionData('Digestion & Absorption', protein_digestion),
        SectionData('Protein Types & Quality', protientypes),
        SectionData('Protein Timing & Distribution', protein_timing),
        SectionData('Lifestyle Goals', lifestylegoals),
        SectionData('Myths', Proteinmyths),
        SectionData('Outro', Overconfident_outro),
      ],
    );
  }
}
