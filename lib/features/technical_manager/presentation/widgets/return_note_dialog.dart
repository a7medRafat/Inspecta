import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

/// Asks why a certificate is going back to its inspector. Pops with the
/// trimmed reason, or `null` when cancelled; a reason is required so the
/// inspector isn't left guessing what to fix.
class ReturnNoteDialog extends StatefulWidget {
  const ReturnNoteDialog({super.key});

  static Future<String?> show(BuildContext context) => showDialog<String>(
    context: context,
    builder: (_) => const ReturnNoteDialog(),
  );

  @override
  State<ReturnNoteDialog> createState() => _ReturnNoteDialogState();
}

class _ReturnNoteDialogState extends State<ReturnNoteDialog> {
  final _controller = TextEditingController();
  bool _showError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final note = _controller.text.trim();
    if (note.isEmpty) {
      setState(() => _showError = true);
      return;
    }
    Navigator.of(context).pop(note);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(t.returnToInspectorTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.returnReasonLabel, style: AppTextStyles.fieldLabel),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: 3,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            onChanged: (_) {
              if (_showError) setState(() => _showError = false);
            },
            decoration: InputDecoration(
              hintText: t.returnReasonHint,
              errorText: _showError ? t.returnReasonRequired : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColours.primaryColor, width: 2),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(t.cancel)),
        TextButton(onPressed: _submit, child: Text(t.returnConfirmAction)),
      ],
    );
  }
}
