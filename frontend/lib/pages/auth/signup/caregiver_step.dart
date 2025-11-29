// lib/pages/auth/signup/caregiver_step.dart
import 'package:flutter/material.dart';
import 'form_fields.dart';

class CaregiverStep extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController dobController;
  final String? gender;
  final TextEditingController childrenCountController;

  final TextEditingController mobileController;
  final TextEditingController emailController;
  final TextEditingController addressController;

  final ValueChanged<String?> onGenderChanged;
  final VoidCallback onDobTap;

  const CaregiverStep({
    super.key,
    required this.fullNameController,
    required this.dobController,
    required this.gender,
    required this.childrenCountController,
    required this.mobileController,
    required this.emailController,
    required this.addressController,
    required this.onGenderChanged,
    required this.onDobTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Parent/Caregiver Details",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFFB37A41),
            decoration: TextDecoration.underline,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Basic Information",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFFC3A27F),
          ),
        ),
        const SizedBox(height: 12),

        RoundedTextField(
          label: "Full Name",
          controller: fullNameController,
        ),
        const SizedBox(height: 12),

        RoundedDateField(
          label: "Date of Birth",
          controller: dobController,
          onTap: onDobTap,
        ),
        const SizedBox(height: 12),

        RoundedDropdown(
          label: "Gender",
          value: gender,
          items: const ["Male", "Female", "Other"],
          onChanged: onGenderChanged,
        ),
        const SizedBox(height: 12),

        RoundedTextField(
          label: "No fo Children",
          controller: childrenCountController,
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 24),
        const Text(
          "Contact Information",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFFC3A27F),
          ),
        ),
        const SizedBox(height: 12),

        RoundedTextField(
          label: "Mobile Number",
          controller: mobileController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),

        RoundedTextField(
          label: "Email",
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),

        RoundedTextField(
          label: "Address",
          controller: addressController,
          maxLines: 2,
        ),
      ],
    );
  }
}
