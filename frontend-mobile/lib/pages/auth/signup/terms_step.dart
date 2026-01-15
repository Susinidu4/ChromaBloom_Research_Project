import 'package:flutter/material.dart';

class TermsStep extends StatelessWidget {
  final bool acceptedPurpose;
  final bool acceptedDataUsage;
  final bool acceptedTerms;

  final ValueChanged<bool> onPurposeChanged;
  final ValueChanged<bool> onDataUsageChanged;
  final ValueChanged<bool> onTermsChanged;

  const TermsStep({
    super.key,
    required this.acceptedPurpose,
    required this.acceptedDataUsage,
    required this.acceptedTerms,
    required this.onPurposeChanged,
    required this.onDataUsageChanged,
    required this.onTermsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        const Center(
          child: Text(
            "Terms & Conditions",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFFB37A41),
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFFB37A41),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          "Welcome to ChromaBloom, an AI-driven support system designed to help "
          "caregivers and children with Down Syndrome. By using this app, you agree "
          "to the following Terms & Conditions.",
          style: TextStyle(fontSize: 13, color: Color(0xFFBD9A6B), height: 1.6),
        ),
        SizedBox(height: 18),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 4),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFBD9A6B), width: 1.2),
            ),
          ),
          child: const Text(
            "1. Purpose of the App",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFBD9A6B),
            ),
          ),
        ),

        SizedBox(height: 6),

        Text(
          "ChromaBloom is developed as a research-based digital tool to support:",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        SizedBox(height: 8),
        Text(
          "• Cognitive development and learning",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        Text(
          "• Daily routine management",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        Text(
          "• Caregiver well-being and stress monitoring",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        Text(
          "• AI-based developmental insights",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        SizedBox(height: 8),
        Text(
          "The app does not provide medical or clinical advice.",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),

        SizedBox(height: 22),

        Container(
          width: double.infinity, // 🔥 makes underline stretch
          padding: const EdgeInsets.only(bottom: 4),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFBD9A6B), width: 1.2),
            ),
          ),
          child: const Text(
            "2. Voluntary Participation",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFBD9A6B),
            ),
          ),
        ),

        SizedBox(height: 6),

        Text(
          "Your use of the app is voluntary. You may stop using the app at any time "
          "without any consequences.",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),

        SizedBox(height: 22),

        Container(
          width: double.infinity, // 🔥 makes underline stretch
          padding: const EdgeInsets.only(bottom: 4),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFBD9A6B), width: 1.2),
            ),
          ),
          child: const Text(
            "3. Data We Collect",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFBD9A6B),
            ),
          ),
        ),

        SizedBox(height: 6),

        Text(
          "Depending on the features you use, the app may collect:",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),

        SizedBox(height: 8),

        Text(
          "• Basic caregiver details",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        Text(
          "• Routine and activity logs",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        Text(
          "• App usage data",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        Text(
          "• Stress / journal inputs (optional)",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        Text(
          "• Child development observations",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        Text(
          "• Optional images of child activities (faces will not be identifiable)",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),

        SizedBox(height: 8),

        Text(
          "No medical tests or invasive procedures are useds.",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),

        const SizedBox(height: 22),

        Container(
          width: double.infinity, // 🔥 makes underline stretch
          padding: const EdgeInsets.only(bottom: 4),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFBD9A6B), width: 1.2),
            ),
          ),
          child: const Text(
            "4. How Your Data Is Used",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFBD9A6B),
            ),
          ),
        ),

        SizedBox(height: 6),
        Text(
          "Your data will be used to:",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        SizedBox(height: 8),
        Text(
          "• Personalize recommendations",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        Text(
          "• Improve the child’s learning and routines",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        Text(
          "• Generate stress insights for caregivers",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        Text(
          "• Support research on digital tools for Down syndrome care",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        SizedBox(height: 8),
        Text(
          "All data is anonymized for research and academic analysis.",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),

        const SizedBox(height: 22),

        Container(
          width: double.infinity, // 🔥 makes underline stretch
          padding: const EdgeInsets.only(bottom: 4),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFBD9A6B), width: 1.2),
            ),
          ),
          child: const Text(
            "5. Confidentiality & Security",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFBD9A6B),
            ),
          ),
        ),

        SizedBox(height: 6),

        Text(
          "We take confidentiality seriously:",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),

        SizedBox(height: 8),

        Text(
          "• All personal data is encrypted and stored securely.",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        Text(
          "• Only authorized research team members can access de-identified data.",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        Text(
          "• No personal identities will be shared with third parties.",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),

        const SizedBox(height: 22),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 4),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFBD9A6B), width: 1.2),
            ),
          ),
          child: const Text(
            "6. Risks & Limitations",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFBD9A6B),
            ),
          ),
        ),

        SizedBox(height: 6),

        Text(
          "There are no physical risks. However, minor emotional discomfort may occur when reflecting on stress or caregiving tasks.",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        Text(
          "The app does not replace medical professionals, diagnosis, or therapy.",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),

        const SizedBox(height: 22),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 4),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFBD9A6B), width: 1.2),
            ),
          ),
          child: const Text(
            "7. Age & Responsibility",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFBD9A6B),
            ),
          ),
        ),

        SizedBox(height: 6),

        Text(
          "• Caregivers must be 18 years or older to use the app.",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        Text(
          "• All child-related data must be entered by a parent or legal guardian.",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),

        const SizedBox(height: 22),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 4),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFBD9A6B), width: 1.2),
            ),
          ),
          child: const Text(
            "8. User Responsibilities",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFBD9A6B),
            ),
          ),
        ),

        SizedBox(height: 6),
        Text(
          "By using the app, you agree to:",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),

        SizedBox(height: 8),

        Text(
          "• Provide accurate information to improve recommendations.",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        Text(
          "• Use the app for lawful and ethical purposes.",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        Text(
          "• Avoid uploading identifiable photos of children.",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),

        const SizedBox(height: 22),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 4),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFBD9A6B), width: 1.2),
            ),
          ),
          child: const Text(
            "9. Withdrawal & Data Removal",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFBD9A6B),
            ),
          ),
        ),

        SizedBox(height: 6),

        Text(
          "You may stop using the app at any time.",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        Text(
          "If you wish to delete your data, you may contact the research team.",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),

        const SizedBox(height: 22),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 4),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFBD9A6B), width: 1.2),
            ),
          ),
          child: const Text(
            "10. No Conflict of Interest",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFBD9A6B),
            ),
          ),
        ),

        SizedBox(height: 6),

        Text(
          "The research team confirms there are no financial or personal conflicts of interest related to this project.",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),

        const SizedBox(height: 22),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 4),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFBD9A6B), width: 1.2),
            ),
          ),
          child: const Text(
            "11. No External Funding",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFBD9A6B),
            ),
          ),
        ),

        SizedBox(height: 6),

        Text(
          "The project is self-funded and developed for academic research purposes only.",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),

        const SizedBox(height: 22),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 4),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFBD9A6B), width: 1.2),
            ),
          ),
          child: const Text(
            "12. Contact Information",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFBD9A6B),
            ),
          ),
        ),

        SizedBox(height: 6),

        Text(
          "If you have questions, concerns, or wish to withdraw:",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),

        SizedBox(height: 8),

        Text(
          "• Ishara Wijesundara – 0775439227",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        Text(
          "• Oshini Malshika – 0787846002",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        Text(
          "• Susinidu Sachinthana – 0763541455",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
        Text(
          "• Yasindu Pasanjith – 0702391114",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),

        const SizedBox(height: 22),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 4),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFBD9A6B), width: 1.2),
            ),
          ),
          child: const Text(
            "13. Acceptance of Terms",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFBD9A6B),
            ),
          ),
        ),

        SizedBox(height: 6),

        Text(
          "By creating an account or using ChromaBloom, you agree that:",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),

        const SizedBox(height: 8),

        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: const Color(0xFFC89B62),
          checkColor: Colors.white,
          value: acceptedPurpose,
          onChanged: (v) => onPurposeChanged(v ?? false),
          title: const Text(
            "I understand the app’s purpose",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFBD9A6B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: const Color(0xFFC89B62),
          checkColor: Colors.white,
          value: acceptedDataUsage,
          onChanged: (v) => onDataUsageChanged(v ?? false),
          title: const Text(
            "I consent to the described data usage",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFBD9A6B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: const Color(0xFFC89B62),
          checkColor: Colors.white,
          value: acceptedTerms,
          onChanged: (v) => onTermsChanged(v ?? false),
          title: const Text(
            "I accept these Terms & Conditions",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFBD9A6B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        SizedBox(height: 8),

        Text(
          "If you do not agree, please discontinue using the app.",
          style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFFBD9A6B)),
        ),
      ],
    );
  }
}
