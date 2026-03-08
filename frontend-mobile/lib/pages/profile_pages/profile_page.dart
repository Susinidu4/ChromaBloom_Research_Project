import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/session_provider.dart';
import '../../services/user_services/child_api.dart';
import '../../services/Gemified/drawing_level_service.dart';
import '../../services/Gemified/problem_solving_level.dart';
import '../../services/api_config.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color headerBlue = Color(0xFF3E6D86);
  static const Color pageBg = Color(0xFFF6EDED);

  static const Color textGold = Color(0xFFC6A36C);
  static const Color cardBg = Color(0xFFE8DDCE);
  static const Color cardIconBg = Color(0xFFD7C3AA);

  static const Color signOutBg = Color(0xFFE9DECF);

  ImageProvider _resolveAvatar(Map<String, dynamic>? caregiver) {
    // Try multiple common keys your backend might return
    final raw = (caregiver?['profilePicUrl'] ??
            caregiver?['profile_pic_url'] ??
            caregiver?['profilePic'] ??
            caregiver?['profile_pic'] ??
            caregiver?['avatar'] ??
            caregiver?['image'])
        ?.toString();

    // Fallback asset
    const fallback = AssetImage("assets/images/profile_avatar.png");

    if (raw == null || raw.trim().isEmpty) return fallback;

    final v = raw.trim();

    // 1) Network URL
    if (v.startsWith('http://') || v.startsWith('https://')) {
      return NetworkImage(v);
    }

    // 2) Data URI base64: data:image/png;base64,....
    if (v.startsWith('data:image')) {
      final commaIndex = v.indexOf(',');
      if (commaIndex != -1) {
        final b64 = v.substring(commaIndex + 1);
        try {
          final bytes = base64Decode(b64);
          return MemoryImage(bytes);
        } catch (_) {
          return fallback;
        }
      }
    }

    // 3) Plain base64 (no prefix)
    try {
      final bytes = base64Decode(v);
      return MemoryImage(bytes);
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final caregiver = session.caregiver;

    final fullName = (caregiver?['fullName'] ??
            caregiver?['full_name'] ??
            caregiver?['name'] ??
            'Caregiver')
        .toString();

    final email = (caregiver?['email'] ?? 'unknown@email.com').toString();

    final avatarProvider = _resolveAvatar(caregiver);

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _HeaderSection(
              name: fullName,
              email: email,
              avatar: avatarProvider,
              notificationCount: 5,
              onNotificationTap: () {},
              onBackTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    const Text(
                      "YOUR PROFILE",
                      style: TextStyle(
                        color: textGold,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    _DrawingLessonBatches(
                      caregiverId: (caregiver?['_id'] ?? caregiver?['id'] ?? '').toString(),
                      token: session.token,
                    ),
                    _ProblemSolvingBatches(
                      caregiverId: (caregiver?['_id'] ?? caregiver?['id'] ?? '').toString(),
                      token: session.token,
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      "GENERAL",
                      style: TextStyle(
                        color: textGold,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ProfileMenuItem(
                      icon: Icons.person_outline,
                      title: "Profile Settings",
                      subtitle: "Update and Modify your details",
                      onTap: () =>
                          Navigator.pushNamed(context, '/profile_settings'),
                    ),
                    const SizedBox(height: 12),
                    ProfileMenuItem(
                      icon: Icons.child_care_outlined,
                      title: "Child Details",
                      subtitle: "Update and Modify your child details",
                      onTap: () => Navigator.pushNamed(context, '/child_details'),
                    ),
                    const SizedBox(height: 12),
                    ProfileMenuItem(
                      icon: Icons.lock_outline,
                      title: "Login and Recovery",
                      subtitle: "Your login credentials",
                      onTap: () => Navigator.pushNamed(context, '/login_recovery'),
                    ),
                    const SizedBox(height: 12),
                    ProfileMenuItem(
                      icon: Icons.warning_rounded,
                      title: "Terms Of Use",
                      subtitle: "Your consent agreement",
                      onTap: () => Navigator.pushNamed(context, '/terms_of_use'),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      "LOGIN",
                      style: TextStyle(
                        color: textGold,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Sign out
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: signOutBg,
                          foregroundColor: const Color(0xFF9B845F),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(
                              color: Color(0xFFBFA47A),
                              width: 1.2,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          await context.read<SessionProvider>().logout();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/caregiver_login',
                              (route) => false,
                            );
                          }
                        },
                        child: const Text(
                          "Sign Out",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Delete Account
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => _showDeleteConfirmation(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 187, 69, 14),
                          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Delete Account",
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text(
              "Are you sure you want to delete your account? This action is permanent and cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await context.read<SessionProvider>().deleteAccount();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/welcome_screen',
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error deleting account: $e")),
                    );
                  }
                }
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ================= HEADER =================

class _HeaderSection extends StatelessWidget {
  final String name;
  final String email;
  final ImageProvider avatar;

  final int notificationCount;
  final VoidCallback onNotificationTap;
  final VoidCallback onBackTap;

  const _HeaderSection({
    required this.name,
    required this.email,
    required this.avatar,
    required this.notificationCount,
    required this.onNotificationTap,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ProfilePage.headerBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 22),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: onBackTap,
                child: const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const Spacer(),
              _NotificationBell(
                count: notificationCount,
                onTap: onNotificationTap,
              ),
            ],
          ),
          const SizedBox(height: 8),
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
                backgroundImage: avatar,
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

// ================= NOTIFICATION =================

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
            child: Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: 26,
            ),
          ),
          if (count > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF8C1D1D),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: ProfilePage.headerBlue,
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

// ================= MENU ITEM =================

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: ProfilePage.cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: ProfilePage.cardIconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF8F6F44)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFB88F55),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFFB88F55),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFB88F55),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= DRAWING LESSON BATCHES =================

