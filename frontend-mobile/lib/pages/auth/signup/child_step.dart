// lib/pages/auth/signup/child_step.dart
import 'package:flutter/material.dart';
import 'form_fields.dart';

class ChildStep extends StatelessWidget {
  final TextEditingController childNameController;
  final TextEditingController childDobController;
  final String? childGender;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final String? downSyndromeType;
  final String? downSyndromeConfirmedBy;

  final ValueChanged<String?> onGenderChanged;
  final VoidCallback onDobTap;
  final ValueChanged<String?> onDownTypeChanged;
  final ValueChanged<String?> onConfirmedByChanged;

  const ChildStep({
    super.key,
    required this.childNameController,
    required this.childDobController,
    required this.childGender,
    required this.heightController,
    required this.weightController,
    required this.downSyndromeType,
    required this.downSyndromeConfirmedBy,
    required this.onGenderChanged,
    required this.onDobTap,
    required this.onDownTypeChanged,
    required this.onConfirmedByChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Child Details",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFFB37A41),
            decoration: TextDecoration.underline,
          ),
        ),
        const SizedBox(height: 16),

        RoundedTextField(
          label: "Child Name",
          controller: childNameController,
        ),
        const SizedBox(height: 12),

        RoundedDateField(
          label: "Child Date of Birth",
          controller: childDobController,
          onTap: onDobTap,
        ),
        const SizedBox(height: 12),

        RoundedDropdown(
          label: "Gender",
          value: childGender,
          items: const ["Male", "Female", "Other"],
          onChanged: onGenderChanged,
        ),
        const SizedBox(height: 12),

        RoundedTextField(
          label: "Height",
          controller: heightController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),

        RoundedTextField(
          label: "Weight",
          controller: weightController,
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 24),
        const Text(
          "Medical Information",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFFB37A41),
            decoration: TextDecoration.underline,
          ),
        ),
        const SizedBox(height: 12),

        RoundedDropdown(
          label: "Down Syndrome Type",
          value: downSyndromeType,
          items: const [
            "Trisomy 21",
            "Mosaic",
            "Translocation",
            "Not Confirmed",
            "Other",
          ],
          onChanged: onDownTypeChanged,
        ),
        const SizedBox(height: 12),

        RoundedDropdown(
          label: "Down Syndrome Conformed by",
          value: downSyndromeConfirmedBy,
          items: const [
            "Pediatrician",
            "Neurologist",
            "Geneticist",
            "Other",
          ],
          onChanged: onConfirmedByChanged,
        ),
      ],
    );
  }
}
