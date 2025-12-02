// lib/pages/auth/signup/signup_screen.dart
import 'package:flutter/material.dart';
import '../../../services/user_services/caregiver_api.dart';
import '../../../services/user_services/child_api.dart';
import '../../../services/user_services/therapist_api.dart'; // 👈 NEW

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
  bool _isSubmitting = false;

  // ------- Step 1: Caregiver controllers -------
  final TextEditingController cgFullNameController = TextEditingController();
  final TextEditingController cgDobController = TextEditingController();
  String? cgGender;
  final TextEditingController cgChildrenCountController =
      TextEditingController();

  final TextEditingController cgMobileController = TextEditingController();
  final TextEditingController cgEmailController = TextEditingController();
  final TextEditingController cgAddressController = TextEditingController();

  // TEMP: we need a password for backend; ideally you add password fields
  final String _tempPassword = "password123"; // TODO: replace with real input

  // ------- Step 2: Child controllers -------
  final TextEditingController childNameController = TextEditingController();
  final TextEditingController childDobController = TextEditingController();
  String? childGender;
  final TextEditingController childHeightController = TextEditingController();
  final TextEditingController childWeightController = TextEditingController();
  String? downSyndromeType;
  String? downSyndromeConfirmedBy;

  // other health conditions
  bool hasHeartIssues = false;
  bool hasThyroidIssues = false;
  bool hasHearingProblems = false;
  bool hasVisionProblems = false;

  // therapist selection
  String? selectedTherapist;
  List<String> therapistOptions = []; // 👈 dynamic from API
  bool _loadingTherapists = false;
  String? _therapistError;

  // ------- Step 3: T&C -------
  bool acceptedTerms = false;
  bool acceptedPrivacy = false;

  @override
  void initState() {
    super.initState();
    _loadTherapists(); // 👈 fetch list when screen opens
  }

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

  // ================== LOAD THERAPISTS ==================
  Future<void> _loadTherapists() async {
    setState(() {
      _loadingTherapists = true;
      _therapistError = null;
    });

    final items = await TherapistApi.getTherapistDropdownItems();

    if (!mounted) return;

    if (items.isEmpty) {
      setState(() {
        therapistOptions = [];
        _therapistError = "No therapists found. Please add therapists first.";
        _loadingTherapists = false;
      });
      return;
    }

    setState(() {
      therapistOptions = items;
      _loadingTherapists = false;
    });
  }

  void _handleNext() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _submitSignUp();
    }
  }

  Future<void> _submitSignUp() async {
    if (!acceptedTerms || !acceptedPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please accept Terms & Conditions and Privacy Policy."),
        ),
      );
      return;
    }

    // Basic validation – you can expand this
    if (cgFullNameController.text.trim().isEmpty ||
        cgEmailController.text.trim().isEmpty ||
        childNameController.text.trim().isEmpty ||
        childDobController.text.trim().isEmpty ||
        childGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill required fields in Step 1 & Step 2."),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1) Register caregiver
      final cgResult = await CaregiverApi.registerCaregiver(
        fullName: cgFullNameController.text.trim(),
        dob: cgDobController.text.trim(),
        gender: cgGender ?? "Other",
        numberOfChildren:
            int.tryParse(cgChildrenCountController.text.trim()) ?? 1,
        mobile: cgMobileController.text.trim(),
        email: cgEmailController.text.trim(),
        address: cgAddressController.text.trim(),
        password: _tempPassword, // TODO: replace with real password field
      );

      final caregiver = cgResult['caregiver'];
      if (caregiver == null || caregiver['_id'] == null) {
        throw Exception("Caregiver ID not returned from backend");
      }

      final String caregiverId = caregiver['_id']; // e.g. "p-0001"

      // 2) Extract therapistId from dropdown (e.g. "Dr. A (Speech Therapist) - t-0001")
      String? therapistId;
      if (selectedTherapist != null &&
          selectedTherapist!.contains(' - ')) {
        final parts = selectedTherapist!.split(' - ');
        if (parts.length >= 2) {
          therapistId = parts.last.trim(); // "t-0001"
        }
      }

      // 3) Create child
      final double? height = double.tryParse(childHeightController.text.trim());
      final double? weight = double.tryParse(childWeightController.text.trim());

      final childResult = await ChildApi.createChild(
        childName: childNameController.text.trim(),
        dateOfBirth: childDobController.text.trim(),
        gender: childGender ?? "Other",
        heightCm: height,
        weightKg: weight,
        downSyndromeType: downSyndromeType,
        downSyndromeConfirmedBy: downSyndromeConfirmedBy,
        caregiverId: caregiverId,
        therapistId: therapistId,
        hasHeartIssues: hasHeartIssues,
        hasThyroidIssues: hasThyroidIssues,
        hasHearingProblems: hasHearingProblems,
        hasVisionProblems: hasVisionProblems,
      );

      if (!mounted) return;

      final msg = childResult['message'] ?? "Sign up completed successfully";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );

      // TODO: Navigate to caregiver home, maybe with newly created child
      // Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign up failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_loadingTherapists)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: LinearProgressIndicator(),
                            ),
                          if (_therapistError != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                _therapistError!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                ),
                              ),
                            ),
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

                            // health condition props
                            hasHeartIssues: hasHeartIssues,
                            hasThyroidIssues: hasThyroidIssues,
                            hasHearingProblems: hasHearingProblems,
                            hasVisionProblems: hasVisionProblems,
                            onHeartIssuesChanged: (v) =>
                                setState(() => hasHeartIssues = v ?? false),
                            onThyroidChanged: (v) =>
                                setState(() => hasThyroidIssues = v ?? false),
                            onHearingChanged: (v) =>
                                setState(() => hasHearingProblems = v ?? false),
                            onVisionChanged: (v) =>
                                setState(() => hasVisionProblems = v ?? false),

                            // therapist dropdown
                            selectedTherapist: selectedTherapist,
                            therapistOptions: therapistOptions,
                            onTherapistChanged: (v) =>
                                setState(() => selectedTherapist = v),
                          ),
                        ],
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
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      decoration: BoxDecoration(
        color: _primaryBlue,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Let’s get Started",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Image.asset(
                'assets/chromabloom1.png',
                height: 70,
              ),
            ],
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
          onPressed: (!canFinish || _isSubmitting) ? null : _handleNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: _gold,
            foregroundColor: Colors.white,
            elevation: 4,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(isLast ? "Finish" : "Next"),
        ),
      ),
    );
  }
}
