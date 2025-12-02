// lib/pages/auth/therapist/therapist_register_screen.dart
import 'dart:io';
import 'dart:convert'; // <-- needed for base64Encode

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/user_services/therapist_api.dart';

class TherapistRegisterScreen extends StatefulWidget {
  const TherapistRegisterScreen({super.key});

  @override
  State<TherapistRegisterScreen> createState() =>
      _TherapistRegisterScreenState();
}

class _TherapistRegisterScreenState extends State<TherapistRegisterScreen> {
  final Color _primaryBlue = const Color(0xFF235870);
  final Color _gold = const Color(0xFFC89B62);
  final Color _background = const Color(0xFFFDF8F2);

  final _formKey = GlobalKey<FormState>();

  // controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  String? gender;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController specializationController =
      TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController licenceController = TextEditingController();
  final TextEditingController workPlaceController = TextEditingController();

  bool _showPassword = false;
  bool _loading = false;
  bool acceptTerms = false;
  bool acceptPrivacy = false;

  // image picker
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  @override
  void dispose() {
    fullNameController.dispose();
    dobController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    addressController.dispose();
    specializationController.dispose();
    startDateController.dispose();
    licenceController.dispose();
    workPlaceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: now,
      initialDate: DateTime(now.year - 25),
    );
    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {});
    }
  }

  Future<void> _pickProfileImage() async {
    final img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (img != null) {
      setState(() {
        _pickedImage = img;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!acceptTerms || !acceptPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please accept Terms and Privacy Policy")),
      );
      return;
    }

    setState(() => _loading = true);

    // optional: convert picked image to base64 string
    String? profileBase64;
    if (_pickedImage != null) {
      final bytes = await _pickedImage!.readAsBytes();
      profileBase64 = "data:image/jpeg;base64,${base64Encode(bytes)}";
    }

    final Map<String, dynamic> payload = {
      "full_name": fullNameController.text.trim(),
      "dob": dobController.text.trim(),
      "gender": gender ?? "",
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
      "phone": phoneController.text.trim(),
      "address": addressController.text.trim(),
      "specialization": specializationController.text.trim(),
      "start_date": startDateController.text.trim(),
      "licence_number": licenceController.text.trim(),
      "work_place": workPlaceController.text.trim(),
      "terms_and_conditions": acceptTerms,
      "privacy_policy": acceptPrivacy,
      if (profileBase64 != null) "profile_picture_base64": profileBase64,
    };

    final res = await TherapistApi.registerTherapist(payload);

    setState(() => _loading = false);

    if (!mounted) return;

    if (res["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Therapist registered successfully")),
      );
      // Navigator.pushReplacementNamed(context, '/therapistLogin');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Registration failed")),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // ==== Profile picture picker ====
                      Center(
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 45,
                                  backgroundColor: Colors.grey.shade300,
                                  backgroundImage: _pickedImage != null
                                      ? FileImage(File(_pickedImage!.path))
                                      : null,
                                  child: _pickedImage == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: InkWell(
                                    onTap: _pickProfileImage,
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: _gold,
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Add Profile Picture",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        "Therapist Registration",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB37A41),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        "Basic Information",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB37A41),
                        ),
                      ),
                      const SizedBox(height: 8),

                      _buildRoundedTextField(
                        label: "Full Name",
                        controller: fullNameController,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: () => _pickDate(dobController),
                        child: AbsorbPointer(
                          child: _buildRoundedTextField(
                            label: "Date of Birth",
                            controller: dobController,
                            suffixIcon: const Icon(Icons.calendar_today),
                            validator: (v) =>
                                v == null || v.trim().isEmpty
                                    ? "Required"
                                    : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        decoration: _dropdownDecoration(label: "Gender"),
                        value: gender,
                        items: const [
                          DropdownMenuItem(
                              value: "Male", child: Text("Male")),
                          DropdownMenuItem(
                              value: "Female", child: Text("Female")),
                          DropdownMenuItem(
                              value: "Other", child: Text("Other")),
                        ],
                        onChanged: (val) => setState(() => gender = val),
                        validator: (v) =>
                            v == null || v.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        "Contact & Work Information",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB37A41),
                        ),
                      ),
                      const SizedBox(height: 8),

                      _buildRoundedTextField(
                        label: "Mobile Number",
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),

                      _buildRoundedTextField(
                        label: "Email",
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Required";
                          }
                          if (!v.contains("@")) return "Enter valid email";
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      _buildRoundedTextField(
                        label: "Password",
                        controller: passwordController,
                        obscureText: !_showPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: _gold,
                          ),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Required";
                          }
                          if (v.length < 6) {
                            return "Minimum 6 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      _buildRoundedTextField(
                        label: "Address",
                        controller: addressController,
                      ),
                      const SizedBox(height: 12),

                      _buildRoundedTextField(
                        label: "Specialization",
                        controller: specializationController,
                        hintText: "e.g., Occupational Therapist",
                      ),
                      const SizedBox(height: 12),

                      _buildRoundedTextField(
                        label: "Work Place",
                        controller: workPlaceController,
                        hintText: "e.g., Lady Ridgeway Hospital",
                      ),
                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: () => _pickDate(startDateController),
                        child: AbsorbPointer(
                          child: _buildRoundedTextField(
                            label: "Start Date (Experience)",
                            controller: startDateController,
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildRoundedTextField(
                        label: "Licence Number",
                        controller: licenceController,
                      ),

                      const SizedBox(height: 16),

                      // Terms & Privacy
                      Row(
                        children: [
                          Checkbox(
                            value: acceptTerms,
                            activeColor: _gold,
                            onChanged: (v) =>
                                setState(() => acceptTerms = v ?? false),
                          ),
                          const Expanded(
                            child: Text(
                              "I agree to the Terms & Conditions",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: acceptPrivacy,
                            activeColor: _gold,
                            onChanged: (v) =>
                                setState(() => acceptPrivacy = v ?? false),
                          ),
                          const Expanded(
                            child: Text(
                              "I agree to the Privacy Policy",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _gold,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text("Register"),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header
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
      child: Row(
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
                "Create Therapist Account",
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
    );
  }

  // rounded text field
  Widget _buildRoundedTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    String? hintText,
  }) {
    const Color borderColor = Color(0xFFC89B62);

    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: color, width: 1.4),
        );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: const TextStyle(color: borderColor),
        enabledBorder: border(borderColor),
        focusedBorder: border(borderColor),
        errorBorder: border(Colors.red),
        focusedErrorBorder: border(Colors.red),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
      ),
    );
  }

  InputDecoration _dropdownDecoration({required String label}) {
    const Color borderColor = Color(0xFFC89B62);
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: color, width: 1.4),
        );

    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: borderColor),
      enabledBorder: border(borderColor),
      focusedBorder: border(borderColor),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
