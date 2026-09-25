import 'package:flutter/material.dart';

import '../../../auth/presentation/pages/profile_page.dart';
import '../../../coordinator/presentation/pages/coordinator_queue_page.dart';
import '../../../coordinator/presentation/pages/coordinator_schedule_page.dart';
import '../../../coordinator/presentation/pages/inspectors_list_page.dart';
import '../../../coordinator/presentation/widgets/coordinator_bottom_nav.dart';

/// The coordinator's shell: Queue, Schedule, Inspectors and Profile —
/// same in-place-swap shape as `SupervisorRootPage`.
class CoordinatorRootPage extends StatefulWidget {
  const CoordinatorRootPage({super.key});

  @override
  State<CoordinatorRootPage> createState() => _CoordinatorRootPageState();
}

class _CoordinatorRootPageState extends State<CoordinatorRootPage> {
  CoordinatorTab _tab = CoordinatorTab.queue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab.index,
        children: [
          CoordinatorQueuePage(onOpenProfile: () => setState(() => _tab = CoordinatorTab.profile)),
          const CoordinatorSchedulePage(),
          const InspectorsListPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: CoordinatorBottomNav(
        selected: _tab,
        onSelectTab: (tab) => setState(() => _tab = tab),
      ),
    );
  }
}
