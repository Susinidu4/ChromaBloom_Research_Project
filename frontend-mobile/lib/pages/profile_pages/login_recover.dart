// lib/pages/profile_pages/login_recover.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/user_services/caregiver_api.dart';
import '../../state/session_provider.dart';
import 'profile_header.dart';

class LoginRecoverPage extends StatefulWidget {
  const LoginRecoverPage({super.key});

  @override
  State<LoginRecoverPage> createState() => _LoginRecoverPageState();
}

class _LoginRecoverPageState extends State<LoginRecoverPage> {
  // ─── Colours ───────────────────────────────────────────────
  static const Color pageBg     = Color(0xFFF6EDED);
  static const Color textGold   = Color(0xFFC6A36C);
  static const Color borderGold = Color(0xFFBFA47A);
  static const Color fieldFill  = Color(0xFFF7F0EC);
  static const Color valueText  = Color(0xFFB88F55);
  static const Color headerBlue = Color(0xFF3E6D86);

  // ─── Form ──────────────────────────────────────────────────
  final _formKey        = GlobalKey<FormState>();
  final _currentPwCtrl  = TextEditingController();
  final _newPwCtrl      = TextEditingController();
  final _confirmPwCtrl  = TextEditingController();

  bool _showCurrent = false;
  bool _showNew     = false;
  bool _showConfirm = false;
  bool _saving      = false;

  // ─── Avatar resolver (same as ProfilePage) ─────────────────
  ImageProvider _resolveAvatar(Map<String, dynamic>? caregiver) {
    final raw = (caregiver?['profilePicUrl'] ??
            caregiver?['profile_pic_url'] ??
            caregiver?['profilePic'] ??
            caregiver?['profile_pic'] ??
            caregiver?['avatar'] ??
            caregiver?['image'])
        ?.toString();

    const fallback = AssetImage('assets/images/profile_avatar.png');
    if (raw == null || raw.trim().isEmpty) return fallback;

    final v = raw.trim();
    if (v.startsWith('http://') || v.startsWith('https://')) {
      return NetworkImage(v);
    }
    if (v.startsWith('data:image')) {
      final comma = v.indexOf(',');
      if (comma != -1) {
        try {
          return MemoryImage(base64Decode(v.substring(comma + 1)));
        } catch (_) {
          return fallback;
        }
      }
    }
    try {
      return MemoryImage(base64Decode(v));
    } catch (_) {
      return fallback;
    }
  }

  // ─── Input decoration ──────────────────────────────────────
  InputDecoration _inputDecoration(
      String label, IconData leadIcon, bool visible, VoidCallback toggle) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: textGold, fontSize: 13),
      filled: true,
      fillColor: fieldFill,
      prefixIcon: Icon(leadIcon, color: textGold, size: 20),
      suffixIcon: IconButton(
        icon: Icon(
          visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: textGold,
          size: 20,
        ),
        onPressed: toggle,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderGold, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: textGold, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: Color(0xFFBB4514), width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: Color(0xFFBB4514), width: 1.8),
      ),
    );
  }

  // ─── Save ──────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final session     = context.read<SessionProvider>();
    final caregiver   = session.caregiver;
    final caregiverId =
        (caregiver?['_id'] ?? caregiver?['id'] ?? '').toString();

    if (caregiverId.isEmpty) {
      _showSnack('Session expired. Please log in again.', isError: true);
      return;
    }

    setState(() => _saving = true);

    try {
      await CaregiverApi.changePassword(
        caregiverId: caregiverId,
        currentPassword: _currentPwCtrl.text.trim(),
        newPassword: _newPwCtrl.text.trim(),
      );

      if (!mounted) return;
      _showSnack('Password updated successfully!');
      _currentPwCtrl.clear();
      _newPwCtrl.clear();
      _confirmPwCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to update password: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            isError ? const Color(0xFFBB4514) : headerBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  // ─── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final session   = context.watch<SessionProvider>();
    final caregiver = session.caregiver;

    final fullName = (caregiver?['fullName'] ??
            caregiver?['full_name'] ??
            caregiver?['name'] ??
            'Caregiver')
        .toString();
    final email =
        (caregiver?['email'] ?? '').toString();

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Shared ProfileHeader ──────────────────────
            ProfileHeader(
              name: fullName,
              email: email,
              avatar: _resolveAvatar(caregiver),
              notificationCount: 0,
              onNotificationTap: () {},
              onBackTap: () => Navigator.pop(context),
            ),

            // ── Scrollable body ──────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back + page title row
                      Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () => Navigator.pop(context),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: textGold,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Login & Recovery',
                            style: TextStyle(
                              color: textGold,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // ── Email (read-only) ──────────────
                      const Text(
                        'Login Email',
                        style: TextStyle(
                          color: textGold,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: fieldFill,
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: borderGold, width: 1.2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.email_outlined,
                                color: textGold, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                email.isEmpty ? '—' : email,
                                style: const TextStyle(
                                  color: valueText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(Icons.lock_rounded,
                                color: borderGold, size: 16),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Change Password ────────────────
                      const Text(
                        'Change Password',
                        style: TextStyle(
                          color: textGold,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choose a strong password for your account.',
                        style: TextStyle(
                          color: textGold.withOpacity(0.70),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Current password
                      TextFormField(
                        controller: _currentPwCtrl,
                        obscureText: !_showCurrent,
                        style: const TextStyle(
                            color: valueText,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                        decoration: _inputDecoration(
                          'Current Password',
                          Icons.lock_outline,
                          _showCurrent,
                          () => setState(
                              () => _showCurrent = !_showCurrent),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please enter your current password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // New password
                      TextFormField(
                        controller: _newPwCtrl,
                        obscureText: !_showNew,
                        style: const TextStyle(
                            color: valueText,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                        decoration: _inputDecoration(
                          'New Password',
                          Icons.vpn_key_outlined,
                          _showNew,
                          () => setState(() => _showNew = !_showNew),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please enter a new password';
                          }
                          if (v.trim().length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Confirm new password
                      TextFormField(
                        controller: _confirmPwCtrl,
                        obscureText: !_showConfirm,
                        style: const TextStyle(
                            color: valueText,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                        decoration: _inputDecoration(
                          'Confirm New Password',
                          Icons.vpn_key_rounded,
                          _showConfirm,
                          () => setState(
                              () => _showConfirm = !_showConfirm),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (v.trim() != _newPwCtrl.text.trim()) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      // ── Save button ────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: textGold,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Update Password',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ── Info card ──────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: fieldFill,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderGold, width: 1),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: textGold, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Your email address is used to log in and '
                                'cannot be changed here. To recover your '
                                'account, contact your administrator.',
                                style: TextStyle(
                                  color: textGold.withOpacity(0.85),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
}