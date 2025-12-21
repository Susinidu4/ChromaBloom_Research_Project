import 'package:flutter/material.dart';

class ProfileEditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboard;
  final bool obscure;
  final String? helper;
  final String? Function(String?)? validator;

  const ProfileEditField({
    super.key,
    required this.label,
    required this.controller,
    required this.keyboard,
    this.obscure = false,
    this.helper,
    this.validator,
  });

  static const Color headerBlue = Color(0xFF3E6D86);
  static const Color textGold = Color(0xFFC6A36C);
  static const Color lineGold = Color(0xFFC6A36C);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textGold,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          obscureText: obscure,
          validator: validator,
          decoration: InputDecoration(
            hintText: label,
            helperText: helper,
            filled: true,
            fillColor: Colors.white.withOpacity(0.8),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: lineGold),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: lineGold.withOpacity(0.7)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: headerBlue, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileEditDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const ProfileEditDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  static const Color textGold = Color(0xFFC6A36C);
  static const Color lineGold = Color(0xFFC6A36C);

  @override
  Widget build(BuildContext context) {
    final safeValue = items.contains(value) ? value : items.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textGold,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: lineGold.withOpacity(0.7)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: safeValue,
              isExpanded: true,
              items: items
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(e[0].toUpperCase() + e.substring(1)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileDobPickerRow extends StatelessWidget {
  final String label;
  final String valueText;
  final VoidCallback onTap;

  const ProfileDobPickerRow({
    super.key,
    required this.label,
    required this.valueText,
    required this.onTap,
  });

  static const Color textGold = Color(0xFFC6A36C);
  static const Color valueTextColor = Color(0xFFB88F55);
  static const Color lineGold = Color(0xFFC6A36C);
  static const Color headerBlue = Color(0xFF3E6D86);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textGold,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: lineGold.withOpacity(0.7)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    valueText,
                    style: const TextStyle(
                      color: valueTextColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_month_rounded, color: headerBlue),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
