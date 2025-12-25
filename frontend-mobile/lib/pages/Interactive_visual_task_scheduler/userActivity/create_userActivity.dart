// createUserActivity.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/quickalert.dart';

import '../../others/navBar.dart';
import '../../others/header.dart';
import '../../../services/Interactive_visual_task_scheduler_services/user_activity_service.dart';

import 'create_userActivity.dart';

class CreateUserActivityScreen extends StatefulWidget {
  const CreateUserActivityScreen({super.key});

  @override
  State<CreateUserActivityScreen> createState() =>
      _CreateUserActivityScreenState();
}

class _CreateUserActivityScreenState extends State<CreateUserActivityScreen> {
  // ===== Theme colors =====
  static const Color pageBg = Color(0xFFF3E8E8);
  static const Color cardBg = Color(0xFFE9DDCC);
  static const Color stroke = Color(0xFFBD9A6B);
  static const Color textSoft = Color(0xFFBD9A6B);
  static const Color shadow = Color(0x33000000);
  static const Color btn = Color(0xFFBD9A6B);

  final _formKey = GlobalKey<FormState>();

  DateTime selectedDate = DateTime.now();

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  // Duration UI
  int durationA = 0;
  int durationB = 0;

  // Steps (dynamic)
  final List<TextEditingController> stepCtrls = [TextEditingController()];

  // ✅ Backend-required dropdowns
  String ageGroup = "1";
  String developmentArea = "motor";
  String difficulty = "easy"; // backend expects lowercase

  // Image
  File? selectedImageFile;
  String imageLabel = "";

  bool saving = false;

  // TEMP caregiver
  static const String hardcodedCaregiverId = "p-0001";

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    for (final c in stepCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: cardBg,
            colorScheme: const ColorScheme.light(
              primary: stroke,
              onPrimary: Colors.white,
              surface: Color(0xFFF3E8E8),
              onSurface: Color(0xFF2F2A22),
            ),
            datePickerTheme: const DatePickerThemeData(
              todayBorder: BorderSide(
                color: Color.fromARGB(255, 166, 135, 94),
                width: 1.6,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 177, 144, 101),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) setState(() => selectedDate = picked);
  }

  void _addStep() => setState(() => stepCtrls.add(TextEditingController()));

  void _removeStep(int index) {
    if (stepCtrls.length <= 1) return;
    setState(() {
      stepCtrls[index].dispose();
      stepCtrls.removeAt(index);
    });
  }

  void _incDurationA() =>
      setState(() => durationA = (durationA + 1).clamp(0, 99));
  void _decDurationA() =>
      setState(() => durationA = (durationA - 1).clamp(0, 99));
  void _incDurationB() =>
      setState(() => durationB = (durationB + 1).clamp(0, 59));
  void _decDurationB() =>
      setState(() => durationB = (durationB - 1).clamp(0, 59));

  String _fmtDate(DateTime d) => "${d.day}/${d.month}/${d.year}";

