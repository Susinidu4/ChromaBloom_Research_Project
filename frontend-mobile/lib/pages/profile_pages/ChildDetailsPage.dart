// lib/pages/profile_pages/ChildDetailsPage.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/user_services/child_api.dart';
import '../../state/session_provider.dart'; // ✅ adjust path if yours is different

class ChildDetailsPage extends StatefulWidget {
  const ChildDetailsPage({super.key});

  @override
  State<ChildDetailsPage> createState() => _ChildDetailsPageState();
}

class _ChildDetailsPageState extends State<ChildDetailsPage> {
  // ---- Colors (match your UI) ----
  static const Color headerBlue = Color(0xFF3E6D86);
  static const Color pageBg = Color(0xFFF6EDED);

  static const Color textGold = Color(0xFFC6A36C);
  static const Color lineGold = Color(0xFFC6A36C);
  static const Color valueText = Color(0xFFB88F55);

  // ---- State ----
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _children = [];
  Map<String, dynamic>? _selectedChild;

  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final session = context.read<SessionProvider>();
      final caregiver = session.caregiver;

      final caregiverId = (caregiver?['_id'] ?? caregiver?['id'] ?? '').toString();
      if (caregiverId.isEmpty) {
        throw Exception("Caregiver session not found. Please login again.");
      }

      final list = await ChildApi.getChildrenByCaregiver(caregiverId);

      final parsed = list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();

      setState(() {
        _children = parsed;
        _selectedChild = parsed.isNotEmpty ? parsed.first : null;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = "$e";
        _loading = false;
      });
    }
  }

  // ---------- Helpers ----------
  String _val(dynamic v, {String fallback = "-"}) {
    if (v == null) return fallback;
    final s = v.toString().trim();
    return s.isEmpty ? fallback : s;
  }

  String _formatDob(dynamic v) {
    if (v == null) return "-";
    final raw = v.toString().trim();
    if (raw.isEmpty) return "-";

    // expects "YYYY-MM-DD" or ISO "2025-12-20T..."
    try {
      final dt = DateTime.parse(raw);
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      final yyyy = dt.year.toString();
      return "$dd/$mm/$yyyy";
    } catch (_) {
      return raw; // if already formatted
    }
  }

  bool _boolFromMap(Map<String, dynamic>? m, String key) {
    if (m == null) return false;
    final v = m[key];
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) return v.toLowerCase() == "true";
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final caregiver = session.caregiver;

    final caregiverName = _val(caregiver?['full_name'] ?? caregiver?['fullName'], fallback: "Caregiver");
    final caregiverEmail = _val(caregiver?['email'], fallback: "");

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _HeaderSection(
              name: caregiverName,
              email: caregiverEmail,
              notificationCount: 0,
              caregiver: caregiver, // ✅ pass caregiver map for avatar
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : (_error != null)
                      ? _ErrorBox(
                          message: _error!,
                          onRetry: _loadChildren,
                        )
                      : (_children.isEmpty)
                          ? _EmptyBox(onRetry: _loadChildren)
                          : SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Back + Title
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
                                        "Child Details",
                                        style: TextStyle(
                                          color: textGold,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // ✅ Child selector (if multiple)
                                  if (_children.length > 1) ...[
                                    const Text(
                                      "Select Child",
                                      style: TextStyle(
                                        color: textGold,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _ChildSelector(
                                      childrenList: _children,
                                      selectedId: _val(_selectedChild?['_id'], fallback: ""),
                                      onChanged: (id) {
                                        final found = _children.firstWhere(
                                          (c) => _val(c['_id']) == id,
                                          orElse: () => _children.first,
                                        );
                                        setState(() => _selectedChild = found);
                                      },
                                    ),
                                    const SizedBox(height: 18),
                                  ],

                                  // ----- Extract selected child fields -----
                                  _buildChildDetails(_selectedChild!),
                                ],
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildDetails(Map<String, dynamic> child) {
    final other = (child['otherHealthConditions'] is Map)
        ? Map<String, dynamic>.from(child['otherHealthConditions'])
        : <String, dynamic>{};

    final heart = _boolFromMap(other, 'heartIssues');
    final thyroid = _boolFromMap(other, 'thyroid');
    final hearing = _boolFromMap(other, 'hearingProblems');
    final vision = _boolFromMap(other, 'visionProblems');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Basic Information",
          style: TextStyle(
            color: textGold,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),

        _InfoRow(label: "Child ID", value: _val(child['_id'])),
        const SizedBox(height: 10),
        _InfoRow(label: "Child Name", value: _val(child['childName'])),
        const SizedBox(height: 10),
        _InfoRow(label: "Date of Birth", value: _formatDob(child['dateOfBirth'])),
        const SizedBox(height: 10),
        _InfoRow(label: "Gender", value: _val(child['gender'])),
        const SizedBox(height: 10),
        _InfoRow(label: "Height", value: "${_val(child['heightCm'], fallback: "-")} cm"),
        const SizedBox(height: 10),
        _InfoRow(label: "Weight", value: "${_val(child['weightKg'], fallback: "-")} kg"),

        const SizedBox(height: 26),

        const Text(
          "Medical Information",
          style: TextStyle(
            color: textGold,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),

        _InfoRow(
          label: "DS Type",
          value: _val(child['downSyndromeType']),
        ),
        const SizedBox(height: 10),
        _InfoRow(
          label: "Confirmed By",
          value: _val(child['downSyndromeConfirmedBy']),
        ),

        const SizedBox(height: 26),

        const Text(
          "Other Health Conditions",
          style: TextStyle(
            color: textGold,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),

        _YesNoTextRow(label: "Heart Issues", value: heart),
        const SizedBox(height: 8),
        _YesNoTextRow(label: "Thyroid", value: thyroid),
        const SizedBox(height: 8),
        _YesNoTextRow(label: "Hearing Problems", value: hearing),
        const SizedBox(height: 8),
        _YesNoTextRow(label: "Vision Problems", value: vision),
      ],
    );
  }
}

// ===================== HEADER =====================

class _HeaderSection extends StatelessWidget {
  final String name;
  final String email;
  final int notificationCount;

  // ✅ to read profile picture from session.caregiver
  final Map<String, dynamic>? caregiver;

  const _HeaderSection({
    required this.name,
    required this.email,
    required this.notificationCount,
    required this.caregiver,
  });

  static const Color headerBlue = Color(0xFF3E6D86);

  // ✅ resolves profile pic (network url / data-uri base64 / plain base64)
  ImageProvider _resolveAvatar(Map<String, dynamic>? caregiver) {
    final raw = (caregiver?['profilePicUrl'] ??
            caregiver?['profile_pic_url'] ??
            caregiver?['profilePic'] ??
            caregiver?['profile_pic'] ??
            caregiver?['avatar'] ??
            caregiver?['image'])
        ?.toString();

    const fallback = AssetImage("assets/images/profile_avatar.png");

    if (raw == null || raw.trim().isEmpty) return fallback;

    final v = raw.trim();

    // URL
    if (v.startsWith('http://') || v.startsWith('https://')) {
      return NetworkImage(v);
    }

    // data:image/...;base64,...
    if (v.startsWith('data:image')) {
      final comma = v.indexOf(',');
      if (comma != -1) {
        final b64 = v.substring(comma + 1);
        try {
          return MemoryImage(base64Decode(b64));
        } catch (_) {
          return fallback;
        }
      }
    }

    // plain base64
    try {
      return MemoryImage(base64Decode(v));
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarProvider = _resolveAvatar(caregiver);

    return Container(
      decoration: const BoxDecoration(
        color: headerBlue,
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
              onTap: () {},
            ),
          ),
          const SizedBox(height: 6),
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
                backgroundImage: avatarProvider, // ✅ HERE
                onBackgroundImageError: (_, __) {},
              ),
            ),
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
                  border: Border.all(color: _HeaderSection.headerBlue, width: 2),
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

// ===================== BASIC INFO ROW =====================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  static const Color textGold = Color(0xFFC6A36C);
  static const Color lineGold = Color(0xFFC6A36C);
  static const Color valueText = Color(0xFFB88F55);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 118,
          child: Text(
            label,
            style: const TextStyle(
              color: textGold,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(
          width: 14,
          child: Text(
            ":",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textGold,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: valueText,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Container(height: 1, color: lineGold.withOpacity(0.75)),
            ],
          ),
        ),
      ],
    );
  }
}

