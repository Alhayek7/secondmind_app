import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:secondmind/core/theme/app_theme.dart';
import 'package:secondmind/core/routes/app_routes.dart';
import 'package:secondmind/data/models/task_model.dart';
import 'package:secondmind/features/tasks/controllers/task_controller.dart';
import 'package:secondmind/data/services/event_service.dart';
import 'package:secondmind/data/models/event_model.dart';

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
  
  // ✅ تحديث العداد عند فتح الصفحة (تعتبر جميع الأحداث مقروءة)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    EventService.markAllAsRead();
  });
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
                _buildEventsTab(),      // ✅ تبويب الأحداث (جديد)
                _buildAIInsightsTab(),   // ✅ تبويب توصيات الذكاء الاصطناعي
              ],
            ),
          ),
        ],
      ),
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
          onPressed: () => _showClearEventsDialog(),
          icon: Icon(Icons.delete_sweep, size: 18, color: AppTheme.primary),
          label: Text(
            'مسح الكل',
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
          Tab(text: 'الأحداث', icon: Icon(Icons.history)),
          Tab(text: 'توصيات AI', icon: Icon(Icons.auto_awesome)),
        ],
      ),
    );
  }

  // ==================== تبويب الأحداث (جديد) ====================
  Widget _buildEventsTab() {
    final events = EventService.getAllEvents();

    if (events.isEmpty) {
      return _buildEmptyState(
        icon: Icons.notifications_none,
        title: 'لا توجد أحداث',
        subtitle: 'ستظهر هنا جميع الأحداث والتغييرات التي تحدث في التطبيق',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(event);
      },
    );
  }

  // ==================== بطاقة الحدث (Event Card) ====================
  Widget _buildEventCard(EventModel event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: event.color.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (event.taskId != null) {
              try {
                final task = _taskController.tasks.firstWhere(
                  (t) => t.id == event.taskId,
                );
                Get.toNamed(
                  AppRoutes.taskDetails,
                  arguments: {'task': task},
                );
              } catch (e) {
                // المهمة غير موجودة
              }
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // أيقونة الحدث
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: event.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    event.icon,
                    size: 28,
                    color: event.color,
                  ),
                ),
                const SizedBox(width: 14),
                // المحتوى
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: AppTheme.bodyLg.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.message,
                        style: AppTheme.bodyMd.copyWith(fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('hh:mm a - dd/MM/yyyy').format(event.timestamp),
                        style: AppTheme.labelSm.copyWith(color: AppTheme.outline),
                      ),
                    ],
                  ),
                ),
                // زر الإجراء
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: event.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'عرض',
                        style: AppTheme.labelMd.copyWith(
                          color: event.color,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 10, color: event.color),
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

  // ==================== تبويب توصيات الذكاء الاصطناعي ====================
  Widget _buildAIInsightsTab() {
    final insights = _generateAIInsights();

    if (insights.isEmpty) {
      return _buildEmptyState(
        icon: Icons.auto_awesome,
        title: 'لا توجد توصيات',
        subtitle: 'سيظهر هنا توصيات الذكاء الاصطناعي المخصصة لك',
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
                if (insight['action'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==================== حوار مسح جميع الأحداث ====================
void _showClearEventsDialog() {
  final eventsCount = EventService.eventsCount;
  
  if (eventsCount == 0) {
    Get.snackbar(
      'تنبيه',
      'لا توجد أحداث لمسحها',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.statusPending,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
    return;
  }
  
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
            // أيقونة التحذير
            Container(
              margin: const EdgeInsets.only(top: 24),
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_sweep,
                size: 36,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 20),
            // عنوان
            Text(
              'مسح جميع الأحداث',
              style: AppTheme.headlineMd.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 8),
            // المحتوى
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'هل أنت متأكد من مسح جميع الأحداث؟',
                style: AppTheme.bodyMd.copyWith(color: AppTheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppTheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'سيتم حذف $eventsCount حدث نهائياً. لا يمكنك التراجع عن هذا الإجراء.',
                      style: AppTheme.labelMd.copyWith(
                        color: AppTheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // أزرار
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Row(
                children: [
                  // زر إلغاء
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
                        style: AppTheme.labelLg.copyWith(color: AppTheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // زر مسح الكل
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back(); // إغلاق النافذة أولاً
                        await EventService.clearAllEvents();
                        setState(() {});
                        Get.snackbar(
                          'تم المسح',
                          'تم مسح جميع الأحداث بنجاح',
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
                      child: const Text('مسح الكل'),
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

  // ==================== إنشاء توصيات الذكاء الاصطناعي ====================
List<Map<String, dynamic>> _generateAIInsights() {
  final tasks = _taskController.tasks;
  final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).length;
  final pendingTasks = tasks.where((t) => t.status != TaskStatus.completed).length;
  final urgentTasks = tasks.where((t) => t.priority == TaskPriority.urgent).length;
  final missedTasks = _taskController.missedTasks;

  final insights = <Map<String, dynamic>>[];

  // ==================== التحليل المتقدم ====================
  
  // 1️⃣ تحليل الاتجاهات الأسبوعية
  final thisWeek = _taskController.weeklyTasksCount;
  final lastWeek = _taskController.lastWeekTasksCount;
  final trendPercent = _taskController.weeklyTrendPercentage;

  if (lastWeek > 0) {
    if (trendPercent > 10) {
      insights.add({
        'title': '🎯 أداء أفضل هذا الأسبوع!',
        'message': 'أنت أكثر إنتاجية بنسبة ${trendPercent.round()}% مقارنة بالأسبوع الماضي. استمر بهذا الزخم!',
        'action': 'عرض الإحصائيات',
      });
    } else if (trendPercent < -10) {
      insights.add({
        'title': '⚠️ تراجع في الإنتاجية',
        'message': 'إنتاجيتك أقل بنسبة ${trendPercent.abs().round()}% مقارنة بالأسبوع الماضي. حاول تحديد أولوياتك.',
        'action': 'عرض الإحصائيات',
      });
    } else if (thisWeek > lastWeek) {
      insights.add({
        'title': '📈 تقدم ملحوظ',
        'message': 'أنجزت ${thisWeek - lastWeek} مهمة أكثر من الأسبوع الماضي. واصل بهذا التحسن!',
      });
    }
  }

  // 2️⃣ أفضل وقت للإنتاجية
  final bestTime = _taskController.bestProductivityTime;
  if (bestTime != '0:00 - 1:00') {
    insights.add({
      'title': '⏰ وقت الإنتاجية المثالي',
      'message': 'أفضل وقت لإنجاز المهام هو بين $bestTime',
      'action': 'جدولة مهامك',
    });
  }

  // 3️⃣ توصيات حسب اليوم
  final today = DateTime.now().weekday;
  final dayNames = {
    1: 'الأحد', 2: 'الإثنين', 3: 'الثلاثاء', 
    4: 'الأربعاء', 5: 'الخميس', 6: 'الجمعة', 7: 'السبت'
  };

  if (pendingTasks > 3) {
    insights.add({
      'title': '📅 توصية ليوم ${dayNames[today]}',
      'message': pendingTasks > 5 
          ? 'لديك مهام كثيرة اليوم. ركز على إكمال 3 مهام أولاً.'
          : 'أنت في منتصف الطريق. أكمل ما تبقى لتحصل على يوم منتج!',
    });
  }

  // 4️⃣ تنبيه الإرهاق
  final recentCompleted = _taskController.tasks
      .where((t) => t.completedAt != null && t.completedAt!.isAfter(DateTime.now().subtract(const Duration(hours: 2))))
      .length;

  if (recentCompleted >= 3) {
    insights.add({
      'title': '🧘 خذ استراحة',
      'message': 'لقد أنجزت $recentCompleted مهام في آخر ساعتين. استراحة قصيرة ستزيد إنتاجيتك.',
      'action': 'وضع التركيز',
    });
  }

  // 5️⃣ توصيات حسب الفئة
  final topCategory = _taskController.topCategory;
  final categoryNames = {
    TaskCategory.work: 'العمل',
    TaskCategory.personal: 'الشخصي',
    TaskCategory.study: 'الدراسة',
    TaskCategory.urgent: 'العاجل',
    TaskCategory.other: 'أخرى',
  };

  final completedInTopCategory = _taskController.completedTasksByCategory[topCategory] ?? 0;
  if (completedInTopCategory > 0) {
    insights.add({
      'title': '🏆 فئتك الأكثر إنجازاً',
      'message': 'لقد أنجزت $completedInTopCategory مهام في فئة ${categoryNames[topCategory]}. استمر بهذا التميز!',
    });
  }

  // ==================== التوصيات الأساسية ====================
  
  // توصية المهام الفائتة
  if (missedTasks > 0) {
    insights.add({
      'title': '⚠️ مهام فائتة',
      'message': 'لديك $missedTasks مهمة فائتة! يرجى مراجعتها وإعادة جدولتها.',
      'action': 'عرض المهام',
    });
  }

  // توصية الإنجاز
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

  // توصية المهام العاجلة
  if (urgentTasks > 0) {
    insights.add({
      'title': '⚡ مهام عاجلة',
      'message': 'لديك $urgentTasks مهمة عاجلة. ركز عليها أولاً لتحقيق أقصى إنتاجية!',
      'action': 'عرض المهام',
    });
  }

  // توصية المهام المعلقة
  if (pendingTasks > 5) {
    insights.add({
      'title': '📋 مهام معلقة',
      'message': 'لديك $pendingTasks مهام معلقة. قسمها إلى مهام أصغر لتسهيل إنجازها.',
    });
  }

  // توصية قرب الهدف
  if (pendingTasks <= 3 && pendingTasks > 0) {
    insights.add({
      'title': '🌟 قريب من الهدف',
      'message': 'بقي لك $pendingTasks مهام فقط. أنت على بعد خطوات من إنجاز كل شيء!',
    });
  }

  // توصية البدء (للمستخدمين الجدد)
  if (tasks.isEmpty) {
    insights.add({
      'title': '✨ ابدأ رحلتك',
      'message': 'أضف مهامك الأولى وابدأ رحلة الإنتاجية مع SecondMind!',
      'action': 'إضافة مهمة',
    });
  }

  // نصيحة يومية (إذا لم توجد توصيات أخرى)
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
}