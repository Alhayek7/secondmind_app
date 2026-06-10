// lib/features/calendar/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:secondmind/core/theme/app_theme.dart';
import 'package:secondmind/data/models/task_model.dart';
import 'package:secondmind/features/tasks/controllers/task_controller.dart';
import 'package:secondmind/core/routes/app_routes.dart';
import 'package:secondmind/data/services/sound_service.dart';
import 'package:secondmind/core/routes/app_routes.dart';


class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late TaskController _taskController;
  DateTime _currentMonth = DateTime.now();
  late DateTime _selectedDate;
  late AnimationController _animationController;
  
  Map<DateTime, List<TaskModel>> _tasksByDate = {};

  @override
  void initState() {
    super.initState();
    _taskController = Get.find<TaskController>();
    _selectedDate = DateTime.now();
    _updateTasksByDate();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateTasksByDate() {
    _tasksByDate.clear();
    
    for (var task in _taskController.tasks) {
      if (task.dueDate != null) {
        final date = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );
        if (!_tasksByDate.containsKey(date)) {
          _tasksByDate[date] = [];
        }
        _tasksByDate[date]!.add(task);
      }
    }
    // ✅ لا نستخدم setState - Obx سيتعامل مع التحديث
  }

  void _previousMonth() {
    _animationController.forward(from: 0.0);
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    Future.delayed(const Duration(milliseconds: 300), () => _animationController.reset());
  }

  void _nextMonth() {
    _animationController.forward(from: 0.0);
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    Future.delayed(const Duration(milliseconds: 300), () => _animationController.reset());
  }

  void _goToToday() {
    SoundService.playNotificationSound();
    _animationController.forward(from: 0.0);
    setState(() {
      _currentMonth = DateTime.now();
      _selectedDate = DateTime.now();
    });
    Future.delayed(const Duration(milliseconds: 300), () => _animationController.reset());
    Get.snackbar('اليوم', 'تم الانتقال إلى التاريخ الحالي',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  void _onDateSelected(DateTime date) {
    if (!_isSameDay(date, _selectedDate)) {
      SoundService.playNotificationSound();
      setState(() {
        _selectedDate = date;
      });
    }
  }

  String _formatMonthYear(DateTime date) {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatSelectedDate(DateTime date) {
    final weekDays = [
      'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'
    ];
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${weekDays[date.weekday % 7]}، ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: Obx(() {
        _updateTasksByDate(); // ✅ يتم استدعاؤها داخل Obx
        return Column(
          children: [
            _buildCalendarHeader(),
            const SizedBox(height: 8),
            _buildWeekDaysHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildCalendarGrid(),
                    const SizedBox(height: 16),
                    _buildSelectedDateHeader(),
                    _buildTasksList(),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

PreferredSizeWidget _buildAppBar() {
  return AppBar(
    title: const Text('التقويم'),
    centerTitle: true,
    backgroundColor: AppTheme.surface.withValues(alpha: 0.95),
    elevation: 0,
    leading: IconButton(
      icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.primary),
      onPressed: () => Get.back(),
    ),
    actions: [
      IconButton(
        icon: Icon(Icons.add, color: AppTheme.primary),
        onPressed: () => Get.toNamed(AppRoutes.addTask),
        tooltip: 'إضافة مهمة جديدة',
      ),
      IconButton(
        icon: Icon(Icons.today, color: AppTheme.primary),
        onPressed: _goToToday,
        tooltip: 'اليوم',
      ),
    ],
  );
}

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.chevron_right, size: 32, color: AppTheme.primary),
                onPressed: _previousMonth,
              ),
              const SizedBox(width: 8),
              Text(
                _formatMonthYear(_currentMonth),
                style: AppTheme.headlineMd.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.chevron_left, size: 32, color: AppTheme.primary),
                onPressed: _nextMonth,
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_tasksByDate.length} أيام بها مهام',
              style: AppTheme.labelSm.copyWith(color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaysHeader() {
    final weekDays = ['أحد', 'إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekDays.map((day) {
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: AppTheme.labelMd.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstDayWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    
    final totalCells = ((firstDayWeekday + daysInMonth) / 7).ceil() * 7;
    final List<DateTime?> days = List.generate(totalCells, (index) {
      final dayNumber = index - firstDayWeekday + 1;
      if (dayNumber >= 1 && dayNumber <= daysInMonth) {
        return DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
      }
      return null;
    });
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.1,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final date = days[index];
          if (date == null) {
            return Container();
          }
          
          final isToday = _isSameDay(date, DateTime.now());
          final isSelected = _isSameDay(date, _selectedDate);
          final hasTasks = _tasksByDate.containsKey(date);
          final tasks = _tasksByDate[date] ?? [];
          final urgentCount = tasks.where((t) => t.priority == TaskPriority.urgent).length;
          final missedCount = tasks.where((t) => t.status == TaskStatus.missed).length;
          final completedCount = tasks.where((t) => t.status == TaskStatus.completed).length;
          
          return GestureDetector(
            onTap: () => _onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? AppTheme.primaryGradient
                    : null,
                color: isSelected
                    ? null
                    : (isToday
                        ? AppTheme.primary.withValues(alpha: 0.1)
                        : Colors.transparent),
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? null
                    : (isToday
                        ? Border.all(color: AppTheme.primary, width: 1.5)
                        : null),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: AppTheme.bodyLg.copyWith(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isToday ? AppTheme.primary : AppTheme.onSurface),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hasTasks) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (completedCount > 0 && completedCount == tasks.length)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.statusCompleted,
                              shape: BoxShape.circle,
                            ),
                          )
                        else if (urgentCount > 0)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.error,
                              shape: BoxShape.circle,
                            ),
                          )
                        else if (missedCount > 0)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.statusUrgent,
                              shape: BoxShape.circle,
                            ),
                          )
                        else
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedDateHeader() {
    final tasks = _tasksByDate[_selectedDate] ?? [];
    final completedCount = tasks.where((t) => t.status == TaskStatus.completed).length;
    final urgentCount = tasks.where((t) => t.priority == TaskPriority.urgent).length;
    final missedCount = tasks.where((t) => t.status == TaskStatus.missed).length;
    
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withValues(alpha: 0.08),
            AppTheme.primaryContainer.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
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
            child: Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatSelectedDate(_selectedDate),
                  style: AppTheme.headlineMd.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildInfoChip('${tasks.length}', 'مهمة', AppTheme.primary),
                    if (completedCount > 0)
                      _buildInfoChip('$completedCount', 'مكتملة', AppTheme.statusCompleted),
                    if (urgentCount > 0)
                      _buildInfoChip('$urgentCount', 'عاجلة', AppTheme.error),
                    if (missedCount > 0)
                      _buildInfoChip('$missedCount', 'فائتة', AppTheme.statusUrgent),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$value $label',
        style: AppTheme.labelSm.copyWith(color: color),
      ),
    );
  }

  Widget _buildTasksList() {
    final tasks = _tasksByDate[_selectedDate] ?? [];
    
    if (tasks.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: AppTheme.outline),
            const SizedBox(height: 16),
            Text(
              'لا توجد مهام في هذا اليوم',
              style: AppTheme.bodyLg.copyWith(color: AppTheme.outline),
            ),
            const SizedBox(height: 8),
            Text(
              'اضغط على زر + لإضافة مهمة جديدة',
              style: AppTheme.bodyMd.copyWith(color: AppTheme.outline),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.addTask),
              icon: const Icon(Icons.add),
              label: const Text('إضافة مهمة جديدة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.onPrimary,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (task.status) {
      case TaskStatus.completed:
        statusColor = AppTheme.statusCompleted;
        statusText = 'مكتمل';
        statusIcon = Icons.check_circle;
        break;
      case TaskStatus.inProgress:
        statusColor = AppTheme.statusPending;
        statusText = 'قيد التنفيذ';
        statusIcon = Icons.play_circle;
        break;
      case TaskStatus.missed:
        statusColor = AppTheme.error;
        statusText = 'فائتة';
        statusIcon = Icons.warning_amber;
        break;
      default:
        statusColor = AppTheme.primary;
        statusText = 'جديد';
        statusIcon = Icons.pending;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: task.priority == TaskPriority.urgent
              ? AppTheme.error.withValues(alpha: 0.3)
              : AppTheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      color: AppTheme.surfaceContainerLowest,
      child: InkWell(
        onTap: () {
          SoundService.playNotificationSound();
          Get.toNamed(AppRoutes.taskDetails, arguments: {'task': task});
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(statusIcon, size: 20, color: statusColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: AppTheme.bodyLg.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (task.description != null)
                          Text(
                            task.description!,
                            style: AppTheme.bodyMd.copyWith(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: AppTheme.labelSm.copyWith(color: statusColor),
                    ),
                  ),
                ],
              ),
              if (task.dueDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: AppTheme.outline),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('hh:mm a').format(task.dueDate!),
                        style: AppTheme.labelSm.copyWith(color: AppTheme.outline),
                      ),
                    ],
                  ),
                ),
              if (task.location != null || task.organizer != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 12,
                    children: [
                      if (task.location != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on, size: 14, color: AppTheme.outline),
                            const SizedBox(width: 4),
                            Text(
                              task.location!,
                              style: AppTheme.labelSm.copyWith(color: AppTheme.outline),
                            ),
                          ],
                        ),
                      if (task.organizer != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.business, size: 14, color: AppTheme.outline),
                            const SizedBox(width: 4),
                            Text(
                              task.organizer!,
                              style: AppTheme.labelSm.copyWith(color: AppTheme.outline),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}