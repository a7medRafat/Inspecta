import 'package:flutter/material.dart';

import '../consts/app_colors.dart';
import '../consts/app_text_styles.dart';

/// Reusable outlined text field shared by every form input (email,
/// password, phone, ...): optional [label] above, an optional leading
/// [prefixIcon], a blue border plus soft ring while focused, and a red
/// border with [errorText] underneath when set. [trailing] renders an optional suffix inside the
/// same box (a dial code, a show/hide toggle, etc.).
class MTextField extends StatefulWidget {
  static const double height = 54;

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool obscureText;
  final String? errorText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? trailing;

  const MTextField({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.obscureText = false,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.autofillHints,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.trailing,
  });

  @override
  State<MTextField> createState() => _MTextFieldState();
}

class _MTextFieldState extends State<MTextField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() => setState(() {});

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focusNode.hasFocus;
    final hasError = widget.errorText != null;
    final borderColor = hasError
        ? AppColours.errorIcon
        : focused
        ? AppColours.primaryColor
        : AppColours.border;

    final field = Container(
      width: double.infinity,
      height: MTextField.height,
      padding: EdgeInsetsDirectional.only(
        start: 14,
        end: widget.trailing != null ? 6 : 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: focused ? 2 : 1.5),
        boxShadow: focused && !hasError
            ? const [BoxShadow(color: AppColours.primaryTint, spreadRadius: 4)]
            : null,
      ),
      child: Row(
        children: [
          if (widget.prefixIcon != null) ...[
            Icon(widget.prefixIcon, size: 20, color: AppColours.inkMuted),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              enabled: widget.enabled,
              focusNode: _focusNode,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              autofillHints: widget.autofillHints,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: AppColours.primaryColor,
              style: AppTextStyles.input,
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
                hintText: widget.hintText,
                hintStyle: AppTextStyles.input.copyWith(
                  color: AppColours.inkMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          if (widget.trailing != null) ...[
            const SizedBox(width: 10),
            widget.trailing!,
          ],
        ],
      ),
    );

    if (widget.label == null && !hasError) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTextStyles.fieldLabel),
          const SizedBox(height: 8),
        ],
        field,
        if (hasError) ...[
          const SizedBox(height: 6),
          Semantics(
            liveRegion: true,
            child: Text(
              widget.errorText!,
              style: AppTextStyles.caption.copyWith(
                color: AppColours.errorIcon,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
