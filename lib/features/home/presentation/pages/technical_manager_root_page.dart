import 'package:flutter/material.dart';

import '../../../auth/presentation/pages/profile_page.dart';
import '../../../technical_manager/presentation/pages/review_queue_page.dart';
import '../../../technical_manager/presentation/pages/sent_certificates_page.dart';
import '../../../technical_manager/presentation/widgets/review_bottom_nav.dart';

/// The technical manager's shell: Review, Sent and Profile — same
/// in-place-swap shape as `CoordinatorRootPage`.
class TechnicalManagerRootPage extends StatefulWidget {
  const TechnicalManagerRootPage({super.key});

  @override
  State<TechnicalManagerRootPage> createState() => _TechnicalManagerRootPageState();
}

class _TechnicalManagerRootPageState extends State<TechnicalManagerRootPage> {
  TechnicalManagerTab _tab = TechnicalManagerTab.review;

  void _openProfile() => setState(() => _tab = TechnicalManagerTab.profile);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab.index,
        children: [
          ReviewQueuePage(onOpenProfile: _openProfile),
          SentCertificatesPage(onOpenProfile: _openProfile),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: ReviewBottomNav(
        selected: _tab,
        onSelectTab: (tab) => setState(() => _tab = tab),
      ),
    );
  }
}
