import 'package:flutter/material.dart';

import '../../../auth/presentation/pages/profile_page.dart';
import '../../../inspector/presentation/pages/inspector_certificates_page.dart';
import '../../../inspector/presentation/pages/inspector_map_page.dart';
import '../../../inspector/presentation/pages/inspector_tasks_page.dart';
import '../../../inspector/presentation/widgets/inspector_bottom_nav.dart';

/// The inspector's shell: Tasks, Certificates and Map are real tabs —
/// same in-place-swap shape as `CoordinatorRootPage`.
class InspectorRootPage extends StatefulWidget {
  const InspectorRootPage({super.key});

  @override
  State<InspectorRootPage> createState() => _InspectorRootPageState();
}

class _InspectorRootPageState extends State<InspectorRootPage> {
  InspectorTab _tab = InspectorTab.tasks;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab.index,
        children: [
          const InspectorTasksPage(),
          const InspectorCertificatesPage(),
          const InspectorMapPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: InspectorBottomNav(
        selected: _tab,
        onSelectTab: (tab) => setState(() => _tab = tab),
      ),
    );
  }
}
