import 'package:flutter/material.dart';

import '../../../auth/presentation/pages/profile_page.dart';
import '../../../clients/presentation/pages/clients_list_page.dart';
import '../../../quotation/presentation/pages/quotations_list_page.dart';
import '../../../requests/presentation/pages/requests_inbox_page.dart';
import '../../../requests/presentation/widgets/requests_bottom_nav.dart';

/// The supervisor's shell: Requests, Quotations and Clients are real
/// tabs that swap in place in the same Scaffold, with the bottom bar
/// staying put and tracking which one's active — not separate pushed
/// screens. Profile is a push, not a tab.
class SupervisorRootPage extends StatefulWidget {
  const SupervisorRootPage({super.key});

  @override
  State<SupervisorRootPage> createState() => _SupervisorRootPageState();
}

class _SupervisorRootPageState extends State<SupervisorRootPage> {
  SupervisorTab _tab = SupervisorTab.requests;

  void _openProfile() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ProfilePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps every tab's state (scroll position, the
      // streams already subscribed) alive when switching, instead of
      // rebuilding from scratch each time.
      body: IndexedStack(
        index: _tab.index,
        children: const [RequestsInboxPage(), QuotationsListPage(), ClientsListPage()],
      ),
      bottomNavigationBar: RequestsBottomNav(
        selected: _tab,
        onSelectTab: (tab) => setState(() => _tab = tab),
        onProfile: _openProfile,
      ),
    );
  }
}
