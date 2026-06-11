// lib/features/add_task/add_task_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:secondmind/core/theme/app_theme.dart';
import 'package:secondmind/data/models/task_model.dart';
import 'package:secondmind/features/tasks/controllers/task_controller.dart';
import 'package:uuid/uuid.dart';
import 'package:secondmind/features/qr_scanner/qr_scanner_screen.dart';
import 'package:secondmind/data/services/smart_analyzer_service.dart';
import 'dart:io';
import 'package:secondmind/data/services/gemini_service.dart';
import 'package:secondmind/data/services/notification_service.dart';
import 'package:secondmind/data/services/sound_service.dart';
import 'package:secondmind/data/services/event_service.dart';
import 'package:secondmind/widgets/fee_section.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  TaskPriority _priority = TaskPriority.medium;
  bool _isAnalyzing = false;
  String _textToAnalyze = '';
  String? _location;
  AttendanceType? _attendanceType;
  String? _meetingLink;
  String? _organizer;
  String? _contactPhone;
  String? _contactEmail;
  String? _registrationLink;
  String? _additionalNotes;
  String? _fee;
  String? _feeType;
  String? _feeCurrency;
  double? _feeAmount;
  String? _feeNote;

  late final SmartAnalyzerService _analyzerService;
  late final GeminiService _geminiService;

  final ImagePicker _picker = ImagePicker();
  late final TaskController _taskController;

  @override
  void initState() {
    super.initState();
    _analyzerService = SmartAnalyzerService();
    _geminiService = GeminiService();
    _taskController = Get.isRegistered<TaskController>()
        ? Get.find<TaskController>()
        : Get.put(TaskController());
  }

  @override
  void dispose() {
    _analyzerService.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  //============================================================================
  // BUILD FORM FIELD (الدالة المفقودة)
  //============================================================================
  Widget _buildFormField({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.secondary),
            const SizedBox(width: 6),
            Text(label,
                style: AppTheme.labelSm.copyWith(color: AppTheme.secondary)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: child,
        ),
      ],
    );
  }

  //============================================================================
  // NEW FIELDS WIDGETS
  //============================================================================
  Widget _buildLocationField() {
    return _buildFormField(
      label: 'المكان',
      icon: Icons.location_on,
      child: TextField(
        onChanged: (value) => _location = value,
        style: AppTheme.bodyLg,
        decoration: const InputDecoration(
          hintText: 'مثال: شارع التحلية، الرياض',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildAttendanceTypeField() {
    return _buildFormField(
      label: 'نوع الحضور',
      icon: Icons.people,
      child: DropdownButton<AttendanceType>(
        value: _attendanceType,
        isExpanded: true,
        hint: Text('اختر نوع الحضور',
            style: AppTheme.bodyMd.copyWith(color: AppTheme.outline)),
        underline: const SizedBox(),
        items: AttendanceType.values.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(type.displayName),
          );
        }).toList(),
        onChanged: (value) => setState(() => _attendanceType = value),
      ),
    );
  }

  Widget _buildMeetingLinkField() {
    return _buildFormField(
      label: 'رابط الحضور',
      icon: Icons.link,
      child: TextField(
        onChanged: (value) => _meetingLink = value,
        style: AppTheme.bodyLg,
        decoration: const InputDecoration(
          hintText: 'https://meet.google.com/...',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildOrganizerField() {
    return _buildFormField(
      label: 'الجهة المنظمة',
      icon: Icons.business,
      child: TextField(
        onChanged: (value) => _organizer = value,
        style: AppTheme.bodyLg,
        decoration: const InputDecoration(
          hintText: 'مثال: شركة قفزة لاب',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildContactField() {
    return Row(
      children: [
        Expanded(
          child: _buildFormField(
            label: 'رقم الاتصال',
            icon: Icons.phone,
            child: TextField(
              onChanged: (value) => _contactPhone = value,
              keyboardType: TextInputType.phone,
              style: AppTheme.bodyLg,
              decoration: const InputDecoration(
                hintText: '05XXXXXXXX',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFormField(
            label: 'البريد الإلكتروني',
            icon: Icons.email,
            child: TextField(
              onChanged: (value) => _contactEmail = value,
              keyboardType: TextInputType.emailAddress,
              style: AppTheme.bodyLg,
              decoration: const InputDecoration(
                hintText: 'example@domain.com',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationLinkField() {
    return _buildFormField(
      label: 'رابط التسجيل',
      icon: Icons.app_registration,
      child: TextField(
        onChanged: (value) => _registrationLink = value,
        style: AppTheme.bodyLg,
        decoration: const InputDecoration(
          hintText: 'https://forms.gle/...',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFeeField() {
    return _buildFormField(
      label: 'الرسوم',
      icon: Icons.money,
      child: TextField(
        onChanged: (value) => _fee = value,
        style: AppTheme.bodyLg,
        decoration: const InputDecoration(
          hintText: 'مجاني / 50 ريال',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildAdditionalNotesField() {
    return _buildFormField(
      label: 'ملاحظات إضافية',
      icon: Icons.note,
      child: TextField(
        onChanged: (value) => _additionalNotes = value,
        maxLines: 3,
        style: AppTheme.bodyLg,
        decoration: const InputDecoration(
          hintText: 'أي معلومات إضافية...',
          border: InputBorder.none,
        ),
      ),
    );
  }

  //============================================================================
  // CAMERA & GALLERY METHODS
  //============================================================================
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() => _isAnalyzing = true);

        // 1. استخراج النص من الصورة
        final smartDetails =
            await _analyzerService.analyzeImage(File(image.path));
        final rawText = smartDetails['raw_text'] ?? '';

        // 2. تحليل النص بـ Gemini إذا كان الإنترنت متاح
        Map<String, dynamic> geminiDetails = {};
        if (rawText.isNotEmpty) {
          try {
            geminiDetails = await _geminiService
                .extractTaskDetails(rawText)
                .timeout(const Duration(seconds: 10));
          } catch (e) {
            print('⚠️ Gemini غير متاح، سيتم استخدام التحليل المحلي فقط');
          }
        }

        // 3. دمج النتيجتين — Gemini له الأولوية
        setState(() {
          _titleController.text =
              geminiDetails['title'] ?? smartDetails['title'] ?? '';
          _descriptionController.text =
              geminiDetails['topics'] ?? smartDetails['notes'] ?? '';
          _location = geminiDetails['location'] ?? smartDetails['location'];
          _organizer = geminiDetails['organizer'] ?? smartDetails['organizer'];
          _fee = geminiDetails['fee'] ?? smartDetails['fee'];
          _registrationLink = geminiDetails['registration_link'] ??
              smartDetails['registration_link'];

          // نوع الحضور
          final attendanceType = geminiDetails['attendance_type'] ??
              smartDetails['attendance_type'];
          if (attendanceType == 'online') {
            _attendanceType = AttendanceType.online;
          } else if (attendanceType == 'in_person') {
            _attendanceType = AttendanceType.inPerson;
          } else if (attendanceType == 'hybrid') {
            _attendanceType = AttendanceType.hybrid;
          }

          // التاريخ والوقت
          final date = geminiDetails['date'] ?? smartDetails['date'];
          final time = geminiDetails['time'] ?? smartDetails['time'];
          if (date != null) _tryParseDate(date);
          if (time != null) _tryParseTime(time);
        });

        _showSnackbarWithSound('تنبيه', 'الرجاء إدخال نص أو رفع صورة',
            isError: true);
      }
    } catch (e) {
      print('❌ خطأ: $e');
      Get.snackbar('خطأ', 'فشل في تحليل الصورة',
          backgroundColor: AppTheme.errorContainer,
          colorText: AppTheme.onErrorContainer);
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _isAnalyzing = true);

        // 1. استخراج النص من الصورة
        final smartDetails =
            await _analyzerService.analyzeImage(File(image.path));
        final rawText = smartDetails['raw_text'] ?? '';

        // 2. تحليل النص بـ Gemini إذا كان الإنترنت متاح
        Map<String, dynamic> geminiDetails = {};
        if (rawText.isNotEmpty) {
          try {
            geminiDetails = await _geminiService
                .extractTaskDetails(rawText)
                .timeout(const Duration(seconds: 10));
          } catch (e) {
            print('⚠️ Gemini غير متاح، سيتم استخدام التحليل المحلي فقط');
          }
        }

        // 3. دمج النتيجتين — Gemini له الأولوية
        setState(() {
          _titleController.text =
              geminiDetails['title'] ?? smartDetails['title'] ?? '';

          // المحاور من Gemini
          _descriptionController.text =
              geminiDetails['topics'] ?? smartDetails['notes'] ?? '';

          _location = geminiDetails['location'] ?? smartDetails['location'];
          _organizer = geminiDetails['organizer'] ?? smartDetails['organizer'];
          _fee = geminiDetails['fee'] ?? smartDetails['fee'];
          _registrationLink = geminiDetails['registration_link'] ??
              smartDetails['registration_link'];

          // نوع الحضور
          final attendanceType = geminiDetails['attendance_type'] ??
              smartDetails['attendance_type'];
          if (attendanceType == 'online') {
            _attendanceType = AttendanceType.online;
          } else if (attendanceType == 'in_person') {
            _attendanceType = AttendanceType.inPerson;
          } else if (attendanceType == 'hybrid') {
            _attendanceType = AttendanceType.hybrid;
          }

          // التاريخ والوقت
          final date = geminiDetails['date'] ?? smartDetails['date'];
          final time = geminiDetails['time'] ?? smartDetails['time'];
          if (date != null) _tryParseDate(date);
          if (time != null) _tryParseTime(time);
        });

        Get.snackbar('نجاح', 'تم استخراج التفاصيل بنجاح',
            backgroundColor: AppTheme.primary, colorText: AppTheme.onPrimary);
      }
    } catch (e) {
      print('❌ خطأ: $e');
      Get.snackbar('خطأ', 'فشل في تحليل الصورة',
          backgroundColor: AppTheme.errorContainer,
          colorText: AppTheme.onErrorContainer);
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _pasteLink() async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData?.text != null && clipboardData!.text!.isNotEmpty) {
      setState(() => _textToAnalyze = clipboardData.text!);
      Get.snackbar('نجاح', 'تم لصق الرابط بنجاح',
          backgroundColor: AppTheme.primary, colorText: AppTheme.onPrimary);
    } else {
      Get.snackbar('تنبيه', 'لا يوجد رابط في الحافظة',
          backgroundColor: AppTheme.errorContainer,
          colorText: AppTheme.onErrorContainer);
    }
  }

  void _scanQRCode() {
    Get.to(() => QRScannerScreen(
          onCodeScanned: (code) => _textToAnalyze = code,
        ));
  }

  Future<void> _analyzeText() async {
    if (_textToAnalyze.isEmpty) {
      _showSnackbarWithSound('تنبيه', 'الرجاء إدخال نص أو رفع صورة',
          isError: true);
      return;
    }

    setState(() => _isAnalyzing = true);

    final details = _analyzerService.analyzeText(_textToAnalyze);

    setState(() {
      _titleController.text = details['title'] ?? '';
      _descriptionController.text = details['topics'] ?? details['notes'] ?? '';
      _location = details['location'];
      _organizer = details['organizer'];
      _fee = details['fee'];
      _registrationLink = details['registration_link'];

      if (details['attendance_type'] == 'online') {
        _attendanceType = AttendanceType.online;
      } else if (details['attendance_type'] == 'in_person') {
        _attendanceType = AttendanceType.inPerson;
      } else if (details['attendance_type'] == 'hybrid') {
        _attendanceType = AttendanceType.hybrid;
      }

      if (details['date'] != null) _tryParseDate(details['date']);
      if (details['time'] != null) _tryParseTime(details['time']);

      _isAnalyzing = false;
    });

    Get.snackbar('نجاح', 'تم تحليل النص بنجاح',
        backgroundColor: AppTheme.primary, colorText: AppTheme.onPrimary);
  }

  void _tryParseDate(String? dateStr) {
    if (dateStr == null) return;
    try {
      final parts = dateStr.split(RegExp(r'[-/]'));
      if (parts.length == 3) {
        int year, month, day;
        if (parts[0].length == 4) {
          year = int.parse(parts[0]);
          month = int.parse(parts[1]);
          day = int.parse(parts[2]);
        } else {
          day = int.parse(parts[0]);
          month = int.parse(parts[1]);
          year = int.parse(parts[2].length == 2 ? '20${parts[2]}' : parts[2]);
        }
        _selectedDate = DateTime(year, month, day);
      }
    } catch (_) {}
  }

  void _tryParseTime(String? timeStr) {
    if (timeStr == null) return;
    try {
      // نمط 9-7 أو 7-9 (من-إلى)
      final rangeMatch =
          RegExp(r'(\d{1,2})\s*[-–]\s*(\d{1,2})').firstMatch(timeStr);
      if (rangeMatch != null) {
        // خذ الرقم الأصغر كوقت البداية
        final first = int.parse(rangeMatch.group(1)!);
        final second = int.parse(rangeMatch.group(2)!);
        final startHour = first < second ? first : second;
        final isEvening = timeStr.contains('مساء') || timeStr.contains('PM');
        _selectedTime = TimeOfDay(
          hour: isEvening && startHour < 12 ? startHour + 12 : startHour,
          minute: 0,
        );
        return;
      }

      // نمط 11:00
      final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(timeStr);
      if (match != null) {
        final hour = int.parse(match.group(1)!);
        final minute = int.parse(match.group(2)!);
        final isEvening = timeStr.contains('مساء') || timeStr.contains('PM');
        _selectedTime = TimeOfDay(
          hour: isEvening && hour < 12 ? hour + 12 : hour,
          minute: minute,
        );
      }
    } catch (_) {}
  }

  Future<void> _saveTask() async {
    if (_titleController.text.isEmpty) {
      Get.snackbar('تنبيه', 'الرجاء إدخال عنوان المهمة');
      return;
    }

    DateTime? dueDate;
    if (_selectedDate != null && _selectedTime != null) {
      dueDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    } else if (_selectedDate != null) {
      dueDate = _selectedDate;
    }

    final task = TaskModel(
      id: const Uuid().v4(),
      title: _titleController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      dueDate: dueDate,
      priority: _priority,
      status: TaskStatus.new_,
      createdAt: DateTime.now(),
      category: TaskCategory.other,
      location: _location,
      attendanceType: _attendanceType,
      meetingLink: _meetingLink,
      organizer: _organizer,
      contactPhone: _contactPhone,
      contactEmail: _contactEmail,
      registrationLink: _registrationLink,
      fee: _fee,
      additionalNotes: _additionalNotes,
    );

    await _taskController.addTask(task);

    // ✅ إضافة حدث عند إضافة مهمة
    await EventService.addEvent(
      title: '✅ مهمة جديدة',
      message: 'تم إضافة مهمة: ${_titleController.text}',
      type: 'add',
      taskId: task.id,
    );

    // ✅ تشغيل صوت الإشعار
    await SoundService.playNotificationSound();

    // ✅ إرسال إشعار
    await NotificationService.showNotification(
      title: '✅ مهمة جديدة',
      body: 'تم إضافة مهمة: ${_titleController.text}',
      playSound: false,
    );

    Get.back();
    Get.snackbar('نجاح', 'تمت إضافة المهمة بنجاح');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('إضافة مهمة ذكية'),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.primary),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAISection(),
          const SizedBox(height: 24),
          _buildFormSection(),
          const SizedBox(height: 16),
          FeeSection(
            initialFee: _fee,
            initialFeeType: _feeType,
            initialFeeCurrency: _feeCurrency,
            initialFeeAmount: _feeAmount,
            initialFeeNote: _feeNote,
            onChanged: (data) {
              _fee = data['fee'];
              _feeType = data['fee_type'];
              _feeCurrency = data['fee_currency'];
              _feeAmount = data['fee_amount'];
              _feeNote = data['fee_note'];
            },
          ),
          const SizedBox(height: 24),
          _buildSaveButton(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildAISection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryContainer.withValues(alpha: 0.15),
            AppTheme.secondaryContainer.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary]),
                borderRadius: BorderRadius.circular(20),
              ),
              child:
                  const Icon(Icons.auto_awesome, size: 30, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text('إلصاق نص أو رفع صورة',
                style: AppTheme.headlineMd.copyWith(
                    color: AppTheme.primary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('سوف يقوم الذكاء الاصطناعي باستخراج تفاصيل المهمة تلقائياً',
                style:
                    AppTheme.bodyMd.copyWith(color: AppTheme.onSurfaceVariant),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextField(
              maxLines: 4,
              style: AppTheme.bodyLg.copyWith(color: AppTheme.onSurface),
              decoration: InputDecoration(
                hintText: 'الصق المنشور أو النص هنا...',
                hintStyle: AppTheme.bodyMd.copyWith(color: AppTheme.outline),
                filled: true,
                fillColor: AppTheme.surfaceContainerLow.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        BorderSide(color: AppTheme.primary, width: 1.5)),
              ),
              onChanged: (value) => _textToAnalyze = value,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInputButton(
                    Icons.camera_alt_outlined, 'كاميرا', _pickImageFromCamera),
                _buildInputButton(Icons.photo_library_outlined, 'معرض',
                    _pickImageFromGallery),
                _buildInputButton(Icons.link_outlined, 'رابط', _pasteLink),
                _buildInputButton(
                    Icons.qr_code_scanner_outlined, 'مسح QR', _scanQRCode),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyzeText,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _isAnalyzing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, size: 18),
                          SizedBox(width: 8),
                          Text('تحليل بالذكاء الاصطناعي')
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputButton(
      IconData icon, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppTheme.outline.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, size: 26, color: AppTheme.primary),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note, size: 20, color: AppTheme.secondary),
                const SizedBox(width: 8),
                Text('تفاصيل المهمة',
                    style: AppTheme.labelMd.copyWith(
                        color: AppTheme.secondary, letterSpacing: 0.5)),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(
                label: 'عنوان المهمة',
                controller: _titleController,
                icon: Icons.title,
                hint: 'أدخل عنوان المهمة'),
            const SizedBox(height: 16),
            _buildTextField(
                label: 'الوصف',
                controller: _descriptionController,
                icon: Icons.description,
                hint: 'أضف تفاصيل إضافية...',
                maxLines: 3),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDateField()),
                const SizedBox(width: 12),
                Expanded(child: _buildTimeField()),
              ],
            ),
            const SizedBox(height: 16),
            _buildPriorityField(),
            // الحقول الجديدة
            const SizedBox(height: 24),
            Divider(color: AppTheme.outlineVariant),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.more_horiz, size: 20, color: AppTheme.secondary),
                const SizedBox(width: 8),
                Text('معلومات إضافية',
                    style: AppTheme.labelMd.copyWith(
                        color: AppTheme.secondary, letterSpacing: 0.5)),
              ],
            ),
            const SizedBox(height: 16),
            _buildLocationField(),
            const SizedBox(height: 16),
            _buildAttendanceTypeField(),
            const SizedBox(height: 16),
            if (_attendanceType == AttendanceType.online ||
                _attendanceType == AttendanceType.hybrid)
              _buildMeetingLinkField(),
            _buildOrganizerField(),
            const SizedBox(height: 16),
            _buildContactField(),
            const SizedBox(height: 16),
            _buildRegistrationLinkField(),
            const SizedBox(height: 16),
            _buildFeeField(),
            const SizedBox(height: 16),
            _buildAdditionalNotesField(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.secondary),
            const SizedBox(width: 6),
            Text(label,
                style: AppTheme.labelSm.copyWith(color: AppTheme.secondary)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: AppTheme.bodyLg.copyWith(color: AppTheme.onSurface),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTheme.bodyMd.copyWith(color: AppTheme.outline),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: AppTheme.secondary),
            const SizedBox(width: 6),
            Text('التاريخ',
                style: AppTheme.labelSm.copyWith(color: AppTheme.secondary)),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) setState(() => _selectedDate = date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'اختر التاريخ',
                  style: AppTheme.bodyLg.copyWith(
                      color: _selectedDate != null
                          ? AppTheme.onSurface
                          : AppTheme.outline),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.schedule, size: 16, color: AppTheme.secondary),
            const SizedBox(width: 6),
            Text('الوقت',
                style: AppTheme.labelSm.copyWith(color: AppTheme.secondary)),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _selectedTime ?? TimeOfDay.now(),
            );
            if (time != null) setState(() => _selectedTime = time);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Text(
                  _selectedTime != null
                      ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                      : 'اختر الوقت',
                  style: AppTheme.bodyLg.copyWith(
                      color: _selectedTime != null
                          ? AppTheme.onSurface
                          : AppTheme.outline),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.flag, size: 16, color: AppTheme.secondary),
            const SizedBox(width: 6),
            Text('الأولوية',
                style: AppTheme.labelSm.copyWith(color: AppTheme.secondary)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButton<TaskPriority>(
            value: _priority,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: AppTheme.surfaceContainerLow,
            style: AppTheme.bodyLg.copyWith(color: AppTheme.onSurface),
            items: TaskPriority.values.map((priority) {
              return DropdownMenuItem(
                value: priority,
                child: Row(
                  children: [
                    Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getPriorityColor(priority))),
                    const SizedBox(width: 10),
                    Text(_getPriorityName(priority)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _priority = value);
            },
          ),
        ),
      ],
    );
  }

  String _getPriorityName(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return 'عاجل';
      case TaskPriority.high:
        return 'عالية';
      case TaskPriority.medium:
        return 'متوسطة';
      case TaskPriority.low:
        return 'منخفضة';
    }
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveTask,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.onPrimary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save_alt, size: 22),
            SizedBox(width: 10),
            Text('حفظ المهمة')
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return AppTheme.error;
      case TaskPriority.high:
        return const Color(0xFFFFB74D);
      case TaskPriority.medium:
        return AppTheme.primary;
      case TaskPriority.low:
        return AppTheme.outline;
    }
  }

// دالة مساعدة لعرض Snackbar مع صوت
  void _showSnackbarWithSound(String title, String message,
      {bool isError = false}) {
    // تشغيل الصوت
    SoundService.playNotificationSound();

    // تحديد اللون: أحمر للخطأ، أخضر/أزرق للنجاح
    final backgroundColor = isError
        ? const Color.fromARGB(255, 214, 72, 56) // اللون الأحمر للخطأ
        : AppTheme.primary; // اللون الأساسي للنجاح

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
