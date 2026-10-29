import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.icon,
    this.required = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.inputFormatters,
    this.maxLength,
    this.textInputAction,
    this.onChanged,
    this.readOnly = false,
    this.decoration, // optional extra overrides, merged on top of the theme
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? icon;
  final bool required;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final InputDecoration? decoration;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final base = InputDecoration(
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
      counterText: maxLength == null ? null : '', // hide the "0/10" counter
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(required ? '$label *' : label,
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters, // passed straight through
          maxLength: maxLength,
          maxLines: maxLines,
          textInputAction: textInputAction,
          onChanged: onChanged,
          readOnly: readOnly,
          textCapitalization: textCapitalization,
          validator: validator ??
              (required
                  ? (v) => (v == null || v.trim().isEmpty)
                      ? '$label is required'
                      : null
                  : null),
          decoration: decoration == null
              ? base
              : base.copyWith(
                  hintText: decoration!.hintText ?? hint,
                  fillColor: decoration!.fillColor,
                  focusedBorder: decoration!.focusedBorder,
                ),
        ),
      ],
    );
  }
}