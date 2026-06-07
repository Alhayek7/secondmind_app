// lib/features/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondmind/core/theme/app_theme.dart';
import 'package:secondmind/core/routes/app_routes.dart';
import 'package:secondmind/data/models/task_model.dart';
import 'package:secondmind/features/tasks/controllers/task_controller.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _taskController = Get.find<TaskController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRemindersTab(),
                _buildAIInsightsTab(),
              ],
            ),
          ),
        ],
      ),
      // bottomNavigationBar: null,  // لا يوجد شريط سفلي
    );
  }

  // ==================== شريط التطبيق العلوي ====================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('الإشعارات'),
      centerTitle: true,
      backgroundColor: AppTheme.surface.withValues(alpha: 0.95),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.primary),
        onPressed: () => Get.back(),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            _showMarkAllReadDialog();
          },
          icon: Icon(Icons.done_all, size: 18, color: AppTheme.primary),
          label: Text(
            'تحديد الكل كمقروء',
            style: AppTheme.labelMd.copyWith(color: AppTheme.primary),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ==================== أزرار التبويب ====================
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(32),
        ),
        labelColor: AppTheme.onPrimary,
        unselectedLabelColor: AppTheme.onSurfaceVariant,
        labelStyle: AppTheme.labelMd.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTheme.labelMd,
        tabs: const [
          Tab(text: 'التذكيرات'),
          Tab(text: 'توصيات الذكاء الاصطناعي'),
        ],
      ),
    );
  }

  // ==================== تبويب التذكيرات ====================
  Widget _buildRemindersTab() {
    final upcomingTasks = _taskController.tasks
        .where((t) => t.dueDate != null && t.dueDate!.isAfter(DateTime.now()))
        .toList();

    if (upcomingTasks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.notifications_none,
        title: 'لا توجد تذكيرات',
        subtitle: 'سيظهر هنا تذكيرات المهام القادمة',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcomingTasks.length,
      itemBuilder: (context, index) {
        final task = upcomingTasks[index];
        return _buildReminderCard(task);
      },
    );
  }

  // ==================== تبويب توصيات الذكاء الاصطناعي ====================
  Widget _buildAIInsightsTab() {
    final insights = _generateAIInsights();

    if (insights.isEmpty) {
      return _buildEmptyState(
        icon: Icons.auto_awesome,
        title: 'لا توجد توصيات',
        subtitle: 'سيظهر هنا توصيات الذكاء الاصطناعي',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: insights.length,
      itemBuilder: (context, index) {
        return _buildInsightCard(insights[index]);
      },
    );
  }

  // ==================== بطاقة التذكير ====================
  Widget _buildReminderCard(TaskModel task) {
    final isUrgent = task.dueDate != null &&
        task.dueDate!.difference(DateTime.now()).inDays <= 1;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: isUrgent
              ? AppTheme.error.withValues(alpha: 0.3)
              : AppTheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.toNamed(AppRoutes.addTask, arguments: {'task': task});
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // أيقونة
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isUrgent
                        ? AppTheme.error.withValues(alpha: 0.1)
                        : AppTheme.primaryContainer.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isUrgent ? Icons.priority_high : Icons.notifications_active,
                    size: 28,
                    color: isUrgent ? AppTheme.error : AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                // المحتوى
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: AppTheme.bodyLg.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 12, color: AppTheme.outline),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(task.dueDate!),
                            style: AppTheme.labelSm.copyWith(
                              color: isUrgent ? AppTheme.error : AppTheme.outline,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (isUrgent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'عاجل',
                                style: AppTheme.labelSm.copyWith(
                                  color: AppTheme.error,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // زر الإجراء
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'عرض',
                        style: AppTheme.labelMd.copyWith(
                          color: AppTheme.primary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios,
                          size: 10, color: AppTheme.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== بطاقة توصية الذكاء الاصطناعي ====================
  Widget _buildInsightCard(Map<String, dynamic> insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryContainer.withValues(alpha: 0.1),
            AppTheme.tertiaryContainer.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: insight['action'] != null
              ? () {
                  if (insight['action'] == 'عرض المهام') {
                    Get.toNamed(AppRoutes.tasks);
                  } else if (insight['action'] == 'إضافة مهمة') {
                    Get.toNamed(AppRoutes.addTask);
                  }
                }
              : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // أيقونة AI
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                // المحتوى
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight['title'],
                        style: AppTheme.bodyLg.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        insight['message'],
                        style: AppTheme.bodyMd.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                // زر الإجراء
                if (insight['action'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      insight['action'],
                      style: AppTheme.labelMd.copyWith(
                        color: AppTheme.onPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== حالة عدم وجود بيانات ====================
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 50, color: AppTheme.primary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: AppTheme.headlineMd.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTheme.bodyMd,
          ),
        ],
      ),
    );
  }

  // ==================== حوار تحديد الكل كمقروء ====================
  void _showMarkAllReadDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.done_all, color: AppTheme.primary),
            const SizedBox(width: 10),
            Text(
              'تحديد الكل كمقروء',
              style: AppTheme.headlineMd.copyWith(fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في تحديد جميع الإشعارات كمقروءة؟',
          style: AppTheme.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء', style: AppTheme.labelMd.copyWith(color: AppTheme.outline)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'تم التحديث',
                'تم تحديد جميع الإشعارات كمقروءة',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.primaryContainer,
                colorText: AppTheme.onPrimaryContainer,
                icon: Icon(Icons.check_circle, color: AppTheme.primary),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  // ==================== إنشاء توصيات الذكاء الاصطناعي ====================
  List<Map<String, dynamic>> _generateAIInsights() {
    final tasks = _taskController.tasks;
    final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).length;
    final pendingTasks = tasks.where((t) => t.status != TaskStatus.completed).length;
    final urgentTasks = tasks.where((t) => t.priority == TaskPriority.urgent).length;

    final insights = <Map<String, dynamic>>[];

    // توصية 1: إنجاز
    if (completedTasks > 5) {
      insights.add({
        'title': '🎉 إنجاز رائع',
        'message': 'لقد أنجزت $completedTasks مهمة هذا الأسبوع. أنت في طريقك لتحقيق أهدافك!',
      });
    } else if (completedTasks > 0) {
      insights.add({
        'title': '📈 تقدم ملحوظ',
        'message': 'أنجزت $completedTasks مهمة حتى الآن. واصل بهذا الزخم!',
      });
    }

    // توصية 2: مهام عاجلة
    if (urgentTasks > 0) {
      insights.add({
        'title': '⚡ مهام عاجلة',
        'message': 'لديك $urgentTasks مهمة عاجلة. ركز عليها أولاً لتحقيق أقصى إنتاجية!',
        'action': 'عرض المهام',
      });
    }

    // توصية 3: مهام معلقة كثيرة
    if (pendingTasks > 5) {
      insights.add({
        'title': '📋 مهام معلقة',
        'message': 'لديك $pendingTasks مهام معلقة. قسمها إلى مهام أصغر لتسهيل إنجازها.',
      });
    }

    // توصية 4: قرب الهدف
    if (pendingTasks <= 3 && pendingTasks > 0) {
      insights.add({
        'title': '🌟 قريب من الهدف',
        'message': 'بقي لك $pendingTasks مهام فقط. أنت على بعد خطوات من إنجاز كل شيء!',
      });
    }

    // توصية 5: بداية
    if (tasks.isEmpty) {
      insights.add({
        'title': '✨ ابدأ رحلتك',
        'message': 'أضف مهامك الأولى وابدأ رحلة الإنتاجية مع SecondMind!',
        'action': 'إضافة مهمة',
      });
    }

    // توصية 6: نصيحة يومية
    if (insights.isEmpty) {
      final tips = [
        {'title': '💡 نصيحة اليوم', 'message': 'خصص أول 30 دقيقة من يومك للمهام الأكثر أهمية.'},
        {'title': '🎯 تركيز', 'message': 'استخدم تقنية بومودورو لزيادة إنتاجيتك: 25 دقيقة عمل، 5 دقائق راحة.'},
        {'title': '📅 تنظيم', 'message': 'خطط لمهامك في الليلة السابقة لتبدأ يومك بنشاط.'},
        {'title': '🚀 إنجاز', 'message': 'أنجز أصعب مهمة أولاً في الصباح عندما تكون طاقتك في أعلى مستوياتها.'},
      ];
      insights.add(tips[DateTime.now().day % tips.length]);
    }

    return insights;
  }

  // ==================== تنسيق التاريخ ====================
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'اليوم';
    } else if (difference == 1) {
      return 'غداً';
    } else if (difference < 7) {
      return 'بعد $difference أيام';
    } else {
      final months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
      return '${date.day} ${months[date.month - 1]}';
    }
  }
}