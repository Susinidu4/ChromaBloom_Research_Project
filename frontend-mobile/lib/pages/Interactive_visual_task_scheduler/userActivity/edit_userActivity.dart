import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:quickalert/quickalert.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:provider/provider.dart';
import '../../../state/session_provider.dart';
import '../../../services/user_services/child_api.dart';

import '../../others/header.dart';
import '../../others/navBar.dart';

import '../../../services/Interactive_visual_task_scheduler_services/user_activity_service.dart';

class UpdateUserActivityScreen extends StatefulWidget {
  const UpdateUserActivityScreen({super.key, required this.activity});

  final Map<String, dynamic> activity;

  @override
  State<UpdateUserActivityScreen> createState() =>
      _UpdateUserActivityScreenState();
}

class _UpdateUserActivityScreenState extends State<UpdateUserActivityScreen> {
  // Theme colors
  static const Color pageBg = Color(0xFFF3E8E8);
  static const Color cardBg = Color(0xFFE9DDCC);
  static const Color stroke = Color(0xFFBD9A6B);
  static const Color textSoft = Color(0xFFBD9A6B);
  static const Color shadow = Color(0x33000000);
  static const Color btn = Color(0xFFBD9A6B);

  // Quick alert
  void showThemedAlert({
    required QuickAlertType type,
    required String title,
    required String text,
  }) {
    QuickAlert.show(
      context: context,
      type: type,
      title: title,
      text: text,
      confirmBtnText: "OK",
      confirmBtnColor: btn,
    );
  }

  // TEMP caregiver
  // static const String hardcodedCaregiverId = "p-0001";

  // Form key
  final _formKey = GlobalKey<FormState>();

  DateTime selectedDate = DateTime.now();
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  // Steps (dynamic)
  final List<TextEditingController> stepCtrls = [];

  // Dropdowns
  String ageGroup = "1";
  String developmentArea = "motor";
  String difficulty = "easy";

  // Image
  File? selectedImageFile;
  String imageLabel = "";
  String? existingImageUrl;

  bool saving = false;

  // Text field + value that you send to backend (0–60)
  final completedCtrl = TextEditingController();
  int completedMinutes = 0;

  // Format date to display in UI
  String _fmtDate(DateTime d) => "${d.day}/${d.month}/${d.year}";

  // Convert duration to minutes to send backend
  int _estimatedDurationMinutes() => completedMinutes;

  // Add a new empty step field
  void _addStep() => setState(() => stepCtrls.add(TextEditingController()));

  // Get logged caregiver id
  String _getCaregiverId() {
    final session = context.read<SessionProvider>();
    return (session.caregiver?['_id'] ?? session.caregiver?['id'] ?? '')
        .toString();
  }

