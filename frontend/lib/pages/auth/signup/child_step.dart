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

  // ========= NEW: Therapist selection (now OPTIONAL) =========
  /// Therapist ID or name selected
  final String? selectedTherapist;

  /// List of therapist options to show in dropdown
  /// (e.g. ["Dr. A - t-0001", "Dr. B - t-0002"])
  final List<String>? therapistOptions;

  /// Callback when therapist is changed
  final ValueChanged<String?>? onTherapistChanged;

  // ========= NEW: Other health conditions (now OPTIONAL) =========
  final bool hasHeartIssues;
  final bool hasThyroidIssues;
  final bool hasHearingProblems;
  final bool hasVisionProblems;

  final ValueChanged<bool?>? onHeartIssuesChanged;
  final ValueChanged<bool?>? onThyroidChanged;
  final ValueChanged<bool?>? onHearingChanged;
  final ValueChanged<bool?>? onVisionChanged;

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

    // NEW (optional, so older code still compiles)
    this.selectedTherapist,
    this.therapistOptions,
    this.onTherapistChanged,
    this.hasHeartIssues = false,
    this.hasThyroidIssues = false,
    this.hasHearingProblems = false,
    this.hasVisionProblems = false,
    this.onHeartIssuesChanged,
    this.onThyroidChanged,
    this.onHearingChanged,
    this.onVisionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> therapistItems = therapistOptions ?? const [];

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
          label: "Height (cm)",
          controller: heightController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),

        RoundedTextField(
          label: "Weight (kg)",
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
          label: "Down Syndrome Confirmed by",
          value: downSyndromeConfirmedBy,
          items: const [
            "Pediatrician",
            "Neurologist",
            "Geneticist",
            "Other",
          ],
          onChanged: onConfirmedByChanged,
        ),

        const SizedBox(height: 20),

        // ============= OTHER HEALTH CONDITIONS =============
        const Text(
          "Other Health Conditions",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFFB37A41),
            decoration: TextDecoration.underline,
          ),
        ),
        const SizedBox(height: 8),

        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text("Heart Issues"),
          value: hasHeartIssues,
          onChanged: onHeartIssuesChanged ?? (_) {},
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text("Thyroid Problems"),
          value: hasThyroidIssues,
          onChanged: onThyroidChanged ?? (_) {},
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text("Hearing Problems"),
          value: hasHearingProblems,
          onChanged: onHearingChanged ?? (_) {},
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text("Vision Problems"),
          value: hasVisionProblems,
          onChanged: onVisionChanged ?? (_) {},
        ),

        const SizedBox(height: 20),

        // ============= THERAPIST SELECTION =============
        const Text(
          "Assigned Therapist",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFFB37A41),
            decoration: TextDecoration.underline,
          ),
        ),
        const SizedBox(height: 8),

        RoundedDropdown(
          label: "Select Therapist",
          value: selectedTherapist,
          items: therapistItems,
          onChanged: onTherapistChanged ?? (_) {},
        ),
      ],
    );
  }
}