class _DrawingLessonBatches extends StatefulWidget {
  final String caregiverId;
  final String? token;

  const _DrawingLessonBatches({required this.caregiverId, this.token});

  @override
  State<_DrawingLessonBatches> createState() => _DrawingLessonBatchesState();
}

class _DrawingLessonBatchesState extends State<_DrawingLessonBatches> {
  String? _drawingLevel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDrawingLevel();
  }

  Future<void> _fetchDrawingLevel() async {
    try {
      final children = await ChildApi.getChildrenByCaregiver(widget.caregiverId);
      if (children.isNotEmpty) {
        final child = children.first;
        final childId = (child['_id'] ?? child['id'] ?? '').toString();

        final drawingLevelService = DrawingLevelService(
          baseUrl: '${ApiConfig.baseUrl}/chromabloom/drawing-levels',
          token: widget.token,
        );

        final levelData = await drawingLevelService.getDrawingLevelByUserId(childId);
        if (levelData.isNotEmpty) {
          final level = (levelData[0]['level'] ?? '').toString();
          if (mounted) {
            setState(() {
              _drawingLevel = level;
              _isLoading = false;
            });
          }
        } else {
           if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching drawing level: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();
    if (_drawingLevel == null || _drawingLevel!.isEmpty) return const SizedBox.shrink();

    // Use lowercase for comparisons to be safe
    final level = _drawingLevel!.toLowerCase();
    
    // Check for "Intermediate" (including possible misspelling "Intermediat")
    bool isIntermediate = level.contains('intermediat') || level == 'intermediate';
    // Check for "Advance" (including "Advanced")
    bool isAdvance = level.contains('advance') || level == 'advanced';

    if (!isIntermediate && !isAdvance) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        const Text(
          "DRAWING LESSON BATCHES",
          style: TextStyle(
            color: ProfilePage.textGold,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (isIntermediate || isAdvance)
              _buildBatchImage("assets/images/d_beginner.png", "Beginner Batch"),
            if (isAdvance) const SizedBox(width: 12),
            if (isAdvance)
              _buildBatchImage("assets/images/d_intermediate.png", "Intermediate Batch"),
          ],
        ),
      ],
    );
  }

  Widget _buildBatchImage(String assetPath, String title) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ProfilePage.cardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: ProfilePage.textGold,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ================= PROBLEM SOLVING BATCHES =================

class _ProblemSolvingBatches extends StatefulWidget {
  final String caregiverId;
  final String? token;

  const _ProblemSolvingBatches({required this.caregiverId, this.token});

  @override
  State<_ProblemSolvingBatches> createState() => _ProblemSolvingBatchesState();
}

class _ProblemSolvingBatchesState extends State<_ProblemSolvingBatches> {
  String? _problemSolvingLevel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProblemSolvingLevel();
  }

  Future<void> _fetchProblemSolvingLevel() async {
    try {
      final children = await ChildApi.getChildrenByCaregiver(widget.caregiverId);
      if (children.isNotEmpty) {
        final child = children.first;
        final childId = (child['_id'] ?? child['id'] ?? '').toString();

        final levelData = await ProblemSolvingLevelService.getLevelByUserId(childId);
        
        // Match backend response: it returns a map for this specific user
        final level = (levelData['level'] ?? '').toString();
        
        if (mounted) {
          setState(() {
            _problemSolvingLevel = level;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching problem solving level: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();
    if (_problemSolvingLevel == null || _problemSolvingLevel!.isEmpty) return const SizedBox.shrink();

    // Use lowercase for comparisons to be safe
    final level = _problemSolvingLevel!.toLowerCase();
    
    // Check for "Intermediate" (including possible misspelling "Intermediat")
    bool isIntermediate = level.contains('intermediat') || level == 'intermediate';
    // Check for "Advance" (including "Advanced")
    bool isAdvance = level.contains('advance') || level == 'advanced';

    if (!isIntermediate && !isAdvance) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        const Text(
          "PROBLEM SOLVING BATCHES",
          style: TextStyle(
            color: ProfilePage.textGold,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (isIntermediate || isAdvance)
              _buildBatchImage("assets/images/p_beginner.png", "Beginner Batch"),
            if (isAdvance) const SizedBox(width: 12),
            if (isAdvance)
              _buildBatchImage("assets/images/p_intermediate.png", "Intermediate Batch"),
          ],
        ),
      ],
    );
  }

  Widget _buildBatchImage(String assetPath, String title) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ProfilePage.cardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: ProfilePage.textGold,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
