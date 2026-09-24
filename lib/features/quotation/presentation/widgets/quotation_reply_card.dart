import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/m_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/reply_type.dart';
import '../bloc/quotation_form_cubit.dart';
import 'price_field.dart';
import 'reply_option_tile.dart';

/// Feature 03 §5's "Reply panel (on Request detail)": Accept / Offer
/// price / Reject, with the offer's price, validity, and message fields.
class QuotationReplyCard extends StatefulWidget {
  const QuotationReplyCard({super.key});

  @override
  State<QuotationReplyCard> createState() => _QuotationReplyCardState();
}

class _QuotationReplyCardState extends State<QuotationReplyCard> {
  final _priceController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _priceController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cubit = context.watch<QuotationFormCubit>();
    final state = cubit.state;

    return MCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t.howDoYouWantToReply, style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
          const SizedBox(height: 12),
          ReplyOptionTile(
            title: t.replyAccept,
            subtitle: t.replyAcceptSubtitle,
            selected: state.replyType == ReplyType.accept,
            onTap: () => cubit.selectReplyType(ReplyType.accept),
          ),
          const SizedBox(height: 10),
          ReplyOptionTile(
            title: t.replyOffer,
            subtitle: t.replyOfferSubtitle,
            selected: state.replyType == ReplyType.offer,
            onTap: () => cubit.selectReplyType(ReplyType.offer),
          ),
          const SizedBox(height: 10),
          ReplyOptionTile(
            title: t.replyReject,
            subtitle: t.replyRejectSubtitle,
            danger: true,
            selected: state.replyType == ReplyType.reject,
            onTap: () => cubit.selectReplyType(ReplyType.reject),
          ),
          if (state.replyType == ReplyType.offer) ...[
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t.pricePerUnit, style: AppTextStyles.fieldLabel.copyWith(fontSize: 13)),
                      const SizedBox(height: 6),
                      PriceField(
                        controller: _priceController,
                        onChanged: cubit.changePrice,
                        errorText: state.showPriceError ? t.errorPriceRequired : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t.validFor, style: AppTextStyles.fieldLabel.copyWith(fontSize: 13)),
                      const SizedBox(height: 6),
                      _ValidityDropdown(
                        value: state.validityDays,
                        onChanged: cubit.changeValidity,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (state.replyType == ReplyType.offer || state.replyType == ReplyType.reject) ...[
            const SizedBox(height: 14),
            _MessageField(
              controller: _messageController,
              required: state.replyType == ReplyType.reject,
              hasError: state.showReasonError,
              onChanged: cubit.changeMessage,
            ),
          ],
        ],
      ),
    );
  }
}

class _ValidityDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _ValidityDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColours.border, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isExpanded: true,
          style: AppTextStyles.input,
          items: [14, 30]
              .map(
                (days) => DropdownMenuItem(
                  value: days,
                  child: Text(t.validityDaysOption(days)),
                ),
              )
              .toList(),
          onChanged: (days) {
            if (days != null) onChanged(days);
          },
        ),
      ),
    );
  }
}

class _MessageField extends StatelessWidget {
  final TextEditingController controller;
  final bool required;
  final bool hasError;
  final ValueChanged<String> onChanged;

  const _MessageField({
    required this.controller,
    required this.required,
    required this.hasError,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final label = required ? t.reasonToClient : '${t.messageToClient} (${t.optionalLabel})';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.fieldLabel.copyWith(fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          minLines: 2,
          maxLines: 4,
          style: AppTextStyles.input.copyWith(fontWeight: FontWeight.w400),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.all(12),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColours.border, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? AppColours.errorIcon : AppColours.border,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? AppColours.errorIcon : AppColours.primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            t.errorReasonRequired,
            style: AppTextStyles.caption.copyWith(
              color: AppColours.errorIcon,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
