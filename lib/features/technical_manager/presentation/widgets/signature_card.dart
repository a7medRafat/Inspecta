import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/m_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import 'signature_pad.dart';

/// "Sign here": the signature pad with its Clear button, and the
/// reviewer's full name and licence number beneath it.
class SignatureCard extends StatelessWidget {
  final List<List<double>> strokes;
  final ValueChanged<List<List<double>>> onStrokesChanged;
  final VoidCallback onClear;
  final TextEditingController nameController;
  final TextEditingController licenseController;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onLicenseChanged;
  final bool enabled;

  const SignatureCard({
    super.key,
    required this.strokes,
    required this.onStrokesChanged,
    required this.onClear,
    required this.nameController,
    required this.licenseController,
    required this.onNameChanged,
    required this.onLicenseChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: AppColours.ink.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.signHereTitle, style: AppTextStyles.cardTitle.copyWith(fontSize: 19)),
              TextButton(
                onPressed: enabled && strokes.isNotEmpty ? onClear : null,
                style: TextButton.styleFrom(
                  backgroundColor: AppColours.primarySoft,
                  foregroundColor: AppColours.primaryDark,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(t.clearAction, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 160,
            child: SignaturePad(strokes: strokes, onChanged: onStrokesChanged, enabled: enabled),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: MTextField(
                  controller: nameController,
                  onChanged: onNameChanged,
                  enabled: enabled,
                  label: t.fullNameLabel,
                  hintText: t.fullNameHint,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: MTextField(
                  controller: licenseController,
                  onChanged: onLicenseChanged,
                  enabled: enabled,
                  label: t.licenseNoLabel,
                  hintText: t.licenseNoHint,
                  textInputAction: TextInputAction.done,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
