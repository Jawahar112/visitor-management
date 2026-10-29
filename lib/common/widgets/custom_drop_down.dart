import 'package:flutter/material.dart';

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
    this.hint,
    this.icon,
    this.required = false,
    this.validator,
    this.decoration,
    this.labelAlignment = CrossAxisAlignment.start,
    this.valueAlignment = AlignmentDirectional.centerStart,
    this.itemAlignment = AlignmentDirectional.centerStart,
    this.isExpanded = true,
    this.menuMaxHeight,
    this.borderRadius,
    this.dropdownColor,
    this.itemLabel,
  });

  final String label;
  final List<T> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final IconData? icon;
  final bool required;
  final String? Function(T?)? validator;
  final InputDecoration? decoration;

  final CrossAxisAlignment labelAlignment;

  final AlignmentGeometry valueAlignment;

  final AlignmentGeometry itemAlignment;

  final bool isExpanded;
  final double? menuMaxHeight;
  final BorderRadius? borderRadius;
  final Color? dropdownColor;

  final String Function(T item)? itemLabel;

  @override
  Widget build(BuildContext context) {
    final base = InputDecoration(
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
    );

    String labelOf(T item) => itemLabel?.call(item) ?? item.toString();

    return Column(
      crossAxisAlignment: labelAlignment,
      children: [
        Text(required ? '$label *' : label,
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: isExpanded,
          alignment: valueAlignment,
          menuMaxHeight: menuMaxHeight,
          borderRadius: borderRadius,
          dropdownColor: dropdownColor,
          onChanged: onChanged,
          items: items
              .map((e) => DropdownMenuItem<T>(
                    value: e,
                    alignment: itemAlignment, // each item in the menu
                    child: Text(labelOf(e), overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          validator: validator ??
              (required
                  ? (v) => v == null ? '$label is required' : null
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