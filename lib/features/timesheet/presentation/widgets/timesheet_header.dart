import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/framework/mtoast.dart';
import '../../../../core/utils/currency.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/timesheet_cubit.dart';
import 'hourly_rate_sheet.dart';
import 'timesheet_labels.dart';

/// The Timesheet tab's blue header: title, the month switcher, and what
/// the inspector has logged that month — total price and total time.
class TimesheetHeader extends StatelessWidget {
  const TimesheetHeader({super.key});

  Future<void> _editRate(BuildContext context, int current) async {
    final cubit = context.read<TimesheetCubit>();
    final t = AppLocalizations.of(context)!;
    await HourlyRateSheet.show(
      context,
      initialRatePiastres: current,
      onSubmit: (rate) async {
        final failure = await cubit.saveHourlyRate(rate);
        if (failure != null) {
          MToast.showError(message: failure.message(t));
          return false;
        }
        MToast.showSuccess(message: t.hourlyRateSavedMessage);
        return true;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 20, 20, 18),
      decoration: const BoxDecoration(
        color: AppColours.primaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t.timesheetTitle, style: AppTextStyles.pageTitle.copyWith(color: Colors.white, fontSize: 24)),
          const SizedBox(height: 16),
          BlocBuilder<TimesheetCubit, TimesheetState>(
            builder: (context, state) {
              final cubit = context.read<TimesheetCubit>();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MonthSwitcher(month: state.selectedMonth, onPrevious: cubit.previousMonth, onNext: cubit.nextMonth),
                  const SizedBox(height: 14),
                  // Stretch both tiles to the taller one, so the total's note
                  // doesn't leave the time tile shorter.
                  IntrinsicHeight(
                    child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _StatTile(
                          label: t.timesheetTotalPriceLabel,
                          value: Currency.formatEgp(state.totalPiastres),
                          // Costs are part of the total but not of the price, so
                          // say how much of it they are.
                          note: state.totalExpensesPiastres > 0
                              ? t.timesheetIncludingTransportation(Currency.formatEgp(state.totalExpensesPiastres))
                              : null,
                          emphasised: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: _StatTile(
                          label: t.timesheetTimeLoggedLabel,
                          value: state.totalMinutes == 0 ? t.durationHours(0) : formatMinutes(t, state.totalMinutes),
                        ),
                      ),
                    ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _RateRow(
                    hourlyRatePiastres: state.hourlyRatePiastres,
                    onTap: () => _editRate(context, state.hourlyRatePiastres),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// The inspector's hourly rate — what every price below is worked out from —
/// tappable to change it, or a prompt to set one if they haven't.
class _RateRow extends StatelessWidget {
  final int hourlyRatePiastres;
  final VoidCallback onTap;

  const _RateRow({required this.hourlyRatePiastres, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final hasRate = hourlyRatePiastres > 0;
    return Material(
      color: Colors.white.withValues(alpha: hasRate ? 0.16 : 0.28),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.payments_outlined, size: 18, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasRate
                      ? '${t.hourlyRateLabel} · ${t.hourlyRatePerHour(Currency.formatEgp(hourlyRatePiastres))}'
                      : t.hourlyRateSetPrompt,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.emphasis.copyWith(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              Icon(hasRate ? Icons.edit_outlined : Icons.chevron_right_rounded, size: 18, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthSwitcher extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthSwitcher({required this.month, required this.onPrevious, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    return Container(
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            tooltip: t.previousMonthTooltip,
            icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
          ),
          Expanded(
            child: Text(
              DateFormat('MMMM yyyy', locale).format(month),
              textAlign: TextAlign.center,
              style: AppTextStyles.emphasis.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            onPressed: onNext,
            tooltip: t.nextMonthTooltip,
            icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  /// A smaller line under the label.
  final String? note;
  final bool emphasised;

  const _StatTile({required this.label, required this.value, this.note, this.emphasised = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: emphasised ? Colors.white : Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // A long month total would otherwise overflow its tile.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: emphasised ? AppColours.primaryDark : Colors.white,
              ),
            ),
          ),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: emphasised ? AppColours.inkSecondary : AppColours.onPrimaryMuted,
            ),
          ),
          if (note != null)
            Text(
              note!,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                color: emphasised ? AppColours.inkMuted : AppColours.onPrimaryMuted,
              ),
            ),
        ],
      ),
    );
  }
}
