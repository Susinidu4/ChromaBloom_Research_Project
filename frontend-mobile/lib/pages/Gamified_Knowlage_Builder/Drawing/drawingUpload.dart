import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../others/header.dart';
import '../../others/navBar.dart';
import './improvment.dart'; // ✅ update to your actual path

class DrawingImprovementCheckPage extends StatefulWidget {
  const DrawingImprovementCheckPage({
    super.key,
    this.previousCorrectness, // optional (0.0 - 1.0)
  });

  final double? previousCorrectness;

  static const Color pageBg = Color(0xFFF5ECEC);

  static const Color topRowBlue = Color(0xFF3D6B86);
  static const Color bubbleBg = Color(0xFFF8F2E8);
  static const Color bubbleIcon = Color(0xFFB0896E);

  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color leftShade = Color(0xFFD6BFA6);
  static const Color titleColor = Color(0xFFA07E6A);

  static const Color uploadBorder = Color(0xFFD8C6B4);
  static const Color uploadIcon = Color(0xFFB0896E);

  static const Color primaryBtnBg = Color(0xFFB89A76);

  @override
  State<DrawingImprovementCheckPage> createState() =>
      _DrawingImprovementCheckPageState();
}

class _DrawingImprovementCheckPageState
    extends State<DrawingImprovementCheckPage> {
  final ImagePicker _picker = ImagePicker();

  Uint8List? _imageBytes;

  Future<void> _pickImage(ImageSource source) async {
    final xfile = await _picker.pickImage(source: source, imageQuality: 95);
    if (xfile == null) return;

    final bytes = await xfile.readAsBytes();
    setState(() => _imageBytes = bytes);
  }

  Future<void> _showPickOptions() async {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text("Pick from Gallery"),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Use Camera"),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _goToCompletePage() {
    if (_imageBytes == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonCompletePage(
          imageBytes: _imageBytes!,
          previousCorrectness: widget.previousCorrectness ?? 0.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _imageBytes != null;

    return Scaffold(
      backgroundColor: DrawingImprovementCheckPage.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            const MainHeader(
              title: "Hello !",
              subtitle: "Welcome Back.",
              notificationCount: 5,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _BackCircleButton(onTap: () => Navigator.pop(context)),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Drawing UNIT 1 Lesson 1",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: DrawingImprovementCheckPage.topRowBlue,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                    const SizedBox(height: 18),

                    const Center(
                      child: Text(
                        "Check Child improvement ...",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Preview
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: DrawingImprovementCheckPage.uploadBorder,
                        ),
                      ),
                      child: _imageBytes == null
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.image_outlined,
                                      size: 34, color: Colors.black45),
                                  SizedBox(height: 6),
                                  Text(
                                    "No image selected",
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.memory(
                                _imageBytes!,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),

                    const SizedBox(height: 14),

                    _UploadTile(
                      title: "Upload child drawing",
                      onTap: _showPickOptions,
                    ),

                    const SizedBox(height: 18),

                    Center(
                      child: _PrimaryButton(
                        label: "Continue",
                        enabled: canContinue,
                        onTap: canContinue ? _goToCompletePage : () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainNavBar(currentIndex: 2),
    );
  }
}

/* ===================== BACK BUTTON ===================== */

class _BackCircleButton extends StatelessWidget {
  const _BackCircleButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: DrawingImprovementCheckPage.bubbleBg,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.chevron_left_rounded,
            size: 26,
            color: DrawingImprovementCheckPage.bubbleIcon,
          ),
        ),
      ),
    );
  }
}

/* ===================== UPLOAD TILE ===================== */

class _UploadTile extends StatelessWidget {
  const _UploadTile({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: w * 0.88,
            height: 56,
            decoration: BoxDecoration(
              color: DrawingImprovementCheckPage.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: DrawingImprovementCheckPage.uploadBorder,
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3A000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  decoration: const BoxDecoration(
                    color: DrawingImprovementCheckPage.leftShade,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.upload_rounded,
                  size: 20,
                  color: DrawingImprovementCheckPage.uploadIcon,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: DrawingImprovementCheckPage.titleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 34),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ===================== PRIMARY BUTTON ===================== */

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    required this.enabled,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 110,
            height: 32,
            decoration: BoxDecoration(
              color: DrawingImprovementCheckPage.primaryBtnBg,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x24000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
