import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/m_primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/client_contact.dart';

/// The Contacts section's "+ Add" bottom sheet.
class AddContactSheet extends StatefulWidget {
  final Future<void> Function(ClientContact contact) onSubmit;

  const AddContactSheet({super.key, required this.onSubmit});

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function(ClientContact contact) onSubmit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddContactSheet(onSubmit: onSubmit),
    );
  }

  @override
  State<AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<AddContactSheet> {
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _submitted = false;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool get _nameMissing => _nameController.text.trim().isEmpty;

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (_nameMissing) return;

    setState(() => _submitting = true);
    await widget.onSubmit(
      ClientContact(
        name: _nameController.text.trim(),
        role: _roleController.text.trim().isEmpty ? null : _roleController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      ),
    );
    if (mounted) Navigator.of(context).pop();
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
                  decoration: BoxDecoration(
                    color: AppColours.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Text(t.addContactSheetTitle, style: AppTextStyles.cardTitle.copyWith(fontSize: 18)),
              const SizedBox(height: 16),
              _Field(
                label: t.contactNameLabel,
                controller: _nameController,
                errorText: _submitted && _nameMissing ? t.errorContactNameRequired : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _Field(label: t.roleLabel, controller: _roleController)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Field(
                      label: t.phoneLabel,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Field(
                label: t.emailLabel,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),
              MPrimaryButton(label: t.createAction, loading: _submitting, onPressed: _submit),
            ],
          ),
        ),
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
