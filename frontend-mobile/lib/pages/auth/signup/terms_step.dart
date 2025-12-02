// lib/pages/auth/signup/terms_step.dart
import 'package:flutter/material.dart';

class TermsStep extends StatelessWidget {
  final bool acceptedTerms;
  final bool acceptedPrivacy;
  final ValueChanged<bool> onTermsChanged;
  final ValueChanged<bool> onPrivacyChanged;

  const TermsStep({
    super.key,
    required this.acceptedTerms,
    required this.acceptedPrivacy,
    required this.onTermsChanged,
    required this.onPrivacyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Terms & Conditions",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFFB37A41),
            decoration: TextDecoration.underline,
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          "Please read and accept our Terms & Conditions and Privacy Policy "
          "to continue using ChromaBloom.",
          style: TextStyle(
            fontSize: 13,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),

        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          activeColor: const Color(0xFFC89B62),
          value: acceptedTerms,
          onChanged: (v) => onTermsChanged(v ?? false),
          title: const Text(
            "I agree to the Terms & Conditions.",
            style: TextStyle(fontSize: 13),
          ),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          activeColor: const Color(0xFFC89B62),
          value: acceptedPrivacy,
          onChanged: (v) => onPrivacyChanged(v ?? false),
          title: const Text(
            "I agree to the Privacy Policy.",
            style: TextStyle(fontSize: 13),
          ),
        ),

        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset: const Offset(0, 4),
                color: Colors.black.withOpacity(0.06),
              ),
            ],
          ),
          child: const Text(
            "You can withdraw your consent at any time by contacting our "
            "support team. Your data will be handled according to ethical "
            "and legal standards.",
            style: TextStyle(fontSize: 12.5, height: 1.4),
          ),
        ),
      ],
    );
  }
}
