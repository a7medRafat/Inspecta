import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

/// A confirm dialog with an optional reason before declining a task.
/// Returns `null` if cancelled, otherwise the (possibly empty) reason.
Future<String?> showDeclineTaskDialog(BuildContext context) {
  final t = AppLocalizations.of(context)!;
  final controller = TextEditingController();
  return showAdaptiveDialog<String?>(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: Text(t.declineTaskTitle),
      content: TextField(
        controller: controller,
        maxLines: 2,
        style: AppTextStyles.input.copyWith(fontWeight: FontWeight.w400, fontSize: 15),
        decoration: InputDecoration(
          isDense: true,
          hintText: t.declineReasonHint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColours.border, width: 1.5),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          style: TextButton.styleFrom(foregroundColor: AppColours.errorIcon),
          child: Text(t.declineAction),
        ),
      ],
    ),
  );
}
