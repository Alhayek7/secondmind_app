import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondmind/core/theme/app_theme.dart';
import 'package:secondmind/core/routes/app_routes.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

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
      title: const Text('المساعدة والدعم'),
      centerTitle: true,
      backgroundColor: AppTheme.surface.withValues(alpha: 0.95),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.primary),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          title: '📱 تعريف التطبيق',
          icon: Icons.info_outline,
          content: '''
SecondMind هو تطبيق إدارة مهام ذكي يستخدم الذكاء الاصطناعي لمساعدتك في تنظيم مهامك اليومية. يمكنك إضافة المهام يدوياً أو عبر تصوير الملصقات والإعلانات، وسيقوم التطبيق باستخراج التفاصيل تلقائياً.
''',
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: '✨ الميزات الرئيسية',
          icon: Icons.star_outline,
          content: '''
• إضافة مهام من النصوص والصور
• تذكيرات وإشعارات ذكية
• وضع التركيز (بومودورو)
• تقويم لعرض المهام شهرياً
• إحصائيات ورسوم بيانية
• تصدير البيانات ومشاركتها
''',
        ),
        const SizedBox(height: 16),
        _buildAccordionSection(
          title: '📝 إدارة المهام',
          icon: Icons.task_alt,
          steps: [
            '1. اضغط على زر + لإضافة مهمة جديدة',
            '2. يمكنك إدخال النص يدوياً أو رفع صورة',
            '3. اضغط على "تحليل بالذكاء الاصطناعي" لاستخراج التفاصيل',
            '4. راجع المعلومات وأضف أي تفاصيل إضافية',
            '5. اضغط "حفظ المهمة" لإضافتها إلى القائمة',
          ],
        ),
        const SizedBox(height: 16),
        _buildAccordionSection(
          title: '🔔 الإشعارات والتذكيرات',
          icon: Icons.notifications_active,
          steps: [
            '1. في صفحة تفاصيل المهمة، فعّل خيار "تذكير"',
            '2. اختر وقت التذكير قبل موعد المهمة',
            '3. احفظ التغييرات - ستتلقى إشعاراً في الوقت المحدد',
            '4. يمكنك مراجعة جميع الإشعارات في صفحة الإشعارات',
          ],
        ),
        const SizedBox(height: 16),
        _buildAccordionSection(
          title: '🎯 وضع التركيز',
          icon: Icons.timer,
          steps: [
            '1. انتقل إلى صفحة "تركيز" من القائمة السفلية',
            '2. اضغط زر التشغيل لبدء جلسة تركيز',
            '3. يمكنك تغيير المدة (15-60 دقيقة)',
            '4. اختر صوتاً خلفياً يساعدك على التركيز',
            '5. عند انتهاء الوقت، ستتلقى إشعاراً',
          ],
        ),
        const SizedBox(height: 16),
        _buildAccordionSection(
          title: '📅 التقويم',
          icon: Icons.calendar_month,
          steps: [
            '1. اضغط على أيقونة التقويم في شريط التطبيق',
            '2. تصفح بين الأشهر باستخدام الأسهم',
            '3. اضغط على أي يوم لعرض مهامه',
            '4. النقاط الملونة تشير إلى وجود مهام',
            '5. اضغط على زر + لإضافة مهمة جديدة',
          ],
        ),
        const SizedBox(height: 16),
        _buildAccordionSection(
          title: '📊 الإحصائيات',
          icon: Icons.bar_chart,
          steps: [
            '1. انتقل إلى صفحة "الإحصائيات" من القائمة السفلية',
            '2. تعرف على نسبة إنجازك اليومية',
            '3. شاهد الرسم البياني للإنتاجية الأسبوعية',
            '4. تعرف على الفئات الأكثر إنجازاً',
            '5. تتبع الأيام المتتالية من الإنجاز',
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: '❓ الأسئلة الشائعة',
          icon: Icons.help_outline,
          content: '''
س: كيف يمكنني استعادة مهمة محذوفة؟
ج: حالياً لا يمكن استعادة المهام المحذوفة، لذا تأكد قبل الحذف.

س: هل البيانات محفوظة في السحابة؟
ج: حالياً جميع البيانات محفوظة محلياً على جهازك فقط.

س: كيف يمكنني تصدير بياناتي؟
ج: اذهب إلى الإعدادات ← البيانات ← تصدير البيانات.

س: لماذا لا تظهر الإشعارات؟
ج: تأكد من تفعيل أذونات الإشعارات في إعدادات الهاتف.
''',
        ),
        const SizedBox(height: 24),
        _buildContactCard(),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Card(
      color: AppTheme.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppTheme.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTheme.headlineMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: AppTheme.bodyMd.copyWith(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccordionSection({
    required String title,
    required IconData icon,
    required List<String> steps,
  }) {
    return Card(
      color: AppTheme.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 24),
          ),
          title: Text(
            title,
            style: AppTheme.headlineMd.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: steps.map((step) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle,
                            size: 18, color: AppTheme.statusCompleted),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            step,
                            style: AppTheme.bodyMd.copyWith(height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Card(
      color: AppTheme.primary.withValues(alpha: 0.05),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.contact_support,
                      color: AppTheme.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  '📞 تواصل معنا',
                  style: AppTheme.headlineMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('للاستفسارات أو الاقتراحات، يمكنك التواصل معنا عبر:'),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.email, color: AppTheme.primary, size: 25),
              title: Text(
                'aalhayek7@smail.ucas.edu.ps',
                style: AppTheme.bodyMd.copyWith(fontSize: 15),
              ),
              onTap: () {},
              dense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
            ListTile(
              leading: Icon(Icons.web, color: AppTheme.primary),
              title: const Text('www.secondmind.com'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
