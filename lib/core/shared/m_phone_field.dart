import 'package:flutter/material.dart';

import '../consts/app_text_styles.dart';
import 'm_text_field.dart';

/// Mobile number input: an [MTextField] with the dial code shown as a
/// trailing label.
class MPhoneField extends StatelessWidget {
  final String dialCode;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const MPhoneField({
    super.key,
    required this.dialCode,
    required this.controller,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return MTextField(
      controller: controller,
      onChanged: onChanged,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      trailing: Text(dialCode, style: AppTextStyles.caption.copyWith(fontSize: 16)),
    );
  }
}
