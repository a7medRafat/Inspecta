import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/m_primary_button.dart';
import '../../../../core/utils/currency.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../quotation/presentation/widgets/price_field.dart';

/// Sets the inspector's hourly rate, which every price on their timesheet is
/// worked out from.
class HourlyRateSheet extends StatefulWidget {
  /// The rate in piastres right now; 0 if none has been set.
  final int initialRatePiastres;

  /// Returns whether the save succeeded — `false` keeps the sheet open (the
  /// caller has already shown its own error) so the inspector can retry.
  final Future<bool> Function(int hourlyRatePiastres) onSubmit;

  const HourlyRateSheet({super.key, required this.initialRatePiastres, required this.onSubmit});

  /// Resolves to `true` once the rate has been saved, or `null` if the
  /// sheet was dismissed without saving.
  static Future<bool?> show(
    BuildContext context, {
    required int initialRatePiastres,
    required Future<bool> Function(int hourlyRatePiastres) onSubmit,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HourlyRateSheet(initialRatePiastres: initialRatePiastres, onSubmit: onSubmit),
    );
  }

  @override
  State<HourlyRateSheet> createState() => _HourlyRateSheetState();
}

class _HourlyRateSheetState extends State<HourlyRateSheet> {
  late final _controller = TextEditingController(
    text: widget.initialRatePiastres > 0 ? Currency.toInputText(widget.initialRatePiastres) : '',
  );
  bool _submitted = false;
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _ratePiastres => Currency.parsePiastres(_controller.text) ?? 0;

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (_ratePiastres <= 0) return;

    setState(() => _submitting = true);
    final ok = await widget.onSubmit(_ratePiastres);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: AppColours.border, borderRadius: BorderRadius.circular(999)),
                ),
              ),
              Text(t.hourlyRateSheetTitle, style: AppTextStyles.cardTitle.copyWith(fontSize: 18)),
              const SizedBox(height: 4),
              Text(t.hourlyRateSheetHint, style: AppTextStyles.caption),
              const SizedBox(height: 18),
              Text(t.hourlyRateLabel, style: AppTextStyles.fieldLabel.copyWith(fontSize: 13)),
              const SizedBox(height: 6),
              PriceField(
                controller: _controller,
                onChanged: (_) => setState(() {}),
                errorText: _submitted && _ratePiastres <= 0 ? t.errorHourlyRateRequired : null,
              ),
              const SizedBox(height: 20),
              MPrimaryButton(label: t.saveAction, loading: _submitting, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
