// lib/features/tasks/tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondmind/core/theme/app_theme.dart';
import 'package:secondmind/core/routes/app_routes.dart';
import 'package:secondmind/data/models/task_model.dart';
import 'package:secondmind/features/tasks/widgets/task_card.dart';
import 'package:secondmind/features/tasks/controllers/task_controller.dart';
import 'package:secondmind/features/tasks/widgets/app_drawer.dart';
import 'package:secondmind/features/stats/stats_screen.dart';
import 'package:secondmind/features/focus/focus_screen.dart';
import 'package:secondmind/features/tasks/task_details_screen.dart';
import 'package:secondmind/data/services/notification_service.dart';
import 'package:secondmind/data/services/sound_service.dart';
import 'package:secondmind/data/services/event_service.dart';

import 'package:secondmind/features/notifications/notifications_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TasksContent(),
    const StatsScreen(),
    const FocusScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: _pages[_currentIndex],
      floatingActionButton: _currentIndex == 0 ? _buildFAB() : null,
      bottomNavigationBar: _buildBottomNavigationBar(),
      drawer: const AppDrawer(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final controller = Get.find<TaskController>();

    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.task_alt, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Text('SecondMind',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppTheme.surface.withValues(alpha: 0.95),
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu, color: AppTheme.primary),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        // ✅ زر تبديل العرض (صفوف/شبكة)
        Obx(() => IconButton(
              icon: Icon(
                controller.isGridView.value ? Icons.view_list : Icons.grid_view,
                color: AppTheme.primary,
              ),
              onPressed: () => controller.toggleViewMode(),
              tooltip: controller.isGridView.value ? 'عرض كصفوف' : 'عرض كشبكة',
            )),
        IconButton(
          icon: Icon(Icons.calendar_month, color: AppTheme.primary),
          onPressed: () => Get.toNamed(AppRoutes.calendar),
        ),
        Obx(() {
          final count = EventService.unreadCountNotifier.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon:
                    Icon(Icons.notifications_outlined, color: AppTheme.primary),
                onPressed: () {
                  print('🔔 فتح الإشعارات');
                  Get.to(
                    () => const NotificationsScreen(),
                    fullscreenDialog: true,
                    transition: Transition.rightToLeft,
                  );
                },
              ),
              if (count > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () => Get.toNamed(AppRoutes.addTask),
      backgroundColor: AppTheme.primary,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(0, -4),
                blurRadius: 20),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.dashboard_customize, 'المهام', 0),
                _buildNavItem(Icons.bar_chart_outlined, 'الإحصائيات', 1),
                _buildNavItem(Icons.timer, 'تركيز', 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (_currentIndex != index) setState(() => _currentIndex = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryContainer.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? AppTheme.primary : AppTheme.outline),
            const SizedBox(height: 4),
            Text(label,
                style: AppTheme.labelSm.copyWith(
                    color: isSelected ? AppTheme.primary : AppTheme.outline)),
          ],
        ),
      ),
    );
  }
}

//==============================================================================
// TASKS CONTENT
//==============================================================================

class TasksContent extends StatelessWidget {
  const TasksContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TaskController>();

    return Obx(() {
      final tasks = controller.filteredTasks;
      final totalTasks = controller.tasks.length;
      final completedTasks = controller.tasks
          .where((t) => t.status == TaskStatus.completed)
          .length;
      final pendingTasks = totalTasks - completedTasks;
      final missedTasks = controller.missedTasks;
      final completionRate =
          totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0;

      return RefreshIndicator(
        onRefresh: () async => controller.loadTasks(),
        color: AppTheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
                child: _buildWelcomeSection(controller, totalTasks,
                    completedTasks, pendingTasks, completionRate)),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
                child: _buildStatsRow(controller, totalTasks, completedTasks)),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(child: _buildFilterChips(controller)),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            tasks.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.checklist_rtl_outlined,
                              size: 80, color: AppTheme.outline),
                          const SizedBox(height: 16),
                          Text('لا توجد مهام', style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 8),
                          Text('اضغط على زر + لإضافة مهمة جديدة'),
                        ],
                      ),
                    ),
                  )
                : controller.isGridView.value
                    ? _buildGridView(tasks, controller)
                    : _buildListView(tasks, controller),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      );
    });
  }

