import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../state/session_provider.dart';
import 'profile_edit_widgets.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  static const Color headerBlue = Color(0xFF3E6D86);
  static const Color pageBg = Color(0xFFF6EDED);

  static const Color textGold = Color(0xFFC6A36C);
  static const Color valueText = Color(0xFFB88F55);
  static const Color lineGold = Color(0xFFC6A36C);

  static String formatDateOnly(dynamic value) {
    if (value == null) return "-";
    final s = value.toString().trim();
    if (s.isEmpty) return "-";

    try {
      final dt = DateTime.parse(s);
      final y = dt.year.toString().padLeft(4, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      return "$y-$m-$d";
    } catch (_) {
      return s.split("T").first;
    }
  }

  static void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ✅ FIXED: upload bytes (no File / Platform / dart:io)
  static Future<void> _handlePickAndUpload(BuildContext context) async {
    final session = context.read<SessionProvider>();
    if (!session.isLoggedIn) {
      _snack(context, "Please login again.");
      return;
    }

    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;

    final Uint8List bytes = await picked.readAsBytes();
    final String filename = picked.name; // safe on web too

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await session.updateCaregiverProfile(
        profilePicBytes: bytes,
        profilePicFilename: filename,
      );
      if (context.mounted) Navigator.pop(context);
      _snack(context, "Profile picture updated!");
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      _snack(context, e.toString());
    }
  }

  static Future<void> _openEditDetails(BuildContext context) async {
    final session = context.read<SessionProvider>();
    final caregiver = session.caregiver ?? {};

    String s(dynamic x) => (x == null) ? "" : x.toString();

    String resolveName() {
      final v = caregiver['fullName'] ??
          caregiver['full_name'] ??
          caregiver['name'] ??
          caregiver['full_name'];
      return s(v).trim();
    }

    String resolvePhone() {
      final v =
          caregiver['phoneNumber'] ?? caregiver['mobile'] ?? caregiver['phone'];
      return s(v).trim();
    }

    String resolveEmail() => s(caregiver['email']).trim();
    String resolveAddress() => s(caregiver['address']).trim();
    String resolveGender() => s(caregiver['gender']).trim();

    int resolveChildCount() {
      final v = caregiver['child_count'];
      if (v is int) return v;
      return int.tryParse(s(v)) ?? 0;
    }

    DateTime? resolveDob() {
      final raw = caregiver['dateOfBirth'] ?? caregiver['dob'];
      final str = s(raw).trim();
      if (str.isEmpty) return null;
      try {
        return DateTime.parse(str);
      } catch (_) {
        return null;
      }
    }

    final nameCtrl = TextEditingController(text: resolveName());
    final phoneCtrl = TextEditingController(text: resolvePhone());
    final emailCtrl = TextEditingController(text: resolveEmail());
    final addressCtrl = TextEditingController(text: resolveAddress());
    final childCtrl =
        TextEditingController(text: resolveChildCount().toString());
    final passwordCtrl = TextEditingController(text: "");

    String gender = resolveGender().isEmpty ? "male" : resolveGender();
    DateTime? dob = resolveDob();

    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            Future<void> pickDob() async {
              final now = DateTime.now();
              final first = DateTime(now.year - 120, 1, 1);
              final initial = dob ?? DateTime(now.year - 25, 1, 1);

              final picked = await showDatePicker(
                context: ctx,
                initialDate: initial.isBefore(first) ? first : initial,
                firstDate: first,
                lastDate: now,
                helpText: "Select Date of Birth",
              );

              if (picked != null) {
                setState(() => dob = picked);
              }
            }

            Future<void> save() async {
              if (!session.isLoggedIn) {
                _snack(context, "Please login again.");
                return;
              }

              if (!(formKey.currentState?.validate() ?? false)) return;

              final fullName = nameCtrl.text.trim();
              final phone = phoneCtrl.text.trim();
              final email = emailCtrl.text.trim();
              final address = addressCtrl.text.trim();

              final childCount = int.tryParse(childCtrl.text.trim());
              if (childCount == null || childCount < 0) {
                _snack(context, "Please enter a valid number of children.");
                return;
              }

              final dobStr = (dob == null)
                  ? null
                  : "${dob!.year.toString().padLeft(4, '0')}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}";

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );

              try {
                await session.updateCaregiverProfile(
                  fullName: fullName,
                  phone: phone,
                  email: email,
                  address: address,
                  gender: gender,
                  dob: dobStr,
                  childCount: childCount,
                  password: passwordCtrl.text.trim().isEmpty
                      ? null
                      : passwordCtrl.text.trim(),
                );

                if (context.mounted) Navigator.pop(context); // close loader
                if (context.mounted) Navigator.pop(context); // close sheet
                _snack(context, "Profile updated successfully!");
              } catch (e) {
                if (context.mounted) Navigator.pop(context);
                _snack(context, e.toString());
              }
            }

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: pageBg,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 46,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const Text(
                          "Edit Caregiver Details",
                          style: TextStyle(
                            color: textGold,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ProfileEditField(
                          label: "Full Name",
                          controller: nameCtrl,
                          keyboard: TextInputType.name,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return "Full name is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        ProfileEditDropdown(
                          label: "Gender",
                          value: gender.toLowerCase(),
                          items: const ["male", "female", "other"],
                          onChanged: (v) => setState(() => gender = v),
                        ),
                        const SizedBox(height: 10),
                        ProfileDobPickerRow(
                          label: "Date of Birth",
                          valueText: dob == null
                              ? "-"
                              : "${dob!.year.toString().padLeft(4, '0')}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}",
                          onTap: pickDob,
                        ),
                        const SizedBox(height: 10),
                        ProfileEditField(
                          label: "No of Children",
                          controller: childCtrl,
                          keyboard: TextInputType.number,
                          validator: (v) {
                            final n = int.tryParse((v ?? "").trim());
                            if (n == null || n < 0) {
                              return "Enter a valid number";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        ProfileEditField(
                          label: "Mobile Number",
                          controller: phoneCtrl,
                          keyboard: TextInputType.phone,
                        ),
                        const SizedBox(height: 10),
                        ProfileEditField(
                          label: "Email",
                          controller: emailCtrl,
                          keyboard: TextInputType.emailAddress,
                          validator: (v) {
                            final t = (v ?? "").trim();
                            if (t.isEmpty) return "Email is required";
                            if (!t.contains("@")) return "Enter a valid email";
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        ProfileEditField(
                          label: "Address",
                          controller: addressCtrl,
                          keyboard: TextInputType.streetAddress,
                        ),
                        const SizedBox(height: 10),
                        ProfileEditField(
                          label: "New Password (optional)",
                          controller: passwordCtrl,
                          keyboard: TextInputType.visiblePassword,
                          obscure: true,
                          helper: "Leave blank to keep your current password.",
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: lineGold.withOpacity(0.9),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: textGold,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: save,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: headerBlue,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  "Save",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    childCtrl.dispose();
    passwordCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final caregiver = context.watch<SessionProvider>().caregiver ?? {};

    String val(dynamic x) =>
        (x == null || x.toString().trim().isEmpty) ? "-" : x.toString();

    final name = val(
      caregiver['fullName'] ??
          caregiver['full_name'] ??
          caregiver['name'] ??
          caregiver['full_name'],
    );

    final email = val(caregiver['email']);

    final profilePicUrl =
        (caregiver['profile_pic'] ?? caregiver['profilePic'])?.toString();

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _HeaderSection(
              name: name,
              email: email,
              notificationCount: 5,
              onNotificationTap: () {},
              onEditAvatarTap: () => _handlePickAndUpload(context),
              profilePicUrl: profilePicUrl,
              onEditDetailsTap: () => _openEditDetails(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () => Navigator.pop(context),
                          child: const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: textGold,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Profile Settings",
                          style: TextStyle(
                            color: textGold,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Basic Information",
                      style: TextStyle(
                        color: textGold,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _InfoRow(label: "Full Name", value: name),
                    const SizedBox(height: 10),
                    _InfoRow(label: "Gender", value: val(caregiver['gender'])),
                    const SizedBox(height: 10),
                    _InfoRow(
                      label: "Date of Birth",
                      value: formatDateOnly(
                        caregiver['dateOfBirth'] ?? caregiver['dob'],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      label: "No of Children",
                      value: val(caregiver['child_count']),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      "Contact Information",
                      style: TextStyle(
                        color: textGold,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _InfoRow(
                      label: "Mobile Number",
                      value: val(
                        caregiver['phoneNumber'] ??
                            caregiver['mobile'] ??
                            caregiver['phone'],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(label: "Email", value: email),
                    const SizedBox(height: 10),
                    _InfoRow(
                      label: "Address",
                      value: val(caregiver['address']),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final String name;
  final String email;
  final int notificationCount;
  final VoidCallback onNotificationTap;
  final VoidCallback onEditAvatarTap;
  final VoidCallback onEditDetailsTap;
  final String? profilePicUrl;

  const _HeaderSection({
    required this.name,
    required this.email,
    required this.notificationCount,
    required this.onNotificationTap,
    required this.onEditAvatarTap,
    required this.onEditDetailsTap,
    required this.profilePicUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasNetworkPic =
        profilePicUrl != null && profilePicUrl!.trim().isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: ProfileSettingsPage.headerBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: _NotificationBell(
              count: notificationCount,
              onTap: onNotificationTap,
            ),
          ),
          const SizedBox(height: 6),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 124,
                height: 124,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.88),
                ),
                child: Center(
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: const Color(0xFFE9E9E9),
                    backgroundImage: hasNetworkPic
                        ? NetworkImage(profilePicUrl!)
                        : const AssetImage("assets/images/profile_avatar.png")
                            as ImageProvider,
                  ),
                ),
              ),
              Positioned(
                right: 6,
                bottom: 6,
                child: InkWell(
                  onTap: onEditAvatarTap,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      size: 18,
                      color: Color(0xFF9B845F),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: OutlinedButton.icon(
              onPressed: onEditDetailsTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withOpacity(0.85)),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.edit, size: 16),
              label: const Text(
                "Edit Details",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _NotificationBell({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Padding(
            padding: EdgeInsets.all(6.0),
            child: Icon(Icons.notifications_none, color: Colors.white, size: 26),
          ),
          if (count > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF8C1D1D),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: ProfileSettingsPage.headerBlue,
                    width: 2,
                  ),
                ),
                child: Text(
                  "$count",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 118,
          child: Text(
            label,
            style: const TextStyle(
              color: ProfileSettingsPage.textGold,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(
          width: 14,
          child: Text(
            ":",
            style: TextStyle(
              color: ProfileSettingsPage.textGold,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: ProfileSettingsPage.valueText,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                height: 1,
                color: ProfileSettingsPage.lineGold.withOpacity(0.75),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
