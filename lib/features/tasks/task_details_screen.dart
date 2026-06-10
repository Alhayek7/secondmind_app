// lib/features/tasks/task_details_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondmind/core/theme/app_theme.dart';
import 'package:secondmind/data/models/task_model.dart';
import 'package:secondmind/features/tasks/controllers/task_controller.dart';
import 'package:intl/intl.dart';
import 'package:secondmind/data/services/sound_service.dart';
import 'package:secondmind/data/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:secondmind/data/services/event_service.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailsScreen({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late final TaskController _taskController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  late TaskPriority _selectedPriority;
  late TaskCategory _selectedCategory;
  late TaskStatus _selectedStatus;

  String? _location;
  AttendanceType? _attendanceType;
  String? _meetingLink;
  String? _organizer;
  String? _contactPhone;
  String? _contactEmail;
  String? _registrationLink;
  String? _fee;
  String? _additionalNotes;
  int? _reminderMinutes;
  final List<int> _reminderOptions = [0, 5, 10, 15, 30, 60, 120];
  bool _isReminderSet = false;
  int? _scheduledReminderId;
  Timer? _countdownTimer;
  String _timeRemainingText = '';
  Color _timeRemainingColor = AppTheme.primary;
  IconData _timeRemainingIcon = Icons.timer_outlined;

  bool _isEditing = false;
  bool _isLoading = false;

  //============================================================================
  // HELPER METHODS FOR DISPLAY NAMES
  //============================================================================
  String _getStatusName(TaskStatus status) {
    switch (status) {
      case TaskStatus.new_:
        return 'جديد';
      case TaskStatus.inProgress:
        return 'قيد التنفيذ';
      case TaskStatus.completed:
        return 'مكتمل';
      case TaskStatus.missed: // ✅ أضف هذا
        return 'فائتة';
    }
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

  String _getCategoryName(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return 'العمل';
      case TaskCategory.personal:
        return 'شخصي';
      case TaskCategory.study:
        return 'دراسة';
      case TaskCategory.urgent:
        return 'عاجل';
      case TaskCategory.other:
        return 'أخرى';
    }
  }

  String _getAttendanceTypeName(AttendanceType? type) {
    if (type == null) return 'غير محدد';
    switch (type) {
      case AttendanceType.online:
        return 'أونلاين';
      case AttendanceType.inPerson:
        return 'وجاهي';
      case AttendanceType.hybrid:
        return 'مختلط';
    }
  }

  @override
  void initState() {
    super.initState();
    _taskController = Get.find<TaskController>();
    _startCountdownTimer();

    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description ?? '');
    _selectedDate = widget.task.dueDate;
    _selectedPriority = widget.task.priority;
    _selectedCategory = widget.task.category;
    _selectedStatus = widget.task.status;
    _location = widget.task.location;
    _attendanceType = widget.task.attendanceType;
    _meetingLink = widget.task.meetingLink;
    _organizer = widget.task.organizer;
    _contactPhone = widget.task.contactPhone;
    _contactEmail = widget.task.contactEmail;
    _registrationLink = widget.task.registrationLink;
    _fee = widget.task.fee;
    _additionalNotes = widget.task.additionalNotes;

    if (widget.task.dueDate != null) {
      _selectedTime = TimeOfDay(
        hour: widget.task.dueDate!.hour,
        minute: widget.task.dueDate!.minute,
      );
    }

    // ✅ تحميل إعدادات التذكير المحفوظة
    _loadReminderSettings();
  }

  Future<void> _loadReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedReminder = prefs.getInt('reminder_${widget.task.id}');
    if (savedReminder != null) {
      setState(() {
        _reminderMinutes = savedReminder;
        _isReminderSet = true;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
    _countdownTimer?.cancel();
  }

  Widget _buildReminderSection() {
    return _buildDetailCard(
      icon: Icons.alarm,
      label: 'تذكير',
      color: AppTheme.statusPending,
      child: Column(
        children: [
          SwitchListTile(
            title: Text('تفعيل التذكير', style: AppTheme.bodyLg),
            subtitle: Text('تذكير قبل موعد المهمة',
                style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
            value: _isReminderSet,
            onChanged: (value) {
              setState(() {
                _isReminderSet = value;
                if (!value) _reminderMinutes = null;
              });
            },
            activeTrackColor: AppTheme.primary,
            activeThumbColor: AppTheme.primary,
            secondary:
                Icon(Icons.notifications_active, color: AppTheme.primary),
          ),
          if (_isReminderSet) ...[
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _reminderMinutes ?? 5,
                    decoration: InputDecoration(
                      labelText: 'وقت التذكير قبل الموعد',
                      prefixIcon: Icon(Icons.timer, color: AppTheme.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _reminderOptions.map((minutes) {
                      String label;
                      if (minutes == 0) {
                        label = 'في الوقت المحدد';
                      } else if (minutes < 60) {
                        label = 'قبل $minutes دقيقة';
                      } else {
                        final hours = minutes ~/ 60;
                        label = 'قبل $hours ساعة';
                      }
                      return DropdownMenuItem(
                        value: minutes,
                        child: Row(
                          children: [
                            Icon(Icons.alarm,
                                size: 16, color: AppTheme.primary),
                            const SizedBox(width: 8),
                            Text(label),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _reminderMinutes = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'سيتم إرسال إشعار صوتي ومرئي قبل موعد المهمة',
                      style: AppTheme.labelSm.copyWith(color: AppTheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _cancelExistingReminder() async {
    if (_scheduledReminderId != null) {
      await NotificationService.cancelNotification(_scheduledReminderId!);
    }
  }

Future<void> _saveChanges() async {
  if (_titleController.text.trim().isEmpty) {
    Get.snackbar('تنبيه', 'الرجاء إدخال عنوان المهمة');
    return;
  }

  setState(() => _isLoading = true);

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

  final updatedTask = widget.task.copyWith(
    title: _titleController.text.trim(),
    description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
    dueDate: dueDate,
    priority: _selectedPriority,
    category: _selectedCategory,
    status: _selectedStatus,
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

  await _cancelExistingReminder();

  if (_isReminderSet && _reminderMinutes != null && dueDate != null) {
    final reminderTime = dueDate.subtract(Duration(minutes: _reminderMinutes!));
    if (reminderTime.isAfter(DateTime.now())) {
      final reminderId = DateTime.now().millisecondsSinceEpoch % 10000;
      _scheduledReminderId = reminderId;
      
      await NotificationService.scheduleTaskReminder(
        id: reminderId,
        title: '🔔 تذكير: ${_titleController.text.trim()}',
        body: 'موعد المهمة بعد ${_reminderMinutes} دقيقة',
        scheduledTime: reminderTime,
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reminder_${widget.task.id}', _reminderMinutes!);
    }
  }

  await _taskController.updateTask(updatedTask);
  
  // ✅ إضافة حدث عند تعديل المهمة
  await EventService.addEvent(
    title: '✏️ تم التعديل',
    message: 'تم تعديل مهمة: ${_titleController.text.trim()}',
    type: 'edit',
    taskId: updatedTask.id,
  );
  
  await SoundService.playNotificationSound();
  await NotificationService.showNotification(
    title: '✏️ تم التعديل',
    body: 'تم تعديل مهمة: ${_titleController.text.trim()}',
    playSound: false,
  );
  
  setState(() => _isLoading = false);
  
  Get.back(result: true);
  Get.snackbar('نجاح', 'تم تحديث المهمة بنجاح');
}

Future<void> _deleteTask() async {
  final confirmed = await Get.dialog<bool>(
    AlertDialog(
      backgroundColor: AppTheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('حذف المهمة'),
      content: Text('هل أنت متأكد من حذف مهمة "${widget.task.title}"؟'),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: true), // ✅ إرجاع true وإغلاق النافذة
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
          child: const Text('حذف'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await _taskController.deleteTask(widget.task.id);
    Get.back(result: true); // ✅ إغلاق صفحة التفاصيل
    Get.snackbar('تم الحذف', 'تم حذف المهمة بنجاح');
  }
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
      title: Text(_isEditing ? 'تعديل المهمة' : 'تفاصيل المهمة'),
      centerTitle: true,
      backgroundColor: AppTheme.surface.withValues(alpha: 0.95),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.primary),
        onPressed: () => Get.back(),
      ),
      actions: [
        if (!_isEditing)
          IconButton(
            icon: Icon(Icons.edit_outlined, color: AppTheme.primary),
            onPressed: () => setState(() => _isEditing = true),
          ),
        if (_isEditing)
          TextButton.icon(
            onPressed: _saveChanges,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(Icons.save, size: 18),
            label: Text(_isLoading ? 'جاري الحفظ...' : 'حفظ'),
          ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 20),
          _buildTimeRemainingCard(), // ✅ أضف هذا
          const SizedBox(height: 16),

          _buildStatusSection(),
          const SizedBox(height: 16),
          _buildTitleSection(),
          const SizedBox(height: 16),
          _buildDescriptionSection(),
          const SizedBox(height: 16),
          _buildDateTimeSection(),
          const SizedBox(height: 16),
          _buildPrioritySection(),
          const SizedBox(height: 16),
          _buildCategorySection(),
          const SizedBox(height: 16),
          _buildLocationSection(),
          const SizedBox(height: 16),
          _buildAttendanceSection(),
          const SizedBox(height: 16),
          if (_attendanceType == AttendanceType.online ||
              _attendanceType == AttendanceType.hybrid)
            _buildMeetingLinkSection(),
          _buildOrganizerSection(),
          const SizedBox(height: 16),
          _buildContactSection(),
          const SizedBox(height: 16),
          _buildRegistrationLinkSection(),
          const SizedBox(height: 16),
          _buildFeeSection(),
          const SizedBox(height: 16),
          _buildAdditionalNotesSection(),
          const SizedBox(height: 16),
          _buildReminderSection(), // ✅ أضف هذا
          const SizedBox(height: 24),
          if (!_isEditing) _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withValues(alpha: 0.08),
            AppTheme.primaryContainer.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(_getStatusIcon(), color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.task.title,
                    style: AppTheme.headlineMd
                        .copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                    'تم الإنشاء: ${DateFormat('yyyy/MM/dd').format(widget.task.createdAt)}',
                    style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return _buildDetailCard(
      icon: Icons.track_changes,
      label: 'حالة المهمة',
      color: _getStatusColor(),
      child: _isEditing
          ? DropdownButton<TaskStatus>(
              value: _selectedStatus,
              isExpanded: true,
              underline: const SizedBox(),
              items: TaskStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Row(
                    children: [
                      Icon(_getStatusIconForStatus(status),
                          size: 18, color: _getStatusColorForStatus(status)),
                      const SizedBox(width: 10),
                      Text(_getStatusName(status)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedStatus = value);
              },
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getStatusIcon(), size: 16, color: _getStatusColor()),
                  const SizedBox(width: 6),
                  Text(_getStatusName(_selectedStatus),
                      style:
                          AppTheme.labelMd.copyWith(color: _getStatusColor())),
                ],
              ),
            ),
    );
  }

  Widget _buildTitleSection() {
    return _buildDetailCard(
      icon: Icons.title,
      label: 'عنوان المهمة',
      child: _isEditing
          ? TextField(
              controller: _titleController,
              style: AppTheme.headlineMd,
              decoration: const InputDecoration(
                  hintText: 'أدخل عنوان المهمة', border: InputBorder.none),
            )
          : Text(widget.task.title,
              style: AppTheme.headlineMd.copyWith(fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildDescriptionSection() {
    return _buildDetailCard(
      icon: Icons.description,
      label: 'الوصف',
      child: _isEditing
          ? TextField(
              controller: _descriptionController,
              maxLines: 4,
              style: AppTheme.bodyLg,
              decoration: const InputDecoration(
                  hintText: 'أضف تفاصيل إضافية...', border: InputBorder.none),
            )
          : Text(widget.task.description ?? 'لا يوجد وصف',
              style: AppTheme.bodyLg.copyWith(
                  color: widget.task.description == null
                      ? AppTheme.outline
                      : AppTheme.onSurface)),
    );
  }

  Widget _buildDateTimeSection() {
    return _buildDetailCard(
      icon: Icons.calendar_today,
      label: 'تاريخ الاستحقاق',
      child: _isEditing
          ? Row(
              children: [
                Expanded(child: _buildDatePicker()),
                const SizedBox(width: 12),
                Expanded(child: _buildTimePicker()),
              ],
            )
          : Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                    widget.task.dueDate != null
                        ? DateFormat('yyyy/MM/dd - HH:mm')
                            .format(widget.task.dueDate!)
                        : 'لم يحدد',
                    style: AppTheme.bodyLg),
              ],
            ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.calendar_today, size: 18, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(
                _selectedDate != null
                    ? DateFormat('yyyy/MM/dd').format(_selectedDate!)
                    : 'اختر التاريخ',
                style: AppTheme.bodyLg),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
            context: context, initialTime: _selectedTime ?? TimeOfDay.now());
        if (time != null) setState(() => _selectedTime = time);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.schedule, size: 18, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(
                _selectedTime != null
                    ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                    : 'اختر الوقت',
                style: AppTheme.bodyLg),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySection() {
    return _buildDetailCard(
      icon: Icons.flag,
      label: 'الأولوية',
      child: _isEditing
          ? DropdownButton<TaskPriority>(
              value: _selectedPriority,
              isExpanded: true,
              underline: const SizedBox(),
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
                if (value != null) setState(() => _selectedPriority = value);
              },
            )
          : Row(
              children: [
                Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getPriorityColor(_selectedPriority))),
                const SizedBox(width: 10),
                Text(_getPriorityName(_selectedPriority),
                    style: AppTheme.bodyLg.copyWith(
                        color: _getPriorityColor(_selectedPriority),
                        fontWeight: FontWeight.w500)),
              ],
            ),
    );
  }

  Widget _buildCategorySection() {
    return _buildDetailCard(
      icon: Icons.category,
      label: 'التصنيف',
      child: _isEditing
          ? DropdownButton<TaskCategory>(
              value: _selectedCategory,
              isExpanded: true,
              underline: const SizedBox(),
              items: TaskCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(_getCategoryName(category)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedCategory = value);
              },
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(_getCategoryName(_selectedCategory),
                  style: AppTheme.labelMd.copyWith(color: AppTheme.primary)),
            ),
    );
  }

  Widget _buildLocationSection() {
    return _buildDetailCard(
      icon: Icons.location_on,
      label: 'المكان',
      child: _isEditing
          ? TextField(
              onChanged: (value) => _location = value,
              controller: TextEditingController(text: _location),
              style: AppTheme.bodyLg,
              decoration: const InputDecoration(
                  hintText: 'أدخل المكان', border: InputBorder.none),
            )
          : Text(_location ?? 'غير محدد',
              style: AppTheme.bodyLg.copyWith(
                  color: _location == null
                      ? AppTheme.outline
                      : AppTheme.onSurface)),
    );
  }

  Widget _buildAttendanceSection() {
    return _buildDetailCard(
      icon: Icons.people,
      label: 'نوع الحضور',
      child: _isEditing
          ? DropdownButton<AttendanceType>(
              value: _attendanceType,
              isExpanded: true,
              hint: Text('اختر نوع الحضور',
                  style: AppTheme.bodyMd.copyWith(color: AppTheme.outline)),
              underline: const SizedBox(),
              items: AttendanceType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getAttendanceTypeName(type)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _attendanceType = value),
            )
          : Text(_getAttendanceTypeName(_attendanceType),
              style: AppTheme.bodyLg),
    );
  }

  Widget _buildMeetingLinkSection() {
    return _buildDetailCard(
      icon: Icons.link,
      label: 'رابط الحضور',
      child: _isEditing
          ? TextField(
              onChanged: (value) => _meetingLink = value,
              controller: TextEditingController(text: _meetingLink),
              style: AppTheme.bodyLg,
              decoration: const InputDecoration(
                  hintText: 'https://...', border: InputBorder.none),
            )
          : SelectableText(_meetingLink ?? 'غير محدد',
              style: AppTheme.bodyLg.copyWith(
                  color: _meetingLink == null
                      ? AppTheme.outline
                      : AppTheme.primary)),
    );
  }

  Widget _buildOrganizerSection() {
    return _buildDetailCard(
      icon: Icons.business,
      label: 'الجهة المنظمة',
      child: _isEditing
          ? TextField(
              onChanged: (value) => _organizer = value,
              controller: TextEditingController(text: _organizer),
              style: AppTheme.bodyLg,
              decoration: const InputDecoration(
                  hintText: 'اسم الجهة المنظمة', border: InputBorder.none),
            )
          : Text(_organizer ?? 'غير محدد', style: AppTheme.bodyLg),
    );
  }

  Widget _buildContactSection() {
    return _buildDetailCard(
      icon: Icons.contact_phone,
      label: 'معلومات الاتصال',
      child: _isEditing
          ? Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => _contactPhone = value,
                    controller: TextEditingController(text: _contactPhone),
                    keyboardType: TextInputType.phone,
                    style: AppTheme.bodyLg,
                    decoration: const InputDecoration(
                        hintText: 'رقم الهاتف', border: InputBorder.none),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    onChanged: (value) => _contactEmail = value,
                    controller: TextEditingController(text: _contactEmail),
                    keyboardType: TextInputType.emailAddress,
                    style: AppTheme.bodyLg,
                    decoration: const InputDecoration(
                        hintText: 'البريد الإلكتروني',
                        border: InputBorder.none),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_contactPhone != null)
                  Text('📞 $_contactPhone', style: AppTheme.bodyLg),
                if (_contactEmail != null)
                  Text('📧 $_contactEmail', style: AppTheme.bodyLg),
                if (_contactPhone == null && _contactEmail == null)
                  Text('غير محدد',
                      style: AppTheme.bodyLg.copyWith(color: AppTheme.outline)),
              ],
            ),
    );
  }

  Widget _buildRegistrationLinkSection() {
    return _buildDetailCard(
      icon: Icons.app_registration,
      label: 'رابط التسجيل',
      child: _isEditing
          ? TextField(
              onChanged: (value) => _registrationLink = value,
              controller: TextEditingController(text: _registrationLink),
              style: AppTheme.bodyLg,
              decoration: const InputDecoration(
                  hintText: 'https://...', border: InputBorder.none),
            )
          : SelectableText(_registrationLink ?? 'غير محدد',
              style: AppTheme.bodyLg.copyWith(
                  color: _registrationLink == null
                      ? AppTheme.outline
                      : AppTheme.primary)),
    );
  }

  Widget _buildFeeSection() {
    return _buildDetailCard(
      icon: Icons.money,
      label: 'الرسوم',
      child: _isEditing
          ? TextField(
              onChanged: (value) => _fee = value,
              controller: TextEditingController(text: _fee),
              style: AppTheme.bodyLg,
              decoration: const InputDecoration(
                  hintText: 'مجاني / 50 ريال', border: InputBorder.none),
            )
          : Text(_fee ?? 'غير محدد', style: AppTheme.bodyLg),
    );
  }

  Widget _buildAdditionalNotesSection() {
    return _buildDetailCard(
      icon: Icons.note,
      label: 'ملاحظات إضافية',
      child: _isEditing
          ? TextField(
              onChanged: (value) => _additionalNotes = value,
              controller: TextEditingController(text: _additionalNotes),
              maxLines: 3,
              style: AppTheme.bodyLg,
              decoration: const InputDecoration(
                  hintText: 'أي ملاحظات إضافية...', border: InputBorder.none),
            )
          : Text(_additionalNotes ?? 'لا توجد ملاحظات',
              style: AppTheme.bodyLg.copyWith(
                  color: _additionalNotes == null
                      ? AppTheme.outline
                      : AppTheme.onSurface)),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required Widget child,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
        border:
            Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: (color ?? AppTheme.primary).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: color ?? AppTheme.primary),
              ),
              const SizedBox(width: 10),
              Text(label,
                  style: AppTheme.labelMd.copyWith(
                      color: color ?? AppTheme.primary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => setState(() => _isEditing = true),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('تعديل المهمة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _deleteTask,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('حذف المهمة'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.error,
              side: BorderSide(color: AppTheme.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (_selectedStatus) {
      case TaskStatus.completed:
        return AppTheme.statusCompleted;
      case TaskStatus.inProgress:
        return AppTheme.statusPending;
      case TaskStatus.missed: // ✅ أضف هذا
        return AppTheme.error;
      default:
        return AppTheme.primary;
    }
  }

  IconData _getStatusIcon() {
    switch (_selectedStatus) {
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.inProgress:
        return Icons.play_circle;
      case TaskStatus.missed: // ✅ أضف هذا
        return Icons.warning_amber;
      default:
        return Icons.pending;
    }
  }

  IconData _getStatusIconForStatus(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.inProgress:
        return Icons.play_circle;
      case TaskStatus.missed: // ✅ أضف هذا
        return Icons.warning_amber;
      default:
        return Icons.pending;
    }
  }

  Color _getStatusColorForStatus(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return AppTheme.statusCompleted;
      case TaskStatus.inProgress:
        return AppTheme.statusPending;
      case TaskStatus.missed: // ✅ أضف هذا
        return AppTheme.error;
      default:
        return AppTheme.primary;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return AppTheme.error;
      case TaskPriority.high:
        return AppTheme.statusPending;
      case TaskPriority.low:
        return AppTheme.outline;
      default:
        return AppTheme.primary;
    }
  }

  void _updateTimeRemaining() {
    if (widget.task.dueDate == null) {
      _timeRemainingText = 'لم يتم تحديد موعد';
      _timeRemainingColor = AppTheme.outline;
      _timeRemainingIcon = Icons.calendar_today;
      return;
    }

    final now = DateTime.now();
    final dueDate = widget.task.dueDate!;

    // إذا كانت المهمة مكتملة
    if (widget.task.status == TaskStatus.completed) {
      _timeRemainingText = '✓ مكتملة';
      _timeRemainingColor = AppTheme.statusCompleted;
      _timeRemainingIcon = Icons.check_circle;
      return;
    }

    // إذا كانت المهمة فائتة
    if (widget.task.status == TaskStatus.missed) {
      _timeRemainingText = '⚠️ فائتة';
      _timeRemainingColor = AppTheme.error;
      _timeRemainingIcon = Icons.warning_amber;
      return;
    }

    // حساب الوقت المتبقي
    final diff = dueDate.difference(now);

    if (diff.isNegative) {
      // الوقت انتهى والمهمة لم تكتمل
      _timeRemainingText = '⏰ انتهى الوقت المحدد';
      _timeRemainingColor = AppTheme.error;
      _timeRemainingIcon = Icons.timer_off;
    } else if (diff.inDays > 0) {
      // أيام متبقية
      _timeRemainingText = '📅 متبقي ${diff.inDays} يوم';
      _timeRemainingColor = AppTheme.statusPending;
      _timeRemainingIcon = Icons.calendar_today;
    } else if (diff.inHours > 0) {
      // ساعات متبقية
      _timeRemainingText = '🕐 متبقي ${diff.inHours} ساعة';
      _timeRemainingColor = AppTheme.statusPending;
      _timeRemainingIcon = Icons.schedule;
    } else if (diff.inMinutes > 0) {
      // دقائق متبقية
      _timeRemainingText = '⏳ متبقي ${diff.inMinutes} دقيقة';
      _timeRemainingColor =
          diff.inMinutes <= 5 ? AppTheme.error : AppTheme.statusPending;
      _timeRemainingIcon = Icons.timer;
    } else {
      // ثوانٍ متبقية
      _timeRemainingText = '⚡ متبقي ${diff.inSeconds} ثانية';
      _timeRemainingColor = AppTheme.error;
      _timeRemainingIcon = Icons.timer;
    }

    setState(() {});
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _updateTimeRemaining();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeRemaining();
    });
  }

  Widget _buildTimeRemainingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _timeRemainingColor.withValues(alpha: 0.15),
            _timeRemainingColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _timeRemainingColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // أيقونة متحركة
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _timeRemainingColor,
                  _timeRemainingColor.withValues(alpha: 0.7)
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _timeRemainingColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(_timeRemainingIcon, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الوقت المتبقي',
                  style: AppTheme.labelSm.copyWith(
                    color: _timeRemainingColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _timeRemainingText,
                  style: AppTheme.headlineMd.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _timeRemainingColor,
                  ),
                ),
                if (widget.task.dueDate != null &&
                    widget.task.status != TaskStatus.completed &&
                    widget.task.status != TaskStatus.missed)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'الموعد: ${DateFormat('hh:mm a - dd/MM/yyyy').format(widget.task.dueDate!)}',
                      style: AppTheme.labelSm.copyWith(
                          color: _timeRemainingColor.withValues(alpha: 0.7)),
                    ),
                  ),
              ],
            ),
          ),
          // شريط التقدم الدائري
          if (widget.task.dueDate != null &&
              widget.task.status != TaskStatus.completed &&
              widget.task.status != TaskStatus.missed)
            SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _calculateProgress(),
                    strokeWidth: 4,
                    backgroundColor: _timeRemainingColor.withValues(alpha: 0.2),
                    color: _timeRemainingColor,
                  ),
                  Text(
                    '${(_calculateProgress() * 100).round()}%',
                    style: AppTheme.labelSm.copyWith(
                      color: _timeRemainingColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  double _calculateProgress() {
    if (widget.task.dueDate == null) return 0;
    final now = DateTime.now();
    final dueDate = widget.task.dueDate!;

    if (now.isAfter(dueDate)) return 1;

    // افتراض أن المهمة أنشئت قبل يوم واحد على الأقل
    final startDate = widget.task.createdAt;
    final totalDuration = dueDate.difference(startDate).inSeconds;
    final elapsed = now.difference(startDate).inSeconds;

    if (totalDuration <= 0) return 0;
    final progress = elapsed / totalDuration;
    return progress.clamp(0.0, 1.0);
  }
}