  // Calculate child age using date of birth
  int calculateAgeFromDob(String dob) {
    final birthDate = DateTime.parse(dob);
    final today = DateTime.now();

    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Get logged caregiver child age of the logged caregiver
  Future<int?> _getLoggedCaregiverChildAge() async {
    final caregiverId = _getCaregiverId();
    if (caregiverId.isEmpty) return null;

    final children = await ChildApi.getChildrenByCaregiver(caregiverId);
    if (children.isEmpty) return null;

    // take first child
    final child = children.first;
    final dob = child['dateOfBirth'];
    if (dob == null) return null;

    return calculateAgeFromDob(dob.toString());
  }

  // Init state
  @override
  void initState() {
    super.initState();
    _prefillFromActivity(widget.activity);
    _loadAgeGroupFromChild();
  }

  // Load age group from logged caregiver child
  Future<void> _loadAgeGroupFromChild() async {
    final age = await _getLoggedCaregiverChildAge();
    if (!mounted) return;

    if (age == null) {
      showThemedAlert(
        type: QuickAlertType.warning,
        title: "No Child Found",
        text: "Please add a child profile first.",
      );
      return;
    }

    setState(() {
      ageGroup = age.toString();
    });
  }

  // Fill UI fields using existing activity data (Prefill form)
  void _prefillFromActivity(Map<String, dynamic> a) {
    titleCtrl.text = (a["title"] ?? "").toString();
    descCtrl.text = (a["description"] ?? "").toString();
    developmentArea = (a["development_area"] ?? "motor").toString();
    difficulty = (a["difficulty_level"] ?? "easy").toString();

    // Parse scheduled date
    final dateStr = (a["scheduled_date"] ?? "").toString();
    final parsedDate = DateTime.tryParse(dateStr);
    if (parsedDate != null) selectedDate = parsedDate;

    // Load estimated duration (minutes)
    final mins =
        int.tryParse((a["estimated_duration_minutes"] ?? "0").toString()) ?? 0;
    completedMinutes = mins.clamp(0, 60);
    completedCtrl.text = completedMinutes.toString();

    // Load Steps
    stepCtrls.clear();
    final steps = (a["steps"] as List?) ?? [];
    for (final s in steps) {
      stepCtrls.add(
        TextEditingController(text: (s["instruction"] ?? "").toString()),
      );
    }
    if (stepCtrls.isEmpty) stepCtrls.add(TextEditingController());

    // Load existing image
    final links = (a["media_links"] as List?) ?? [];
    if (links.isNotEmpty) {
      existingImageUrl = links.first.toString();
      imageLabel = "Existing image";
    }
  }

  // Dispose controllers -> Clean controllers to avoid memory leaks
  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    for (final c in stepCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  // Remove one step
  void _removeStep(int index) {
    if (stepCtrls.length <= 1) return;
    setState(() {
      stepCtrls[index].dispose();
      stepCtrls.removeAt(index);
    });
  }

  // Date picker
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
              surface: Color(0xFFDFC7A7),
              onSurface: Color(0xFF2F2A22),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  // Image picker
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

  // Convert image file to base64 data URI to send backend
  Future<String?> _fileToBase64DataUri(File? f) async {
    if (f == null) return null;
    final bytes = await f.readAsBytes();
    final b64 = base64Encode(bytes);

    // basic mime guess (good enough for png/jpg)
    final lower = f.path.toLowerCase();
    final mime = lower.endsWith(".png")
        ? "image/png"
        : (lower.endsWith(".webp") ? "image/webp" : "image/jpeg");

    return "data:$mime;base64,$b64";
  }

  // Update activity
  Future<void> _submitUpdate() async {
    final mongoId = (widget.activity["_id"] ?? "").toString();

    // Check activity ID
    if (mongoId.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Update Failed",
        text: "Cannot update: missing activity ID.",
        confirmBtnText: "OK",
        confirmBtnColor: btn,
      );
      return;
    }

    // build steps as array
    final steps = List.generate(stepCtrls.length, (i) {
      return {"step_number": i + 1, "instruction": stepCtrls[i].text.trim()};
    });

    // Development area required
    if (developmentArea.trim().isEmpty) {
      showThemedAlert(
        type: QuickAlertType.warning,
        title: "Development Area Required",
        text: "Please select a development area.",
      );
      return;
    }

    // Title required
    if (titleCtrl.text.trim().isEmpty) {
      showThemedAlert(
        type: QuickAlertType.warning,
        title: "Title Required",
        text: "Please enter the title.",
      );
      return;
    }

    // Description required
    if (descCtrl.text.trim().isEmpty) {
      showThemedAlert(
        type: QuickAlertType.warning,
        title: "Description Required",
        text: "Please enter the description.",
      );
      return;
    }

    // Duration required
    if (completedMinutes <= 0) {
      showThemedAlert(
        type: QuickAlertType.warning,
        title: "Duration Required",
        text: "Please enter duration (1–60 minutes).",
      );
      return;
    }

    // steps required
    for (int i = 0; i < stepCtrls.length; i++) {
      if (stepCtrls[i].text.trim().isEmpty) {
        showThemedAlert(
          type: QuickAlertType.warning,
          title: "Step Required",
          text: "Please fill step ${i + 1}.",
        );
        return;
      }
    }

    // Difficulty required
    if (difficulty.trim().isEmpty) {
      showThemedAlert(
        type: QuickAlertType.warning,
        title: "Difficulty Required",
        text: "Please select a difficulty level.",
      );
      return;
    }

    setState(() => saving = true);

    try {
      final imgBase64 = await _fileToBase64DataUri(selectedImageFile);

      final caregiverId = _getCaregiverId();

      if (caregiverId.isEmpty) {
        showThemedAlert(
          type: QuickAlertType.error,
          title: "Session Error",
          text: "Please login again.",
        );
        return;
      }

      // Call backend update API
      final res = await UserActivityService.updateUserActivity(
        activityId: mongoId,
        createdBy: caregiverId,
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        ageGroup: ageGroup,
        developmentArea: developmentArea,
        scheduledDate: selectedDate,
        estimatedDurationMinutes: _estimatedDurationMinutes(),
        difficultyLevel: difficulty,
        steps: steps,
        mediaImageBase64: imgBase64,
      );

      if (!mounted) return;

      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Updated",
        text: (res["message"] ?? "Activity updated successfully").toString(),
        confirmBtnText: "OK",
        confirmBtnColor: btn,
        onConfirmBtnTap: () {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.pop(context, true);
        },
      );
    } catch (e) {
      if (!mounted) return;
      showThemedAlert(
        type: QuickAlertType.error,
        title: "Update Failed",
        text: "Update failed: $e",
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const MainHeader(
              title: "Hello!",
              subtitle: "Welcome back",
            ),
            // Body
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
      // Navigation Bar
      bottomNavigationBar: const MainNavBar(currentIndex: 1),
    );
  }

  // Form card
  Widget _buildFormCard(BuildContext context) {
    return Container(
      // Card style
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: shadow, blurRadius: 16, offset: Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),

      // Form
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title row + close
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Update your task...",
                    style: TextStyle(
                      color: textSoft,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: textSoft,
                    ),
                  ),
                ),
                // Close
                _circleIconButton(
                  icon: Icons.close,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Top image
            Center(
              child: Image.asset(
                "assets/InteractiveVisualTaskScheduler/create_user_activity.png",
                width: 180,
                height: 160,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 18),

            // Date picker
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

            // Development area dropdown
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
                      setState(() => developmentArea = v ?? "self-care"),
                  style: const TextStyle(
                    color: textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Title
            _label("Title :"),
            const SizedBox(height: 6),
            _underlineField(
              controller: titleCtrl,
              hint: "",
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? "Title required" : null,
            ),

            const SizedBox(height: 12),

            // Description
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

                // editable number box
                Container(
                  width: 56,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E8DA),
                    border: Border.all(color: stroke, width: 1.2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: shadow,
                        blurRadius: 10,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: completedCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (v) {
                      final n = int.tryParse(v) ?? 0;
                      final clamped = n.clamp(0, 60);
                      setState(() => completedMinutes = clamped);
                      completedCtrl.text = clamped.toString();
                      completedCtrl.selection = TextSelection.collapsed(
                        offset: completedCtrl.text.length,
                      );
                    },
                  ),
                ),

                const SizedBox(width: 6),

                // Up/down arrows
                Container(
                  width: 26,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E8DA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: stroke, width: 1.2),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(
                              () => completedMinutes = (completedMinutes + 1)
                                  .clamp(0, 60),
                            );
                            completedCtrl.text = completedMinutes.toString();
                          },
                          child: const Icon(
                            Icons.keyboard_arrow_up_rounded,
                            color: textSoft,
                            size: 18,
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(
                              () => completedMinutes = (completedMinutes - 1)
                                  .clamp(0, 60),
                            );
                            completedCtrl.text = completedMinutes.toString();
                          },
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: textSoft,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

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

            // Steps
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

            // Difficulty level dropdown
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

            // Image picker
            _label("Images :"),
            const SizedBox(height: 6),

            GestureDetector(
              onTap: _pickImage,
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

            // preview (new picked)
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

            // preview (existing)
            if (selectedImageFile == null && existingImageUrl != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    existingImageUrl!,
                    width: 180,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Text("Image load failed"),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Submit button
            Center(
              child: SizedBox(
                width: 160,
                height: 40,
                child: ElevatedButton(
                  onPressed: saving ? null : _submitUpdate,
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
                          "Update",
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

  // ================== Helpers ================== //

  // Label widget
  Widget _label(String t) => Text(
    t,
    style: const TextStyle(
      color: textSoft,
      fontSize: 13,
      fontWeight: FontWeight.w700,
    ),
  );

  // Input-like container
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

  // Underline text field
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

  // Circle icon button (add/close buttons)
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
}
