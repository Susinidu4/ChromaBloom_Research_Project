import 'package:flutter/material.dart';

Future<void> showDigitalWellbeingPermissionGate({
  required BuildContext context,
  required Future<void> Function() onCancel,
  required Future<void> Function() onAllow,
}) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Digital Wellbeing Permission',
    barrierColor: const Color(0xAA000000), // grey overlay
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (_, __, ___) {
      return _DigitalWellbeingPermissionDialog(
        onCancel: onCancel,
        onAllow: onAllow,
      );
    },
    transitionBuilder: (_, anim, __, child) {
      final curve = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curve,
        child: ScaleTransition(
          scale: Tween(begin: 0.96, end: 1.0).animate(curve),
          child: child,
        ),
      );
    },
  );
}

class _DigitalWellbeingPermissionDialog extends StatefulWidget {
  final Future<void> Function() onCancel;
  final Future<void> Function() onAllow;

  const _DigitalWellbeingPermissionDialog({
    required this.onCancel,
    required this.onAllow,
  });

  @override
  State<_DigitalWellbeingPermissionDialog> createState() =>
      _DigitalWellbeingPermissionDialogState();
}

class _DigitalWellbeingPermissionDialogState
    extends State<_DigitalWellbeingPermissionDialog> {
  bool _loading = false;

  // Colors matching your screenshot
  static const Color cardBg = Color(0xFFE9DDCC);
  static const Color textGold = Color(0xFFB89A76);
  static const Color cancelBtn = Color(0xFF7A4A3B);
  static const Color allowBtn = Color(0xFFC9B28A);
  static const Color shadow = Color(0x55000000);

  Future<void> _safeRun(Future<void> Function() fn) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await fn();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Center(
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 24,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(26),
                boxShadow: const [
                  BoxShadow(
                    color: shadow,
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Allow Digital Wellbeing Access?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textGold,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Content scrollable (important for small screens)
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.45,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'To understand your daily stress patterns and suggest helpful micro-\nrecommendations, ChromaBloom needs access to your daily screen time and phone usage information.',
                                style: TextStyle(
                                  color: textGold.withOpacity(0.95),
                                  fontSize: 14,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 16),

                              _SectionTitle('We collect only:'),
                              _Bullets(
                                items: const [
                                  'Total screen time',
                                  'Night-time phone use',
                                  'App switching and unlock count',
                                ],
                                color: textGold,
                              ),
                              const SizedBox(height: 12),

                              _SectionTitle('We do NOT collect:'),
                              _Bullets(
                                items: const [
                                  'Messages',
                                  'Photos',
                                  'Call logs',
                                  'App content',
                                ],
                                color: textGold,
                              ),
                              const SizedBox(height: 12),

                              _SectionTitle('We use your data to:'),
                              _Bullets(
                                items: const [
                                  'Detect stress levels',
                                  'Give personalized recommendations',
                                  'Improve your wellbeing',
                                ],
                                color: textGold,
                              ),
                              const SizedBox(height: 6),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              text: _loading ? '...' : 'Cancel',
                              bg: cancelBtn,
                              fg: Colors.white,
                              onTap: _loading
                                  ? null
                                  : () async {
                                      Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).pop(); // CLOSE dialog first
                                      await widget
                                          .onCancel(); // THEN run your cancel logic
                                    },
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _ActionButton(
                              text: _loading ? '...' : 'Allow Access',
                              bg: allowBtn,
                              fg: Colors.white,
                              onTap: _loading
                                  ? null
                                  : () async {
                                      Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).pop(); // CLOSE dialog first
                                      await widget
                                          .onAllow(); // THEN run your allow logic
                                    },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    // Underline like screenshot
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: _DigitalWellbeingPermissionDialogState.textGold,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  final List<String> items;
  final Color color;
  const _Bullets({required this.items, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (t) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•  ',
                    style: TextStyle(color: color, fontSize: 14, height: 1.4),
                  ),
                  Expanded(
                    child: Text(
                      t,
                      style: TextStyle(color: color, fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.text,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 6,
          shadowColor: const Color(0x66000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
