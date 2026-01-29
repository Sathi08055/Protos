import "package:flutter/material.dart";

import '../widgets/sectioned_flow.dart';
import '../Protein Project/mark_protein_proffessor.dart';

class ProteinProfessorFlowPage extends StatelessWidget {
  const ProteinProfessorFlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionedFlowPage(
      appBarTitle: 'Protein Professor',
      sections: [
        SectionData('Introduction', proffcontent),
        SectionData('Biochemistry', Biochemistry),
        SectionData('Physical Properties', Physicalproperties),
        SectionData('Chemical Properties', ChemicalpropertiesofProtein),
        SectionData('Food Processing', Foodprocessing),
        SectionData('Analysis Methods', AnalysisMethods),
        SectionData('Outro', ProfessorOutro),
      ],
    );
  }
}
