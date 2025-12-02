// lib/pages/auth/therapist/therapist_login_screen.dart
import 'package:flutter/material.dart';
import '../../../services/user_services/therapist_api.dart';

class TherapistLoginScreen extends StatefulWidget {
  const TherapistLoginScreen({super.key});

  @override
  State<TherapistLoginScreen> createState() => _TherapistLoginScreenState();
}

class _TherapistLoginScreenState extends State<TherapistLoginScreen> {
  final Color _primaryBlue = const Color(0xFF235870);
  final Color _gold = const Color(0xFFC89B62);
  final Color _background = const Color(0xFFFDF8F2);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _showPassword = false;
  bool _loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final res = await TherapistApi.loginTherapist(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => _loading = false);

    if (!mounted) return;

    if (res["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Therapist login successful")),
      );

      // TODO: Navigate to therapist dashboard
      // Navigator.pushReplacementNamed(context, '/therapistHome');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Login failed")),
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
                      const SizedBox(height: 32),
                      const Text(
                        "Therapist Login",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB37A41),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Welcome back! Please log in to continue.",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),

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

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _handleLogin,
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
                              : const Text("Login"),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(fontSize: 13),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to therapist register
                              // Navigator.pushNamed(context, '/therapistRegister');
                            },
                            child: const Text(
                              "Register",
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
                "Log in as Therapist",
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
