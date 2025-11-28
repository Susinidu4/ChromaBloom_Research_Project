// lib/pages/auth/signup/signup_screen.dart
import 'package:flutter/material.dart';

import 'caregiver_step.dart';
import 'child_step.dart';
import 'terms_step.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Colors
  final Color _primaryBlue = const Color(0xFF235870);
  final Color _gold = const Color(0xFFC89B62);
  final Color _background = const Color(0xFFFDF8F2);

  int _currentStep = 0;

  // ------- Step 1: Caregiver controllers -------
  final TextEditingController cgFullNameController = TextEditingController();
  final TextEditingController cgDobController = TextEditingController();
  String? cgGender;
  final TextEditingController cgChildrenCountController =
      TextEditingController();

  final TextEditingController cgMobileController = TextEditingController();
  final TextEditingController cgEmailController = TextEditingController();
  final TextEditingController cgAddressController = TextEditingController();

  // ------- Step 2: Child controllers -------
  final TextEditingController childNameController = TextEditingController();
  final TextEditingController childDobController = TextEditingController();
  String? childGender;
  final TextEditingController childHeightController = TextEditingController();
  final TextEditingController childWeightController = TextEditingController();
  String? downSyndromeType;
  String? downSyndromeConfirmedBy;

  // ------- Step 3: T&C -------
  bool acceptedTerms = false;
  bool acceptedPrivacy = false;

  @override
  void dispose() {
    cgFullNameController.dispose();
    cgDobController.dispose();
    cgChildrenCountController.dispose();
    cgMobileController.dispose();
    cgEmailController.dispose();
    cgAddressController.dispose();

    childNameController.dispose();
    childDobController.dispose();
    childHeightController.dispose();
    childWeightController.dispose();

    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 5),
      firstDate: DateTime(1990),
      lastDate: now,
    );
    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {});
    }
  }

  void _handleNext() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      // TODO: final submit – call backend APIs here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sign up completed (demo).")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildStepIndicators(),
                    const SizedBox(height: 24),
                    if (_currentStep == 0)
                      CaregiverStep(
                        fullNameController: cgFullNameController,
                        dobController: cgDobController,
                        gender: cgGender,
                        childrenCountController: cgChildrenCountController,
                        mobileController: cgMobileController,
                        emailController: cgEmailController,
                        addressController: cgAddressController,
                        onGenderChanged: (val) =>
                            setState(() => cgGender = val),
                        onDobTap: () => _pickDate(cgDobController),
                      )
                    else if (_currentStep == 1)
                      ChildStep(
                        childNameController: childNameController,
                        childDobController: childDobController,
                        childGender: childGender,
                        heightController: childHeightController,
                        weightController: childWeightController,
                        downSyndromeType: downSyndromeType,
                        downSyndromeConfirmedBy: downSyndromeConfirmedBy,
                        onGenderChanged: (val) =>
                            setState(() => childGender = val),
                        onDobTap: () => _pickDate(childDobController),
                        onDownTypeChanged: (val) =>
                            setState(() => downSyndromeType = val),
                        onConfirmedByChanged: (val) =>
                            setState(() => downSyndromeConfirmedBy = val),
                      )
                    else
                      TermsStep(
                        acceptedTerms: acceptedTerms,
                        acceptedPrivacy: acceptedPrivacy,
                        onTermsChanged: (v) =>
                            setState(() => acceptedTerms = v),
                        onPrivacyChanged: (v) =>
                            setState(() => acceptedPrivacy = v),
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  // ---------- header ----------
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: BoxDecoration(
        color: _primaryBlue,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Text(
            "Sign Up",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Let’s get Started",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.auto_awesome, // replace with your logo if needed
              color: Colors.white.withOpacity(0.8),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- step indicators ----------
  Widget _buildStepIndicators() {
    Widget stepButton(String text, int index) {
      final bool isActive = _currentStep == index;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => setState(() => _currentStep = index),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            backgroundColor: isActive ? _gold : Colors.white,
            foregroundColor: isActive ? Colors.white : _gold,
            elevation: isActive ? 4 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: _gold.withOpacity(0.4)),
            ),
          ),
          child: Text(text),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        stepButton("Step 1", 0),
        stepButton("Step 2", 1),
        stepButton("Step 3", 2),
      ],
    );
  }

  // ---------- bottom button ----------
  Widget _buildBottomButton() {
    final bool isLast = _currentStep == 2;
    final bool canFinish = !isLast || (acceptedTerms && acceptedPrivacy);

    return Container(
      color: _background,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canFinish ? _handleNext : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _gold,
            foregroundColor: Colors.white,
            elevation: 4,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ).borderRadius,
            ),
          ),
          child: Text(isLast ? "Finish" : "Next"),
        ),
      ),
    );
  }
}
