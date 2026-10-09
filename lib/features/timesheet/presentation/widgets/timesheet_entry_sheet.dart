import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/m_primary_button.dart';
import '../../../../core/utils/currency.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../quotation/presentation/widgets/price_field.dart';
import '../../domain/entities/timesheet_activity.dart';
import '../../domain/entities/timesheet_entry.dart';
import '../../domain/entities/timesheet_expense.dart';
import '../../domain/entities/timesheet_row.dart';
import 'timesheet_labels.dart';

typedef TimesheetSubmit = Future<bool> Function({
  required Map<TimesheetActivity, int> activities,
  required Map<TimesheetExpense, int> expenses,
});

/// The "Time & price" bottom sheet: how an inspector's time on a job was
/// spent — inspection, report writing, an unpaid break and so on — and what
/// they spent on transportation. The price isn't entered: it's shown as it
/// is worked out, the net working time at [hourlyRatePiastres]. Any of the
/// time or costs may be left empty, but not all of it.
class TimesheetEntrySheet extends StatefulWidget {
  final TimesheetRow row;

  /// The inspector's hourly rate, which the price is calculated from; 0 if
  /// they haven't set one yet.
  final int hourlyRatePiastres;

  /// Returns whether the save succeeded — `false` keeps the sheet open
  /// (the caller has already shown its own error) so the inspector can
  /// retry.
  final TimesheetSubmit onSubmit;

  const TimesheetEntrySheet({
    super.key,
    required this.row,
    required this.hourlyRatePiastres,
    required this.onSubmit,
  });

  /// Resolves to `true` once the entry has been saved, or `null` if the
  /// sheet was dismissed without saving.
  static Future<bool?> show(
    BuildContext context, {
    required TimesheetRow row,
    required int hourlyRatePiastres,
    required TimesheetSubmit onSubmit,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TimesheetEntrySheet(row: row, hourlyRatePiastres: hourlyRatePiastres, onSubmit: onSubmit),
    );
  }

  @override
  State<TimesheetEntrySheet> createState() => _TimesheetEntrySheetState();
}