// ✅ عرض الشبكة (GridView)
  Widget _buildGridView(List<TaskModel> tasks, TaskController controller) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => TaskCard(
            task: tasks[index],
            onStatusChanged: () async {
              final oldStatus = tasks[index].status;

              DateTime? newDueDate;
              if (oldStatus == TaskStatus.missed) {
                newDueDate = await _showRescheduleDialog(tasks[index]);
                if (newDueDate == null) return;
              }

              await controller.updateTaskStatus(
                tasks[index].id,
                tasks[index].status,
                newDueDate: newDueDate,
              );

              final updatedTask = controller.tasks.firstWhere(
                (t) => t.id == tasks[index].id,
                orElse: () => tasks[index],
              );

              _handleStatusChange(oldStatus, updatedTask, controller);
            },
            onDelete: () => _showDeleteDialog(controller, tasks[index]),
            onTap: () {
              Get.toNamed(
                AppRoutes.taskDetails,
                arguments: {'task': tasks[index]},
              );
            },
          ),
          childCount: tasks.length,
        ),
      ),
    );
  }

// ✅ عرض القائمة (ListView)
  Widget _buildListView(List<TaskModel> tasks, TaskController controller) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: TaskCard(
            task: tasks[index],
            onStatusChanged: () async {
              final oldStatus = tasks[index].status;

              DateTime? newDueDate;
              if (oldStatus == TaskStatus.missed) {
                newDueDate = await _showRescheduleDialog(tasks[index]);
                if (newDueDate == null) return;
              }

              await controller.updateTaskStatus(
                tasks[index].id,
                tasks[index].status,
                newDueDate: newDueDate,
              );

              final updatedTask = controller.tasks.firstWhere(
                (t) => t.id == tasks[index].id,
                orElse: () => tasks[index],
              );

              _handleStatusChange(oldStatus, updatedTask, controller);
            },
            onDelete: () => _showDeleteDialog(controller, tasks[index]),
            onTap: () {
              Get.toNamed(
                AppRoutes.taskDetails,
                arguments: {'task': tasks[index]},
              );
            },
          ),
        ),
        childCount: tasks.length,
      ),
    );
  }

