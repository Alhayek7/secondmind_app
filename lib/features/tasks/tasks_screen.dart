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
          const Text('SecondMind', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: AppTheme.primary),
          onPressed: () => Get.toNamed(AppRoutes.notifications),
        ),
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -4), blurRadius: 20),
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
          color: isSelected ? AppTheme.primaryContainer.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? AppTheme.primary : AppTheme.outline),
            const SizedBox(height: 4),
            Text(label, style: AppTheme.labelSm.copyWith(color: isSelected ? AppTheme.primary : AppTheme.outline)),
          ],
        ),
      ),
    );
  }
}

//==============================================================================
// TASKS CONTENT
//==============================================================================

class TasksContent extends StatefulWidget {
  const TasksContent({super.key});

  @override
  State<TasksContent> createState() => _TasksContentState();
}

class _TasksContentState extends State<TasksContent> {
  late final TaskController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<TaskController>();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _controller.loadTasks(),
      color: AppTheme.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildWelcomeSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(child: _buildStatsRow()),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(child: _buildFilterChips()),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          _buildTasksList(),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  //----------------------------------------------------------------------------
  // WELCOME SECTION
  //----------------------------------------------------------------------------
  Widget _buildWelcomeSection() {
    final totalTasks = _controller.tasks.length;
    final completedTasks = _controller.tasks.where((t) => t.status == TaskStatus.completed).length;
    final pendingTasks = totalTasks - completedTasks;
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0;
    
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
                    BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Icon(Icons.waving_hand, size: 28, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('مرحباً، سارة', style: AppTheme.headlineMd.copyWith(fontWeight: FontWeight.w700, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(
                      pendingTasks == 0 ? 'جميع المهام مكتملة 🎉' : 'لديك $pendingTasks مهام متبقية',
                      style: AppTheme.bodyMd.copyWith(fontSize: 13, color: AppTheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: completionRate / 100,
                      backgroundColor: AppTheme.surfaceContainerHighest,
                      color: AppTheme.primary,
                      strokeWidth: 5,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$completionRate', style: AppTheme.headlineMd.copyWith(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                        Text('%', style: AppTheme.labelSm.copyWith(fontSize: 10, color: AppTheme.primary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('التقدم اليومي', style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
                  Text('$completedTasks من $totalTasks مهام', style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: completionRate / 100,
                  backgroundColor: AppTheme.surfaceContainerHighest,
                  color: AppTheme.primary,
                  minHeight: 8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: motivationalColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(motivationalIcon, size: 18, color: motivationalColor),
                const SizedBox(width: 8),
                Expanded(child: Text(motivationalMessage, style: AppTheme.labelMd.copyWith(color: motivationalColor, fontSize: 12))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //----------------------------------------------------------------------------
  // STATISTICS CARDS
  //----------------------------------------------------------------------------
  Widget _buildStatsRow() {
    final total = _controller.tasks.length;
    final completed = _controller.tasks.where((t) => t.status == TaskStatus.completed).length;
    final rate = total > 0 ? (completed / total * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatCard('المهام المتبقية', '${total - completed}', Icons.pending_actions, AppTheme.statusPending),
          const SizedBox(width: 12),
          _buildStatCard('المهام المكتملة', '$completed', Icons.check_circle, AppTheme.statusCompleted),
          const SizedBox(width: 12),
          _buildStatCard('نسبة الإنجاز', '$rate%', Icons.trending_up, AppTheme.primary),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(value, style: AppTheme.headlineMd.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(title, style: AppTheme.labelSm, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  //----------------------------------------------------------------------------
  // FILTER CHIPS
  //----------------------------------------------------------------------------
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _FilterChipsWidget(controller: _controller),
    );
  }

  //----------------------------------------------------------------------------
  // TASKS LIST
  //----------------------------------------------------------------------------
  Widget _buildTasksList() {
    return _TasksListWidget(controller: _controller);
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
            labelStyle: TextStyle(color: selected ? AppTheme.onPrimary : AppTheme.onSurfaceVariant),
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
          onStatusChanged: () {
            widget.controller.updateTaskStatus(tasks[index].id, tasks[index].status);
            _showStatusSnackbar(tasks[index]);
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
    }
    Get.snackbar('تم التحديث', message, snackPosition: SnackPosition.BOTTOM, backgroundColor: color, colorText: Colors.white);
  }

  void _showDeleteDialog(TaskModel task) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('حذف المهمة', style: AppTheme.headlineMd.copyWith(color: AppTheme.error)),
        content: Text('هل أنت متأكد من حذف مهمة "${task.title}"؟'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              widget.controller.deleteTask(task.id);
              Get.snackbar('تم الحذف', 'تم حذف المهمة بنجاح');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}