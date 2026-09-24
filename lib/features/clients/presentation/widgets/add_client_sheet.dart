import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/m_primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/client_contact.dart';

/// The "Add client" bottom sheet: company + location + a starting
/// contact, marked main. Not in the design mockup (which only shows the
/// button), so styled to match the app's other input sheets
/// ([LogClientReplySheet]) rather than a specific reference.
class AddClientSheet extends StatefulWidget {
  final Future<void> Function({
    required String companyName,
    required String location,
    required ClientContact mainContact,
  })
  onSubmit;

  const AddClientSheet({super.key, required this.onSubmit});

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function({
      required String companyName,
      required String location,
      required ClientContact mainContact,
    })
    onSubmit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddClientSheet(onSubmit: onSubmit),
    );
  }

  @override
  State<AddClientSheet> createState() => _AddClientSheetState();
}

class _AddClientSheetState extends State<AddClientSheet> {
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _roleController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _submitted = false;
  bool _submitting = false;

  @override
  void dispose() {
    _companyController.dispose();
    _locationController.dispose();
    _contactNameController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool get _companyMissing => _companyController.text.trim().isEmpty;
  bool get _locationMissing => _locationController.text.trim().isEmpty;
  bool get _contactNameMissing => _contactNameController.text.trim().isEmpty;

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (_companyMissing || _locationMissing || _contactNameMissing) return;

    setState(() => _submitting = true);
    await widget.onSubmit(
      companyName: _companyController.text.trim(),
      location: _locationController.text.trim(),
      mainContact: ClientContact(
        name: _contactNameController.text.trim(),
        role: _roleController.text.trim().isEmpty ? null : _roleController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        isMain: true,
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
              Text(t.addClientSheetTitle, style: AppTextStyles.cardTitle.copyWith(fontSize: 18)),
              const SizedBox(height: 16),
              _Field(
                label: t.companyNameLabel,
                controller: _companyController,
                errorText: _submitted && _companyMissing ? t.errorCompanyNameRequired : null,
              ),
              const SizedBox(height: 12),
              _Field(
                label: t.locationLabel,
                controller: _locationController,
                errorText: _submitted && _locationMissing ? t.errorLocationRequired : null,
              ),
              const SizedBox(height: 12),
              _Field(
                label: t.contactNameLabel,
                controller: _contactNameController,
                errorText: _submitted && _contactNameMissing ? t.errorContactNameRequired : null,
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