// ✅ دالة عرض حوار تحديد الموعد الجديد
  Future<DateTime?> _showRescheduleDialog(TaskModel task) async {
    return Get.dialog<DateTime>(
      AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('📅 تحديد موعد جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'المهمة "${task.title}" فائتة',
              style: AppTheme.bodyMd,
            ),
            const SizedBox(height: 8),
            Text(
              'هل تريد تحديد موعد جديد؟',
              style: AppTheme.bodyMd,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: Get.context!,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  Get.back(result: date);
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text('اختر تاريخ جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.onPrimary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null),
            child: Text('إلغاء',
                style: AppTheme.labelMd.copyWith(color: AppTheme.outline)),
          ),
          TextButton(
            onPressed: () => Get.back(result: DateTime.now()),
            child: Text('غداً',
                style: AppTheme.labelMd.copyWith(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

// ✅ دالة معالجة تغيير الحالة
  void _handleStatusChange(
      TaskStatus oldStatus, TaskModel task, TaskController controller) {
    if (oldStatus == TaskStatus.inProgress &&
        task.status == TaskStatus.completed) {
      SoundService.playTaskCompleteSound();
      NotificationService.showNotification(
        title: '🎉 مبروك!',
        body: 'لقد أنجزت مهمة: ${task.title}',
        playSound: false,
      );
      Get.snackbar(
        '🎉 إنجاز!',
        'تم إكمال مهمة: ${task.title}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.statusCompleted,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } else if (oldStatus == TaskStatus.new_ &&
        task.status == TaskStatus.inProgress) {
      SoundService.playFocusStartSound();
      Get.snackbar(
        '🚀 بدء العمل!',
        'بدأت العمل على مهمة: ${task.title}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.statusPending,
        colorText: Colors.white,
      );
    } else if (oldStatus == TaskStatus.completed &&
        task.status != TaskStatus.completed) {
      SoundService.playNotificationSound();
      NotificationService.showNotification(
        title: '🔄 تم إعادة فتح المهمة',
        body: 'تم إعادة فتح مهمة: ${task.title}',
        playSound: false,
      );
      Get.snackbar(
        '🔄 إعادة فتح',
        'تم إعادة فتح مهمة: ${task.title}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.statusPending,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } else if (oldStatus == TaskStatus.missed &&
        task.status == TaskStatus.inProgress) {
      SoundService.playFocusStartSound();
      Get.snackbar(
        '🔄 إعادة فتح',
        'تم إعادة فتح المهمة الفائتة: ${task.title}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.primary,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildWelcomeSection(TaskController controller, int totalTasks,
      int completedTasks, int pendingTasks, int completionRate) {
    String motivationalMessage;
    IconData motivationalIcon;
    Color motivationalColor;

    if (completionRate == 100) {
      motivationalMessage = '🎉 مذهل! أنجزت جميع مهامك';
      motivationalIcon = Icons.emoji_events;
      motivationalColor = AppTheme.statusCompleted;
    } else if (completionRate >= 75) {
      motivationalMessage = '🌟 أداء رائع! أنت على بعد خطوات قليلة';
      motivationalIcon = Icons.rocket_launch;
      motivationalColor = AppTheme.primary;
    } else if (completionRate >= 50) {
      motivationalMessage = '📈 في منتصف الطريق! استمر بهذا الزخم';
      motivationalIcon = Icons.trending_up;
      motivationalColor = AppTheme.statusPending;
    } else if (completionRate >= 25) {
      motivationalMessage = '💪 بداية جيدة! أنت تبني عادة الإنتاجية';
      motivationalIcon = Icons.fitness_center;
      motivationalColor = AppTheme.secondary;
    } else {
      motivationalMessage = '✨ ابدأ رحلتك! أضف مهامك الأولى اليوم';
      motivationalIcon = Icons.auto_awesome;
      motivationalColor = AppTheme.tertiary;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.waving_hand,
                    size: 28, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً، سارة',
                      style: AppTheme.headlineMd.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pendingTasks == 0
                          ? 'جميع المهام مكتملة 🎉'
                          : 'لديك $pendingTasks مهام متبقية',
                      style: AppTheme.bodyMd.copyWith(
                        fontSize: 13,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 75,
                height: 75,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 6,
                        backgroundColor: Colors.transparent,
                        color: AppTheme.surfaceContainerHighest,
                      ),
                    ),
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        value: completionRate / 100,
                        strokeWidth: 6,
                        backgroundColor: Colors.transparent,
                        color: AppTheme.primary,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$completionRate',
                          style: AppTheme.headlineMd.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                        Text(
                          '%',
                          style: AppTheme.labelSm.copyWith(
                            fontSize: 10,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('التقدم اليومي',
                      style: AppTheme.labelSm.copyWith(
                          color: AppTheme.outline,
                          fontWeight: FontWeight.w500)),
                  Text('$completedTasks من $totalTasks مهام',
                      style: AppTheme.labelSm.copyWith(
                          color: AppTheme.outline,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: completionRate / 100,
                  backgroundColor: AppTheme.surfaceContainerHighest,
                  color: AppTheme.primary,
                  minHeight: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: motivationalColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: motivationalColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: motivationalColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(motivationalIcon,
                      size: 18, color: motivationalColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    motivationalMessage,
                    style: AppTheme.labelMd.copyWith(
                      color: motivationalColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
      TaskController controller, int totalTasks, int completedTasks) {
    final rate =
        totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0;
    final pendingTasks = totalTasks - completedTasks;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatCard('المهام المتبقية', '${pendingTasks}',
              Icons.pending_actions, AppTheme.statusPending),
          const SizedBox(width: 12),
          _buildStatCard('المهام المكتملة', '$completedTasks',
              Icons.check_circle, AppTheme.statusCompleted),
          const SizedBox(width: 12),
          _buildStatCard(
              'نسبة الإنجاز', '$rate%', Icons.trending_up, AppTheme.primary),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(value,
                style: AppTheme.headlineMd.copyWith(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(title, style: AppTheme.labelSm, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(TaskController controller) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = controller.filters[index];
          final selected = controller.selectedFilter.value == filter;
          return FilterChip(
            label: Text(filter.displayName),
            selected: selected,
            onSelected: (_) => controller.selectedFilter.value = filter,
            backgroundColor: AppTheme.surfaceContainerLowest,
            selectedColor: AppTheme.primary,
            labelStyle: TextStyle(
                color:
                    selected ? AppTheme.onPrimary : AppTheme.onSurfaceVariant),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(TaskController controller, TaskModel task) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 24),
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  size: 36,
                  color: AppTheme.error,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'حذف المهمة',
                style: AppTheme.headlineMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'هل أنت متأكد من حذف مهمة',
                  style: AppTheme.bodyMd
                      .copyWith(color: AppTheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '"${task.title}"',
                  style: AppTheme.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'لا يمكنك التراجع عن هذا الإجراء',
                style: AppTheme.labelSm.copyWith(color: AppTheme.outline),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(color: AppTheme.outline),
                        ),
                        child: Text(
                          'إلغاء',
                          style: AppTheme.labelLg
                              .copyWith(color: AppTheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back(); // إغلاق نافذة التأكيد

                          // ✅ إضافة حدث عند حذف المهمة
                          await EventService.addEvent(
                            title: '🗑️ تم حذف المهمة',
                            message: 'تم حذف مهمة: ${task.title}',
                            type: 'delete',
                            taskId: task.id,
                          );

                          await controller.deleteTask(task.id);

                          Get.snackbar(
                            'تم الحذف',
                            'تم حذف المهمة بنجاح',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppTheme.statusCompleted,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppTheme.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('حذف'),
                      ),
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
}

//==============================================================================
// FILTER CHIPS WIDGET
//==============================================================================

class _FilterChipsWidget extends StatefulWidget {
  final TaskController controller;
  const _FilterChipsWidget({required this.controller});

  @override
  State<_FilterChipsWidget> createState() => _FilterChipsWidgetState();
}

class _FilterChipsWidgetState extends State<_FilterChipsWidget> {
  void _onFilterChanged(_) {
    if (mounted) {
      setState(() {});
    }
  }

  void _onTasksChanged(_) {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    ever(widget.controller.selectedFilter, _onFilterChanged);
    ever(widget.controller.tasks, _onTasksChanged);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.controller.filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = widget.controller.filters[index];
          final selected = widget.controller.selectedFilter.value == filter;
          return FilterChip(
            label: Text(filter.displayName),
            selected: selected,
            onSelected: (_) => widget.controller.selectedFilter.value = filter,
            backgroundColor: AppTheme.surfaceContainerLowest,
            selectedColor: AppTheme.primary,
            labelStyle: TextStyle(
                color:
                    selected ? AppTheme.onPrimary : AppTheme.onSurfaceVariant),
          );
        },
      ),
    );
  }
}

//==============================================================================
// TASKS LIST WIDGET
//==============================================================================

class _TasksListWidget extends StatefulWidget {
  final TaskController controller;
  const _TasksListWidget({required this.controller});

  @override
  State<_TasksListWidget> createState() => _TasksListWidgetState();
}

class _TasksListWidgetState extends State<_TasksListWidget> {
  @override
  void initState() {
    super.initState();
    ever(widget.controller.tasks, (_) {
      if (mounted) setState(() {});
    });
    ever(widget.controller.selectedFilter, (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasks = widget.controller.filteredTasks;

    if (tasks.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.checklist_rtl_outlined, size: 64),
              SizedBox(height: 16),
              Text('لا توجد مهام'),
              SizedBox(height: 8),
              Text('اضغط على زر + لإضافة مهمة جديدة'),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: TaskCard(
            task: tasks[index],
            onStatusChanged: () async {
              final oldStatus = tasks[index].status;

              // ✅ إذا كانت المهمة فائتة، اسأل المستخدم عن الموعد الجديد
              DateTime? newDueDate;
              if (oldStatus == TaskStatus.missed) {
                newDueDate = await _showRescheduleDialog(tasks[index]);
                if (newDueDate == null) return;
              }

              await widget.controller.updateTaskStatus(
                tasks[index].id,
                tasks[index].status,
                newDueDate: newDueDate,
              );

              final updatedTask = widget.controller.tasks.firstWhere(
                (t) => t.id == tasks[index].id,
                orElse: () => tasks[index],
              );

              // ✅ عند إكمال المهمة (inProgress → completed)
              if (oldStatus == TaskStatus.inProgress &&
                  updatedTask.status == TaskStatus.completed) {
                await SoundService.playTaskCompleteSound();

                // ✅ إضافة حدث الإكمال
                await EventService.addEvent(
                  title: '🎉 إنجاز!',
                  message: 'تم إكمال مهمة: ${tasks[index].title}',
                  type: 'complete',
                  taskId: tasks[index].id,
                );

                await NotificationService.showNotification(
                  title: '🎉 مبروك!',
                  body: 'لقد أنجزت مهمة: ${tasks[index].title}',
                  playSound: false,
                );
                Get.snackbar(
                  '🎉 إنجاز!',
                  'تم إكمال مهمة: ${tasks[index].title}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.statusCompleted,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
              }
              // ✅ عند بدء المهمة (new → inProgress)
              else if (oldStatus == TaskStatus.new_ &&
                  updatedTask.status == TaskStatus.inProgress) {
                await SoundService.playFocusStartSound();

                // ✅ إضافة حدث بدء المهمة
                await EventService.addEvent(
                  title: '🚀 بدء العمل',
                  message: 'بدأت العمل على مهمة: ${tasks[index].title}',
                  type: 'start',
                  taskId: tasks[index].id,
                );

                Get.snackbar(
                  '🚀 بدء العمل!',
                  'بدأت العمل على مهمة: ${tasks[index].title}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.statusPending,
                  colorText: Colors.white,
                );
              }
              // ✅ عند إعادة فتح المهمة المكتملة (completed → أي حالة أخرى)
              else if (oldStatus == TaskStatus.completed &&
                  updatedTask.status != TaskStatus.completed) {
                await SoundService.playNotificationSound();

                // ✅ إضافة حدث إعادة الفتح
                await EventService.addEvent(
                  title: '🔄 إعادة فتح',
                  message: 'تم إعادة فتح مهمة: ${tasks[index].title}',
                  type: 'reopen',
                  taskId: tasks[index].id,
                );

                await NotificationService.showNotification(
                  title: '🔄 تم إعادة فتح المهمة',
                  body: 'تم إعادة فتح مهمة: ${tasks[index].title}',
                  playSound: false,
                );
                Get.snackbar(
                  '🔄 إعادة فتح',
                  'تم إعادة فتح مهمة: ${tasks[index].title}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.statusPending,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              }
              // ✅ عند إعادة فتح مهمة فائتة (missed → inProgress)
              else if (oldStatus == TaskStatus.missed &&
                  updatedTask.status == TaskStatus.inProgress) {
                await SoundService.playFocusStartSound();

                // ✅ إضافة حدث إعادة فتح مهمة فائتة
                await EventService.addEvent(
                  title: '🔄 إعادة فتح',
                  message: 'تم إعادة فتح المهمة الفائتة: ${tasks[index].title}',
                  type: 'reopen',
                  taskId: tasks[index].id,
                );

                Get.snackbar(
                  '🔄 إعادة فتح',
                  'تم إعادة فتح المهمة الفائتة: ${tasks[index].title}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.primary,
                  colorText: Colors.white,
                );
              } else {
                _showStatusSnackbar(updatedTask);
              }
            },
            onDelete: () => _showDeleteDialog(tasks[index]),
            onTap: () {
              // ✅ الانتقال إلى شاشة تفاصيل المهمة
              Get.toNamed(
                AppRoutes.taskDetails,
                arguments: {'task': tasks[index]},
              );
            },
          ),
        ),
        childCount: tasks.length,
      ),
    );
  }

  void _showDeleteDialog(TaskModel task) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 24),
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  size: 36,
                  color: AppTheme.error,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'حذف المهمة',
                style: AppTheme.headlineMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'هل أنت متأكد من حذف مهمة',
                  style: AppTheme.bodyMd
                      .copyWith(color: AppTheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '"${task.title}"',
                  style: AppTheme.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'لا يمكنك التراجع عن هذا الإجراء',
                style: AppTheme.labelSm.copyWith(color: AppTheme.outline),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(color: AppTheme.outline),
                        ),
                        child: Text(
                          'إلغاء',
                          style: AppTheme.labelLg
                              .copyWith(color: AppTheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back();
                          await widget.controller.deleteTask(task.id);
                          Get.snackbar(
                            'تم الحذف',
                            'تم حذف المهمة بنجاح',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppTheme.statusCompleted,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppTheme.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('حذف'),
                      ),
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

  void _showStatusSnackbar(TaskModel task) {
    String message;
    Color color;
    switch (task.status) {
      case TaskStatus.new_:
        message = 'تم بدء العمل على "${task.title}"';
        color = AppTheme.statusPending;
        break;
      case TaskStatus.inProgress:
        message = 'تم إكمال "${task.title}" 🎉';
        color = AppTheme.statusCompleted;
        break;
      case TaskStatus.completed:
        message = 'تم إعادة فتح "${task.title}"';
        color = AppTheme.statusPending;
        break;
      case TaskStatus.missed:
        message = 'تم إعادة فتح المهمة الفائتة "${task.title}"';
        color = AppTheme.error;
        break;
    }
    Get.snackbar('تم التحديث', message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: color,
        colorText: Colors.white);
  }

  Future<DateTime?> _showRescheduleDialog(TaskModel task) async {
    DateTime? selectedDate = DateTime.now();

    return Get.dialog<DateTime>(
      AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('📅 تحديد موعد جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'المهمة "${task.title}" فائتة',
              style: AppTheme.bodyMd,
            ),
            const SizedBox(height: 8),
            Text(
              'هل تريد تحديد موعد جديد؟',
              style: AppTheme.bodyMd,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: Get.context!,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  Get.back(result: date);
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text('اختر تاريخ جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.onPrimary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null),
            child: Text('إلغاء',
                style: AppTheme.labelMd.copyWith(color: AppTheme.outline)),
          ),
          TextButton(
            onPressed: () => Get.back(result: DateTime.now()),
            child: Text('غداً',
                style: AppTheme.labelMd.copyWith(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }
}
