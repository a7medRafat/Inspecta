import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/m_primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/request_item.dart';

/// The "Complete this request" bottom sheet: location + a dynamic list of
/// equipment rows. The only in-app way to fill in the two fields a
/// request needs before it's quotable (BR-02.5) when they didn't arrive
/// with it — e.g. an email-sourced request whose body couldn't be parsed
/// into structured fields.
class CompleteRequestSheet extends StatefulWidget {
  /// Returns whether the save succeeded — `false` keeps the sheet open
  /// (the caller has already shown its own error) so the user can retry.
  final Future<bool> Function({required String location, required List<RequestItem> items}) onSubmit;

  const CompleteRequestSheet({super.key, required this.onSubmit});

  /// Resolves to `true` once the request has been successfully completed,
  /// or `null` if the sheet was dismissed without saving.
  static Future<bool?> show(
    BuildContext context, {
    required Future<bool> Function({required String location, required List<RequestItem> items}) onSubmit,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CompleteRequestSheet(onSubmit: onSubmit),
    );
  }

  @override
  State<CompleteRequestSheet> createState() => _CompleteRequestSheetState();
}

class _ItemRowControllers {
  final typeController = TextEditingController();
  final capacityController = TextEditingController();
  final quantityController = TextEditingController(text: '1');

  void dispose() {
    typeController.dispose();
    capacityController.dispose();
    quantityController.dispose();
  }
}

class _CompleteRequestSheetState extends State<CompleteRequestSheet> {
  final _locationController = TextEditingController();
  final _rows = [_ItemRowControllers()];
  bool _submitted = false;
  bool _submitting = false;

  @override
  void dispose() {
    _locationController.dispose();
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  bool get _locationMissing => _locationController.text.trim().isEmpty;

  List<RequestItem> get _validItems {
    final items = <RequestItem>[];
    for (var i = 0; i < _rows.length; i++) {
      final type = _rows[i].typeController.text.trim();
      if (type.isEmpty) continue;
      final capacity = _rows[i].capacityController.text.trim();
      items.add(
        RequestItem(
          id: 'item-${DateTime.now().microsecondsSinceEpoch}-$i',
          type: type,
          capacity: capacity.isEmpty ? null : capacity,
          quantity: int.tryParse(_rows[i].quantityController.text.trim()) ?? 1,
        ),
      );
    }
    return items;
  }

  void _addRow() => setState(() => _rows.add(_ItemRowControllers()));

  void _removeRow(int index) => setState(() {
    _rows[index].dispose();
    _rows.removeAt(index);
  });

  Future<void> _submit() async {
    setState(() => _submitted = true);
    final items = _validItems;
    if (_locationMissing || items.isEmpty) return;

    setState(() => _submitting = true);
    final ok = await widget.onSubmit(location: _locationController.text.trim(), items: items);
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
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88),
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
                  decoration: BoxDecoration(
                    color: AppColours.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Text(t.completeRequestSheetTitle, style: AppTextStyles.cardTitle.copyWith(fontSize: 18)),
              const SizedBox(height: 4),
              Text(t.completeRequestSheetSubtitle, style: AppTextStyles.caption),
              const SizedBox(height: 16),
              _Field(
                label: t.locationLabel,
                controller: _locationController,
                errorText: _submitted && _locationMissing ? t.errorLocationRequired : null,
              ),
              const SizedBox(height: 18),
              Text(t.equipmentLabel, style: AppTextStyles.fieldLabel.copyWith(fontSize: 13)),
              const SizedBox(height: 10),
              for (var i = 0; i < _rows.length; i++) ...[
                _ItemRow(
                  controllers: _rows[i],
                  errorText: _submitted && _rows[i].typeController.text.trim().isEmpty
                      ? t.errorEquipmentTypeRequired
                      : null,
                  onRemove: _rows.length > 1 ? () => _removeRow(i) : null,
                  removeLabel: t.removeItemAction,
                  typeLabel: t.equipmentTypeLabel,
                  capacityLabel: t.capacityLabel,
                  quantityLabel: t.quantityLabel,
                ),
                const SizedBox(height: 10),
              ],
              if (_submitted && _validItems.isEmpty) ...[
                Text(t.errorEquipmentRequired, style: AppTextStyles.caption.copyWith(color: AppColours.dangerText)),
                const SizedBox(height: 8),
              ],
              TextButton(
                onPressed: _addRow,
                style: TextButton.styleFrom(foregroundColor: AppColours.primaryDark),
                child: Text(t.addEquipmentItemAction),
              ),
              const SizedBox(height: 10),
              MPrimaryButton(label: t.saveAction, loading: _submitting, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final _ItemRowControllers controllers;
  final String? errorText;
  final VoidCallback? onRemove;
  final String removeLabel;
  final String typeLabel;
  final String capacityLabel;
  final String quantityLabel;

  const _ItemRow({
    required this.controllers,
    required this.removeLabel,
    required this.typeLabel,
    required this.capacityLabel,
    required this.quantityLabel,
    this.errorText,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColours.surfaceMuted, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Field(label: typeLabel, controller: controllers.typeController, errorText: errorText),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _Field(label: capacityLabel, controller: controllers.capacityController),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Field(
                  label: quantityLabel,
                  controller: controllers.quantityController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          if (onRemove != null) ...[
            const SizedBox(height: 4),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: onRemove,
                style: TextButton.styleFrom(foregroundColor: AppColours.dangerText),
                child: Text(removeLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? errorText;
  final TextInputType? keyboardType;

  const _Field({
    required this.label,
    required this.controller,
    this.errorText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.fieldLabel.copyWith(fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.input.copyWith(fontWeight: FontWeight.w400, fontSize: 15),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: Colors.white,
            errorText: errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColours.border, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
