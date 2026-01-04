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
  // ✅ Colors to match PNG
  static const Color _bgBlue = Color(0xFF2F5F77); // deep teal/blue
  static const Color _gold = Color(0xFFC89B62); // gold stroke + button
  static const Color _hintGold = Color(0xFFB89263);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

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
      backgroundColor: _bgBlue,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),

                  // ✅ Logo (center)
                  Image.asset(
                    'assets/chromabloom1.png',
                    height: 78,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 12),

                  // ✅ App name text
                  const Text(
                    'ChromaBloom',
                    style: TextStyle(
                      color: _gold,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 34),

                  // ✅ Email field
                  _outlinedField(
                    label: "Email",
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return "Email is required";
                      if (!v.contains("@")) return "Enter a valid email";
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // ✅ Password field
                  _outlinedField(
                    label: "Password",
                    controller: passwordController,
                    obscureText: !_showPassword,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return "Password is required";
                      if (v.length < 6) return "Minimum 6 characters";
                      return null;
                    },
                    suffixIcon: IconButton(
                      splashRadius: 18,
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                        color: _gold,
                      ),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ✅ Forget Password ? (right)
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: _isLoading
                          ? null
                          : () {
                              // TODO: navigate forgot password
                            },
                      child: Text(
                        "Forget Password ?",
                        style: TextStyle(
                          color: _gold.withOpacity(0.85),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ✅ Login button (gold, rounded)
                  SizedBox(
                    width: 210,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _gold.withOpacity(0.55),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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
                          : const Text(
                              "Log in",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ✅ Bottom signup text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Doesn’t have an account? ",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.70),
                          fontSize: 12.5,
                        ),
                      ),
                      InkWell(
                        onTap: _isLoading
                            ? null
                            : () => Navigator.pushNamed(context, '/caregiver_signup'),
                        child: const Text(
                          "Signup",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Outlined rounded text field (gold stroke) to match PNG
  Widget _outlinedField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: 1.2),
        );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13.5,
      ),
      cursorColor: _gold,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: _hintGold.withOpacity(0.9),
          fontSize: 12.5,
        ),
        floatingLabelStyle: const TextStyle(color: _gold),
        enabledBorder: border(_gold.withOpacity(0.85)),
        focusedBorder: border(_gold),
        errorBorder: border(Colors.redAccent),
        focusedErrorBorder: border(Colors.redAccent),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.transparent, // keep like PNG
        suffixIcon: suffixIcon,
      ),
    );
  }
}