  int _estimatedDurationMinutes() {
    // You used two boxes; treat them as minutes like: A:B (example)
    // If you want A as tens and B as ones => (A*10 + B)
    // For now: A = minutes, B = extra minutes (0..59)
    return (durationA * 60) + durationB;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImageFile = File(picked.path);
        imageLabel = picked.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ Build steps in backend format
    final steps = List.generate(stepCtrls.length, (i) {
      return {"step_number": i + 1, "instruction": stepCtrls[i].text.trim()};
    });

    setState(() => saving = true);

    try {
      final res = await UserActivityService.createUserActivity(
        createdBy: hardcodedCaregiverId,
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        ageGroup: ageGroup,
        developmentArea: developmentArea,
        scheduledDate: selectedDate,
        estimatedDurationMinutes: _estimatedDurationMinutes(),
        difficultyLevel: difficulty,
        steps: steps,
        mediaImage: selectedImageFile, // optional
      );

      // Success
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Success',
        text: 'Activity created successfully',
        confirmBtnText: 'OK',

        backgroundColor: const Color(0xFF1E1E1E),
        titleColor: Colors.white,
        textColor: Colors.white70,
        confirmBtnColor: const Color(0xFF00C853),
      );

      // Reset UI
      titleCtrl.clear();
      descCtrl.clear();
      for (final c in stepCtrls) c.clear();
      setState(() {
        selectedImageFile = null;
        imageLabel = "";
        durationA = 0;
        durationB = 0;
        ageGroup = "1";
        developmentArea = "motor";
        difficulty = "easy";
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: $e")));
    } finally {
      setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,

      body: SafeArea(
        child: Column(
          children: [
            const MainHeader(
              title: "Hello!",
              subtitle: "Welcome back",
              notificationCount: 0,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: _buildFormCard(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Navigation bar
      bottomNavigationBar: const MainNavBar(currentIndex: 1),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: shadow, blurRadius: 16, offset: Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Let’s add a new task...",
                    style: TextStyle(
                      color: textSoft,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: textSoft,
                    ),
                  ),
                ),
                _circleIconButton(
                  icon: Icons.close,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Image preview
            Center(
              child: Image.asset(
                "assets/create_user_activity.png",
                width: 180,
                height: 160,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 18),

            _label("Date :"),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDate,
              child: _inputLike(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _fmtDate(selectedDate),
                        style: const TextStyle(
                          color: textSoft,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(Icons.calendar_month_rounded, color: textSoft),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ✅ Age Group
            _label("Age Group :"),
            const SizedBox(height: 6),
            _inputLike(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: ageGroup,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: textSoft,
                  ),
                  items: List.generate(10, (i) {
                    final v = "${i + 1}";
                    return DropdownMenuItem(value: v, child: Text(v));
                  }),
                  onChanged: (v) => setState(() => ageGroup = v ?? "1"),
                  style: const TextStyle(
                    color: textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ✅ Development Area
            _label("Development Area :"),
            const SizedBox(height: 6),
            _inputLike(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: developmentArea,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: textSoft,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "self-care",
                      child: Text("self-care"),
                    ),
                    DropdownMenuItem(value: "motor", child: Text("motor")),
                    DropdownMenuItem(
                      value: "language",
                      child: Text("language"),
                    ),
                    DropdownMenuItem(
                      value: "cognitive",
                      child: Text("cognitive"),
                    ),
                    DropdownMenuItem(value: "social", child: Text("social")),
                    DropdownMenuItem(
                      value: "emotional",
                      child: Text("emotional"),
                    ),
                  ],
                  onChanged: (v) =>
                      setState(() => developmentArea = v ?? "motor"),
                  style: const TextStyle(
                    color: textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            _label("Title :"),
            const SizedBox(height: 6),
            _underlineField(
              controller: titleCtrl,
              hint: "",
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? "Title required" : null,
            ),

            const SizedBox(height: 12),

            _label("Description :"),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0E8DA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: stroke, width: 1.2),
              ),
              child: TextFormField(
                controller: descCtrl,
                maxLines: 4,
                style: const TextStyle(color: Color(0xFF2F2A22)),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(12),
                  border: InputBorder.none,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? "Description required"
                    : null,
              ),
            ),

            const SizedBox(height: 12),

            // Duration
            Row(
              children: [
                const Text(
                  "Duration :",
                  style: TextStyle(
                    color: textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                _smallBoxNumber(durationA.toString()),
                const SizedBox(width: 8),
                const Text(
                  ":",
                  style: TextStyle(color: textSoft, fontSize: 18),
                ),
                const SizedBox(width: 8),
                _smallBoxNumber(durationB.toString().padLeft(2, "0")),
                const SizedBox(width: 8),
                _upDown(onUp: _incDurationB, onDown: _decDurationB),
                const SizedBox(width: 8),
                const Text(
                  "min",
                  style: TextStyle(
                    color: textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Steps (dynamic list)
            Row(
              children: [
                _label("Steps :"),
                const Spacer(),
                _circleIconButton(icon: Icons.add, onTap: _addStep),
              ],
            ),
            const SizedBox(height: 8),

            ...List.generate(stepCtrls.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 22,
                      child: Text(
                        "${i + 1}.",
                        style: const TextStyle(
                          color: textSoft,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _underlineField(
                        controller: stepCtrls[i],
                        hint: "",
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Step required"
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _circleIconButton(
                      icon: Icons.close,
                      onTap: () => _removeStep(i),
                      size: 34,
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 6),

            _label("Difficulty Level :"),
            const SizedBox(height: 6),
            _inputLike(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: difficulty,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: textSoft,
                  ),
                  items: const [
                    DropdownMenuItem(value: "easy", child: Text("Easy")),
                    DropdownMenuItem(value: "medium", child: Text("Medium")),
                    DropdownMenuItem(value: "hard", child: Text("Hard")),
                  ],
                  onChanged: (v) => setState(() => difficulty = v ?? "easy"),
                  style: const TextStyle(
                    color: textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ===== Images =====
            _label("Images :"),
            const SizedBox(height: 6),

            GestureDetector(
              onTap: _pickImage, // ✅ THIS calls ImagePicker
              child: _inputLike(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        imageLabel.isEmpty ? "Choose an image" : imageLabel,
                        style: const TextStyle(
                          color: textSoft,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.file_upload_outlined, color: textSoft),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ✅ Preview (only if image selected)
            if (selectedImageFile != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    selectedImageFile!,
                    width: 180,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            Center(
              child: SizedBox(
                width: 140,
                height: 40,
                child: ElevatedButton(
                  onPressed: saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btn,
                    foregroundColor: Colors.white,
                    elevation: 10,
                    shadowColor: Colors.black54,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Add",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== Helpers ==================

  Widget _label(String t) => Text(
    t,
    style: const TextStyle(
      color: textSoft,
      fontSize: 13,
      fontWeight: FontWeight.w700,
    ),
  );

  Widget _inputLike({required Widget child}) => Container(
    height: 42,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF0E8DA),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: stroke, width: 1.2),
      boxShadow: const [
        BoxShadow(color: shadow, blurRadius: 8, offset: Offset(0, 4)),
      ],
    ),
    alignment: Alignment.centerLeft,
    child: child,
  );

  Widget _underlineField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    validator: validator,
    style: const TextStyle(
      color: Color(0xFF2F2A22),
      fontWeight: FontWeight.w600,
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFBFB2A0)),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: stroke, width: 1.4),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: stroke, width: 2.0),
      ),
    ),
  );

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    double size = 40,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: size,
      width: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: shadow, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Icon(icon, color: textSoft),
    ),
  );

  Widget _smallBoxNumber(String text) => Container(
    width: 46,
    height: 38,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFFF0E8DA),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: stroke, width: 1.2),
      boxShadow: const [
        BoxShadow(color: shadow, blurRadius: 8, offset: Offset(0, 4)),
      ],
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: textSoft,
        fontWeight: FontWeight.w800,
        fontSize: 14,
      ),
    ),
  );

  Widget _upDown({required VoidCallback onUp, required VoidCallback onDown}) =>
      Container(
        width: 26,
        height: 43,
        decoration: BoxDecoration(
          color: const Color(0xFFF0E8DA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: stroke, width: 1.2),
          boxShadow: const [
            BoxShadow(color: shadow, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            InkWell(
              onTap: onUp,
              child: const SizedBox(
                height: 20,
                child: Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: textSoft,
                  size: 18,
                ),
              ),
            ),
            InkWell(
              onTap: onDown,
              child: const SizedBox(
                height: 20,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: textSoft,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      );
}