class _TimesheetEntrySheetState extends State<TimesheetEntrySheet> {
  final _hours = {for (final a in TimesheetActivity.values) a: TextEditingController()};
  final _minutes = {for (final a in TimesheetActivity.values) a: TextEditingController()};
  final _expenseControllers = {for (final e in TimesheetExpense.values) e: TextEditingController()};
  bool _submitted = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final entry = widget.row.entry;
    if (entry == null) return;
    for (final activity in TimesheetActivity.values) {
      final total = entry.minutesOf(activity);
      if (total >= 60) _hours[activity]!.text = '${total ~/ 60}';
      if (total % 60 > 0) _minutes[activity]!.text = '${total % 60}';
    }
    for (final expense in TimesheetExpense.values) {
      if (entry.expenseOf(expense) > 0) {
        _expenseControllers[expense]!.text = Currency.toInputText(entry.expenseOf(expense));
      }
    }
  }

  @override
  void dispose() {
    for (final controller in [..._hours.values, ..._minutes.values, ..._expenseControllers.values]) {
      controller.dispose();
    }
    super.dispose();
  }

  int _minutePartOf(TimesheetActivity a) => int.tryParse(_minutes[a]!.text.trim()) ?? 0;

  int _minutesOf(TimesheetActivity a) => (int.tryParse(_hours[a]!.text.trim()) ?? 0) * 60 + _minutePartOf(a);

  bool _outOfRange(TimesheetActivity a) => _minutePartOf(a) > 59;

  /// Only the activities with time on them.
  Map<TimesheetActivity, int> get _activities => {
    for (final a in TimesheetActivity.values)
      if (_minutesOf(a) > 0) a: _minutesOf(a),
  };

  int get _elapsed => _activities.values.fold(0, (sum, minutes) => sum + minutes);

  int get _unpaidBreak => _minutesOf(TimesheetActivity.unpaidBreak);

  int _expenseOf(TimesheetExpense e) => Currency.parsePiastres(_expenseControllers[e]!.text) ?? 0;

  /// Only the expenses with an amount.
  Map<TimesheetExpense, int> get _expenses => {
    for (final e in TimesheetExpense.values)
      if (_expenseOf(e) > 0) e: _expenseOf(e),
  };

  int get _transport => _expenses.values.fold(0, (sum, piastres) => sum + piastres);

  /// What this would be saved as — built the same way the cubit builds it,
  /// so the price shown is the price saved.
  TimesheetEntry get _draft => TimesheetEntry.priced(
    requestId: widget.row.request.id,
    inspectorId: '',
    activities: _activities,
    expenses: _expenses,
    hourlyRatePiastres: widget.hourlyRatePiastres,
  );

  bool get _anyOutOfRange => TimesheetActivity.values.any(_outOfRange);

  bool get _nothingEntered => _elapsed == 0 && _transport == 0;

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (_anyOutOfRange || _nothingEntered) return;

    setState(() => _submitting = true);
    final ok = await widget.onSubmit(activities: _activities, expenses: _expenses);
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
    final request = widget.row.request;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.92),
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
              Text(t.timesheetSheetTitle, style: AppTextStyles.cardTitle.copyWith(fontSize: 18)),
              const SizedBox(height: 4),
              Text(
                '${request.equipmentTitle} · ${request.clientName}',
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: Text(t.timesheetActivitiesLabel, style: AppTextStyles.fieldLabel.copyWith(fontSize: 13))),
                  _ColumnHeading(t.hoursLabel),
                  const SizedBox(width: 8),
                  _ColumnHeading(t.minutesLabel),
                ],
              ),
              const SizedBox(height: 6),
              for (final activity in TimesheetActivity.values) ...[
                // The break is the one deduction, so it sits apart from the
                // activities that count as work.
                if (!activity.isPaid) const Divider(height: 20, color: AppColours.border),
                _ActivityRow(
                  activity: activity,
                  hours: _hours[activity]!,
                  minutes: _minutes[activity]!,
                  invalid: _submitted && _outOfRange(activity),
                  onChanged: () => setState(() {}),
                ),
              ],
              if (_submitted && _anyOutOfRange) ...[
                const SizedBox(height: 8),
                Text(
                  t.errorMinutesRange,
                  style: AppTextStyles.caption.copyWith(color: AppColours.dangerText, fontWeight: FontWeight.w600),
                ),
              ],
              if (_elapsed > 0) ...[
                const SizedBox(height: 12),
                _Summary(elapsed: _elapsed, unpaidBreak: _unpaidBreak),
              ],
              const SizedBox(height: 18),
              Text(t.timesheetExpensesLabel, style: AppTextStyles.fieldLabel.copyWith(fontSize: 13)),
              const SizedBox(height: 6),
              for (final expense in TimesheetExpense.values)
                _ExpenseRow(
                  expense: expense,
                  controller: _expenseControllers[expense]!,
                  onChanged: () => setState(() {}),
                ),
              if (_elapsed > 0 || _transport > 0) ...[
                const SizedBox(height: 16),
                _MoneySummary(entry: _draft, hourlyRatePiastres: widget.hourlyRatePiastres),
              ],
              if (_submitted && _nothingEntered) ...[
                const SizedBox(height: 10),
                Text(
                  t.errorTimeOrPriceRequired,
                  style: AppTextStyles.caption.copyWith(color: AppColours.dangerText, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 20),
              MPrimaryButton(label: t.saveAction, loading: _submitting, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColumnHeading extends StatelessWidget {
  final String label;

  const _ColumnHeading(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _boxWidth,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTextStyles.caption.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

const double _boxWidth = 72;

/// One activity: its name, and hours and minutes boxes.
class _ActivityRow extends StatelessWidget {
  final TimesheetActivity activity;
  final TextEditingController hours;
  final TextEditingController minutes;
  final bool invalid;
  final VoidCallback onChanged;

  const _ActivityRow({
    required this.activity,
    required this.hours,
    required this.minutes,
    required this.invalid,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              activity.label(t),
              style: AppTextStyles.subtitle.copyWith(
                fontWeight: FontWeight.w600,
                color: activity.isPaid ? AppColours.ink : AppColours.inkSecondary,
              ),
            ),
          ),
          _TimeBox(fieldKey: Key('${activity.name}-hours'), controller: hours, onChanged: onChanged),
          const SizedBox(width: 8),
          _TimeBox(
            fieldKey: Key('${activity.name}-minutes'),
            controller: minutes,
            invalid: invalid,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// One cost: its name, and an amount in EGP.
class _ExpenseRow extends StatelessWidget {
  final TimesheetExpense expense;
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _ExpenseRow({required this.expense, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              expense.label(t),
              style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600, color: AppColours.ink),
            ),
          ),
          SizedBox(
            width: 176,
            child: PriceField(
              key: Key('${expense.name}-cost'),
              controller: controller,
              onChanged: (_) => onChanged(),
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact two-digit whole-number box. [invalid] only recolours the
/// border: the message is shown once under the list, so a bad row doesn't
/// push the others out of alignment.
class _TimeBox extends StatelessWidget {
  final Key fieldKey;
  final TextEditingController controller;
  final bool invalid;
  final VoidCallback onChanged;

  const _TimeBox({required this.fieldKey, required this.controller, required this.onChanged, this.invalid = false});

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );

    return SizedBox(
      width: _boxWidth,
      child: TextField(
        key: fieldKey,
        controller: controller,
        onChanged: (_) => onChanged(),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
        style: AppTextStyles.input,
        decoration: InputDecoration(
          hintText: '0',
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          border: border(AppColours.border, 1.5),
          enabledBorder: border(invalid ? AppColours.errorIcon : AppColours.border, 1.5),
          focusedBorder: border(invalid ? AppColours.errorIcon : AppColours.primaryColor, 2),
        ),
      ),
    );
  }
}

/// The live calculation: everything entered, less the unpaid break, is the
/// working time.
class _Summary extends StatelessWidget {
  final int elapsed;
  final int unpaidBreak;

  const _Summary({required this.elapsed, required this.unpaidBreak});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColours.surfaceMuted, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          _SummaryLine(label: t.timesheetElapsedLabel, value: formatMinutes(t, elapsed)),
          if (unpaidBreak > 0) ...[
            const SizedBox(height: 4),
            _SummaryLine(
              label: t.timesheetActivityUnpaidBreak,
              value: '− ${formatMinutes(t, unpaidBreak)}',
              muted: true,
            ),
          ],
          const Divider(height: 16, color: AppColours.border),
          _SummaryLine(label: t.timesheetNetTimeLabel, value: formatMinutes(t, elapsed - unpaidBreak), strong: true),
        ],
      ),
    );
  }
}

/// The money: the price worked out from the net working time and the hourly
/// rate — with that working shown — the transportation costs, and what they
/// come to together. Costs get their own line so they never read as part of
/// the price.
class _MoneySummary extends StatelessWidget {
  final TimesheetEntry entry;
  final int hourlyRatePiastres;

  const _MoneySummary({required this.entry, required this.hourlyRatePiastres});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final hasRate = hourlyRatePiastres > 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColours.surfaceMuted, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryLine(label: t.priceLabel, value: Currency.formatEgp(entry.pricePiastres)),
          const SizedBox(height: 2),
          if (!hasRate)
            Text(
              t.timesheetRateMissing,
              style: AppTextStyles.caption.copyWith(color: AppColours.chipAmberText, fontWeight: FontWeight.w600),
            )
          else if (entry.minutes > 0)
            Text(
              t.timesheetPriceFormula(formatMinutes(t, entry.minutes), Currency.formatEgp(hourlyRatePiastres)),
              style: AppTextStyles.caption,
            ),
          if (entry.hasExpenses) ...[
            const SizedBox(height: 6),
            _SummaryLine(label: t.timesheetTransportationLabel, value: Currency.formatEgp(entry.expensesPiastres)),
            const Divider(height: 16, color: AppColours.border),
            _SummaryLine(label: t.timesheetTotalPriceLabel, value: Currency.formatEgp(entry.totalPiastres), strong: true),
          ],
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;
  final bool muted;

  const _SummaryLine({required this.label, required this.value, this.strong = false, this.muted = false});

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.subtitle.copyWith(
      fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
      color: strong ? AppColours.ink : (muted ? AppColours.inkMuted : AppColours.inkSecondary),
    );
    // The label gives way to the amount, so a long one wraps instead of
    // overflowing the row.
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        const SizedBox(width: 12),
        Text(value, style: style),
      ],
    );
  }
}
