// lib/pages/profile_pages/term_of_use.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/session_provider.dart';
import 'profile_header.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  static const Color pageBg   = Color(0xFFF6EDED);
  static const Color textGold = Color(0xFFC6A36C);

  // ─── Avatar resolver ───────────────────────────────────────
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
    if (v.startsWith('http://') || v.startsWith('https://')) return NetworkImage(v);
    if (v.startsWith('data:image')) {
      final comma = v.indexOf(',');
      if (comma != -1) {
        try { return MemoryImage(base64Decode(v.substring(comma + 1))); } catch (_) {}
      }
    }
    try { return MemoryImage(base64Decode(v)); } catch (_) { return fallback; }
  }

  @override
  Widget build(BuildContext context) {
    final session   = context.watch<SessionProvider>();
    final caregiver = session.caregiver;
    final fullName  = (caregiver?['fullName'] ?? caregiver?['full_name'] ?? caregiver?['name'] ?? 'Caregiver').toString();
    final email     = (caregiver?['email'] ?? '').toString();

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            ProfileHeader(
              name: fullName,
              email: email,
              avatar: _resolveAvatar(caregiver),
              notificationCount: 0,
              onNotificationTap: () {},
              onBackTap: () => Navigator.pop(context),
            ),
            Expanded(
              child: _TermsBody(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Body — stateful so ExpansionTiles can open/close
// ─────────────────────────────────────────────────────────────

class _TermsBody extends StatefulWidget {
  @override
  State<_TermsBody> createState() => _TermsBodyState();
}

class _TermsBodyState extends State<_TermsBody> {
  static const Color pageBg    = Color(0xFFF6EDED);
  static const Color textGold  = Color(0xFFC6A36C);
  static const Color divider   = Color(0xFFDDCFBF);

  // 12 sections — title + content
  static const List<Map<String, String>> _sections = [
    {
      'title': 'Purpose of the App',
      'body':
          'ChromaBloom is an application designed to support caregivers of '
          'children with Down Syndrome by providing tools for activity '
          'scheduling, progress tracking, wellness monitoring, and '
          'educational resources.',
    },
    {
      'title': 'Voluntary Participation',
      'body':
          'Your participation in using ChromaBloom is entirely voluntary. '
          'You may choose to stop using the application at any time without '
          'any consequences. You may also request deletion of your account '
          'and associated data at any time.',
    },
    {
      'title': 'Data We Collect',
      'body':
          'We collect personal information such as your name, email address, '
          'and profile picture. We also collect data about the child in your '
          'care, including health-related information, activity logs, and '
          'progress records, solely for the purpose of providing the service.',
    },
    {
      'title': 'How Your Data Is Used',
      'body':
          'Your data is used exclusively to operate and improve the '
          'ChromaBloom application. It enables personalised recommendations, '
          'activity scheduling, and progress tracking. We do not use your '
          'data for advertising purposes.',
    },
    {
      'title': 'Confidentiality & Security',
      'body':
          'We implement appropriate technical and organisational measures to '
          'protect your personal data against unauthorised access, disclosure, '
          'alteration, or destruction. Access to your data is restricted to '
          'authorised personnel only.',
    },
    {
      'title': 'Risks & Limitations',
      'body':
          'ChromaBloom provides informational and tracking tools only. It is '
          'not a substitute for professional medical advice, diagnosis, or '
          'treatment. Always consult a qualified healthcare professional for '
          'medical decisions relating to your child.',
    },
    {
      'title': 'Age & Responsibility',
      'body':
          'ChromaBloom is intended for use by adults (caregivers aged 18 and '
          'above). By using the application you confirm that you are the '
          'legal guardian or authorised carer of the child whose data you '
          'submit.',
    },
    {
      'title': 'User Responsibilities',
      'body':
          'You are responsible for keeping your login credentials confidential '
          'and for ensuring that all information you provide is accurate. Any '
          'activity that occurs under your account is your responsibility.',
    },
    {
      'title': 'Withdrawal & Data Removal',
      'body':
          'You may withdraw from using ChromaBloom at any time and request '
          'complete removal of your account and all associated data. Requests '
          'for data removal can be submitted through the app or by contacting '
          'our support team.',
    },
    {
      'title': 'No Conflict of Interest',
      'body':
          'ChromaBloom is developed as a research and support tool. The '
          'development team has no financial or commercial interest in any '
          'external products or services that may be referenced within the '
          'application.',
    },
    {
      'title': 'No External Funding',
      'body':
          'The ChromaBloom project is independently developed and is not '
          'funded by or affiliated with any pharmaceutical, medical, or '
          'commercial organisation. All features are provided in good faith '
          'to support caregivers.',
    },
    {
      'title': 'Contact Information',
      'body':
          'If you have any questions, concerns, or requests regarding these '
          'terms or your data, please contact the ChromaBloom support team '
          'through the Help section of the application or via the registered '
          'project email address.',
    },
  ];

  // Track which panel is open (-1 = none)
  int _openIndex = -1;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + title
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
                'Terms Of Use',
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

          // Accordion list
          Container(
            decoration: BoxDecoration(
              color: pageBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: List.generate(_sections.length, (i) {
                final isOpen = _openIndex == i;
                final isLast = i == _sections.length - 1;

                return Column(
                  children: [
                    // Row tap area
                    InkWell(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(i == 0 ? 16 : 0),
                        topRight: Radius.circular(i == 0 ? 16 : 0),
                        bottomLeft: Radius.circular(isLast && !isOpen ? 16 : 0),
                        bottomRight: Radius.circular(isLast && !isOpen ? 16 : 0),
                      ),
                      onTap: () => setState(() => _openIndex = isOpen ? -1 : i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${i + 1}. ${_sections[i]['title']!}',
                                style: const TextStyle(
                                  color: textGold,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            AnimatedRotation(
                              turns: isOpen ? 0.5 : 0,
                              duration: const Duration(milliseconds: 220),
                              child: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: textGold,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Expanded body
                    AnimatedCrossFade(
                      firstChild: const SizedBox(width: double.infinity),
                      secondChild: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 4, 14),
                        child: Text(
                          _sections[i]['body']!,
                          style: TextStyle(
                            color: textGold.withOpacity(0.78),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            height: 1.65,
                          ),
                        ),
                      ),
                      crossFadeState: isOpen
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 220),
                    ),

                    // Divider (skip after last)
                    if (!isLast)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: divider.withOpacity(0.7),
                      ),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          // Footer note
          Center(
            child: Text(
              'Last updated: March 2025',
              style: TextStyle(
                color: textGold.withOpacity(0.50),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}