// ===================== YES/NO TEXT ROW =====================

class _YesNoTextRow extends StatelessWidget {
  final String label;
  final bool value;

  const _YesNoTextRow({required this.label, required this.value});

  static const Color textGold = Color(0xFFC6A36C);
  static const Color valueText = Color(0xFFB88F55);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: textGold,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value ? "Yes" : "No",
          style: const TextStyle(
            color: valueText,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ===================== CHILD SELECTOR =====================

class _ChildSelector extends StatelessWidget {
  final List<Map<String, dynamic>> childrenList;
  final String selectedId;
  final ValueChanged<String> onChanged;

  const _ChildSelector({
    required this.childrenList,
    required this.selectedId,
    required this.onChanged,
  });

  static const Color fieldFill = Color(0xFFF7F0EC);
  static const Color borderGold = Color(0xFFBFA47A);
  static const Color textGold = Color(0xFFC6A36C);

  String _displayName(Map<String, dynamic> c) {
    final name = (c['childName'] ?? '').toString();
    final id = (c['_id'] ?? '').toString();
    if (name.trim().isEmpty) return id;
    if (id.trim().isEmpty) return name;
    return "$name ($id)";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: fieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderGold, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedId,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: textGold),
          dropdownColor: fieldFill,
          style: const TextStyle(
            color: textGold,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          items: childrenList
              .map((c) => DropdownMenuItem<String>(
                    value: (c['_id'] ?? '').toString(),
                    child: Text(_displayName(c)),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

// ===================== EMPTY / ERROR =====================

class _EmptyBox extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyBox({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("No children found for this caregiver."),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Refresh"),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Failed to load: $message"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
