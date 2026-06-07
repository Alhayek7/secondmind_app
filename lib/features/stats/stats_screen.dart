// lib/features/stats/stats_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondmind/core/theme/app_theme.dart';
import 'package:secondmind/data/models/task_model.dart';
import 'package:secondmind/features/tasks/controllers/task_controller.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _buildBody(taskController),
    );
  }

  //============================================================================
  // BODY (بدون AppBar)
  //============================================================================
  Widget _buildBody(TaskController taskController) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 80),
      child: Column(
        children: [
          _buildAISummaryCard(taskController),
          const SizedBox(height: 20),
          _buildStatsGrid(taskController),
          const SizedBox(height: 20),
          _buildCategoryCard(taskController),
          const SizedBox(height: 20),
          _buildWeeklyChart(taskController),
          const SizedBox(height: 20),
          _buildSecondaryStats(taskController),
          const SizedBox(height: 20),
        ],
      ),
    );
  }



  //============================================================================
  // AI SUMMARY CARD (بيانات حقيقية)
  //============================================================================
  Widget _buildAISummaryCard(TaskController taskController) {
    final totalTasks = taskController.totalTasks;
    final completedTasks = taskController.completedTasks;
    final pendingTasks = taskController.pendingTasks;
    final rate = taskController.completionRate;
    
    String message;
    if (completedTasks == 0) {
      message = '📝 لم تقم بإنجاز أي مهمة بعد. ابدأ بإضافة مهام جديدة وحقق أهدافك!';
    } else if (pendingTasks == 0) {
      message = '🎉 رائع! لقد أنجزت جميع مهامك. أنت مذهل! استمر في هذا الزخم.';
    } else if (rate >= 70) {
      message = '🌟 أداء ممتاز! لقد أنجزت $rate% من مهامك. أنت على الطريق الصحيح.';
    } else if (rate >= 50) {
      message = '📈 أداء جيد! أنجزت $rate% من مهامك. يمكنك تحسين إنتاجيتك أكثر.';
    } else {
      message = '💪 بداية جيدة! أنجزت $rate% من مهامك. ركز على المهام العاجلة أولاً.';
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withValues(alpha: 0.1),
            AppTheme.primaryContainer.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text('ملخص الأداء الذكي', style: AppTheme.headlineMd.copyWith(fontWeight: FontWeight.w700, color: AppTheme.primary)),
            ],
          ),
          const SizedBox(height: 16),
          Text(message, style: AppTheme.bodyMd.copyWith(height: 1.5)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip('🎯 هدف الأسبوع: ${(totalTasks * 0.8).round()} مهمة'),
              _buildChip('📊 نسبة الإنجاز: $rate%'),
              _buildChip('✅ أنجزت: $completedTasks مهمة'),
              _buildChip('🔥 الأيام المتتالية: ${taskController.streakDays}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: AppTheme.labelSm.copyWith(color: AppTheme.primary)),
    );
  }

  //============================================================================
  // STATS GRID (بيانات حقيقية)
  //============================================================================
  Widget _buildStatsGrid(TaskController taskController) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'المهام المكتملة',
            value: '${taskController.completedTasks}',
            subtitle: 'من أصل ${taskController.totalTasks}',
            icon: Icons.check_circle_outline,
            color: AppTheme.statusCompleted,
            trend: '+${taskController.completionRate}%',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'المهام المتبقية',
            value: '${taskController.pendingTasks}',
            subtitle: 'قيد التنفيذ',
            icon: Icons.pending_actions,
            color: AppTheme.statusPending,
            trend: taskController.pendingTasks > 0 ? 'قيد العمل' : 'مكتملة',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTheme.headlineXl.copyWith(fontSize: 32, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(title, style: AppTheme.labelMd),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(trend.contains('+') ? Icons.trending_up : Icons.trending_flat, size: 12, color: color),
                const SizedBox(width: 4),
                Text(trend, style: AppTheme.labelSm.copyWith(color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //============================================================================
  // CATEGORY CARD (بيانات حقيقية)
  //============================================================================
Widget _buildCategoryCard(TaskController taskController) {
  final Map<String, int> categoryCount = {
    'العمل': 0,
    'شخصي': 0,
    'دراسة': 0,
    'عاجل': 0,
  };
  
  for (var task in taskController.tasks) {
    switch (task.category) {
      case TaskCategory.work:
        categoryCount['العمل'] = (categoryCount['العمل'] ?? 0) + 1;
        break;
      case TaskCategory.personal:
        categoryCount['شخصي'] = (categoryCount['شخصي'] ?? 0) + 1;
        break;
      case TaskCategory.study:
        categoryCount['دراسة'] = (categoryCount['دراسة'] ?? 0) + 1;
        break;
      case TaskCategory.urgent:
        categoryCount['عاجل'] = (categoryCount['عاجل'] ?? 0) + 1;
        break;
      default:
        break;
    }
  }
  
  final topCategory = categoryCount.entries.reduce((a, b) => a.value > b.value ? a : b);
  final totalCompleted = taskController.tasks.where((t) => t.status == TaskStatus.completed).length;
  final percentage = totalCompleted > 0 ? (topCategory.value / totalCompleted * 100).round() : 0;
  
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
      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
    ),
    child: Row(
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.category, color: AppTheme.primary, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الفئة الأكثر إنجازاً', style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
              const SizedBox(height: 4),
              // ✅ هنا التعديل - استخدام topCategory.key بدلاً من displayName
              Text(topCategory.key, style: AppTheme.headlineMd.copyWith(fontWeight: FontWeight.w700, color: AppTheme.primary)),
              const SizedBox(height: 8),
              Text('${topCategory.value} مهام مكتملة', style: AppTheme.labelMd.copyWith(color: AppTheme.primary)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('$percentage%', style: AppTheme.labelLg.copyWith(color: AppTheme.primary)),
        ),
      ],
    ),
  );
}

  //============================================================================
  // WEEKLY CHART (بيانات حقيقية)
  //============================================================================
  Widget _buildWeeklyChart(TaskController taskController) {
    final days = ['أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت'];
    final weeklyTasks = taskController.weeklyTasks;
    final weeklyCompleted = taskController.weeklyCompletedTasks;
    final maxValue = weeklyTasks.reduce((a, b) => a > b ? a : b).toDouble();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(Icons.bar_chart, color: AppTheme.primary), const SizedBox(width: 8), Text('مخطط الإنتاجية الأسبوعي', style: AppTheme.headlineMd.copyWith(fontWeight: FontWeight.w700))]),
          const SizedBox(height: 4),
          Text('مستوى إنجاز المهام يومياً', style: AppTheme.bodyMd.copyWith(color: AppTheme.outline)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final height = maxValue > 0 ? (weeklyTasks[index] / maxValue) * 140 : 0.0;
                final isHighest = weeklyTasks[index] == maxValue;
                return _buildChartBar(
                  day: days[index],
                  height: height,
                  tasks: weeklyTasks[index],
                  completed: weeklyCompleted[index],
                  isHighest: isHighest,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar({
    required String day,
    required double height,
    required int tasks,
    required int completed,
    required bool isHighest,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(width: 40, height: 140, decoration: BoxDecoration(color: AppTheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8))),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 40,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: isHighest ? [AppTheme.primary, AppTheme.primaryContainer] : [AppTheme.secondary, AppTheme.secondaryContainer],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('$completed/$tasks', style: AppTheme.labelSm.copyWith(color: isHighest ? AppTheme.primary : AppTheme.outline)),
        const SizedBox(height: 4),
        Text(day, style: AppTheme.labelSm.copyWith(color: isHighest ? AppTheme.primary : AppTheme.outline, fontSize: 11)),
      ],
    );
  }

  //============================================================================
  // SECONDARY STATS (بيانات حقيقية)
  //============================================================================
  Widget _buildSecondaryStats(TaskController taskController) {
    final totalHours = taskController.totalWorkHours.toStringAsFixed(1);
    final focusRate = taskController.focusRate.round();
    
    return Row(
      children: [
        Expanded(
          child: _buildSecondaryCard(
            icon: Icons.timer_outlined,
            value: totalHours,
            unit: 'ساعة',
            label: 'إجمالي وقت العمل المركز',
            color: AppTheme.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSecondaryCard(
            icon: Icons.psychology_outlined,
            value: '$focusRate',
            unit: '%',
            label: 'معدل التركيز الذهني',
            color: AppTheme.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryCard({
    required IconData icon,
    required String value,
    required String unit,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(value, style: AppTheme.headlineLg.copyWith(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
                    const SizedBox(width: 4),
                    Text(unit, style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(label, style: AppTheme.labelSm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}