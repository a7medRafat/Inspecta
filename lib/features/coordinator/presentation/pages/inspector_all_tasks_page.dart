import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/m_back_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import '../widgets/inspector_task_row.dart';

/// The "See all" destination from an inspector's detail screen — every
/// job still ahead of them, not just the next couple.
class InspectorAllTasksPage extends StatelessWidget {
  final String inspectorName;
  final List<InspectionRequest> tasks;

  const InspectorAllTasksPage({super.key, required this.inspectorName, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColours.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColours.border)),
              ),
              child: Row(
                children: [
                  const MBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(t.allTasksTitle, style: AppTextStyles.cardTitle.copyWith(fontSize: 18)),
                        Text(inspectorName, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: tasks.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) => InspectorTaskRow(task: tasks[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
