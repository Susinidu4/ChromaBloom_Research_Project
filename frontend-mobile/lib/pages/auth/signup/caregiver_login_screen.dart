import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:provider/provider.dart';

import '../../../services/user_services/caregiver_api.dart';
import '../../../state/session_provider.dart';

class CaregiverLoginScreen extends StatefulWidget {
  const CaregiverLoginScreen({super.key});

  @override
  State<CaregiverLoginScreen> createState() => _CaregiverLoginScreenState();
}

class _CaregiverLoginScreenState extends State<CaregiverLoginScreen> {
  // Colors
  final Color _primaryBlue = const Color(0xFF235870);
  final Color _gold = const Color(0xFFC89B62);
  final Color _background = const Color(0xFFFDF8F2);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _showPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    // ✅ validate first
    if (!_formKey.currentState!.validate()) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Invalid input',
        text: 'Please fix the highlighted fields and try again.',
        confirmBtnText: 'OK',
        confirmBtnColor: _gold,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await CaregiverApi.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final token = result['token'] as String?;
      final caregiver = result['caregiver'] as Map<String, dynamic>?;

      if (token == null || caregiver == null) {
        throw Exception("Missing token/caregiver from server response");
      }

      await context.read<SessionProvider>().setSession(
            token: token,
            caregiver: caregiver,
          );

      if (!mounted) return;

      // ✅ show success, then navigate when user taps OK
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Login Successful',
        text: result['message'] ?? 'Welcome back!',
        confirmBtnText: 'OK',
        confirmBtnColor: _gold,
      );

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (e) {
      if (!mounted) return;

      // ✅ show backend error message if available (your CaregiverApi throws Exception(message))
      final msg = e.toString().replaceFirst('Exception: ', '');

      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Login Failed',
        text: msg.isEmpty ? 'Something went wrong. Please try again.' : msg,
        confirmBtnText: 'OK',
        confirmBtnColor: _gold,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                      const SizedBox(height: 32),
                      const Text(
                        "Caregiver Login",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB37A41),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Welcome back! Please login to continue.",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Email
                      _buildRoundedTextField(
                        label: "Email",
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Email is required";
                          }
                          if (!value.contains("@")) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Password is required";
                          }
                          if (value.length < 6) {
                            return "Minimum 6 characters";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  // TODO: Forgot password navigation
                                },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Color(0xFFB37A41),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _gold,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text("Login"),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Go to signup
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(fontSize: 13),
                          ),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    Navigator.pushNamed(
                                        context, '/caregiver_signup');
                                  },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFB37A41),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Welcome Back",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Log in to ChromaBloom",
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

  // ---------- shared rounded text field ----------
  Widget _buildRoundedTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
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
}
