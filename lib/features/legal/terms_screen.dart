// lib/features/legal/terms_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:secondmind/core/theme/app_theme.dart';
import 'package:secondmind/features/legal/privacy_policy_screen.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key, this.isPrivacy = false});

  final bool isPrivacy;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  //============================================================================
  // APP BAR
  //============================================================================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(isPrivacy ? 'سياسة الخصوصية' : 'شروط الخدمة'),
      centerTitle: true,
      backgroundColor: AppTheme.surface.withOpacity(0.95),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.primary),
        onPressed: () => Get.back(),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            if (isPrivacy) {
              Get.to(() => const TermsScreen(isPrivacy: false));
            } else {
              Get.to(() => const PrivacyPolicyScreen());
            }
          },
          icon: Icon(
            isPrivacy ? Icons.description : Icons.privacy_tip,
            size: 18,
            color: AppTheme.primary,
          ),
          label: Text(
            isPrivacy ? 'شروط الخدمة' : 'سياسة الخصوصية',
            style: AppTheme.labelMd.copyWith(color: AppTheme.primary),
          ),
        ),
      ],
    );
  }

  //============================================================================
  // BODY
  //============================================================================
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildLastUpdated(),
          const SizedBox(height: 24),
          _buildIntroduction(),
          const SizedBox(height: 24),
          ..._buildSections(),
          const SizedBox(height: 30),
          _buildFooter(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  //============================================================================
  // HEADER
  //============================================================================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withOpacity(0.1),
            AppTheme.primaryContainer.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Icon(
              isPrivacy ? Icons.privacy_tip : Icons.description,
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
                  isPrivacy ? 'سياسة الخصوصية' : 'شروط الخدمة',
                  style: AppTheme.headlineLg.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPrivacy ? 'نحن نهتم بخصوصية بياناتك' : 'يرجى قراءة الشروط بعناية',
                  style: AppTheme.bodyMd.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //============================================================================
  // LAST UPDATED
  //============================================================================
  Widget _buildLastUpdated() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.update, size: 18, color: AppTheme.primary),
          const SizedBox(width: 8),
          Text(
            'آخر تحديث: 7 يونيو 2026',
            style: AppTheme.labelMd.copyWith(color: AppTheme.primary),
          ),
        ],
      ),
    );
  }

  //============================================================================
  // INTRODUCTION
  //============================================================================
  Widget _buildIntroduction() {
    return _buildCard(
      title: isPrivacy ? '📖 مقدمة' : '📖 مقدمة',
      icon: Icons.info_outline,
      content: isPrivacy
          ? '''
مرحباً بك في تطبيق SecondMind. خصوصيتك مهمة بالنسبة لنا. توضح سياسة الخصوصية هذه كيفية جمع معلوماتك الشخصية واستخدامها وحمايتها عند استخدام تطبيقنا.

نحن نلتزم بحماية بياناتك الشخصية والشفافية في كيفية التعامل معها. يرجى قراءة سياسة الخصوصية هذه بعناية لفهم ممارساتنا فيما يتعلق بمعلوماتك الشخصية.
'''
          : '''
مرحباً بك في تطبيق SecondMind. باستخدامك لتطبيقنا، فإنك توافق على الالتزام بشروط الخدمة هذه. يرجى قراءة هذه الشروط بعناية قبل استخدام التطبيق.

إذا كنت لا توافق على أي جزء من هذه الشروط، يرجى عدم استخدام التطبيق. نحتفظ بالحق في تعديل هذه الشروط في أي وقت.
''',
    );
  }

  //============================================================================
  // SECTIONS
  //============================================================================
  List<Widget> _buildSections() {
    if (isPrivacy) {
      return _buildPrivacySections();
    } else {
      return _buildTermsSections();
    }
  }

  List<Widget> _buildTermsSections() {
    return [
      _buildSection(
        title: '١. قبول الشروط',
        icon: Icons.check_circle_outline,
        content: 'باستخدامك لتطبيق SecondMind، فإنك توافق على الالتزام بهذه الشروط والأحكام. إذا كنت لا توافق على أي جزء من هذه الشروط، يرجى عدم استخدام التطبيق.',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '٢. وصف الخدمة',
        icon: Icons.description_outlined,
        content: 'SecondMind هو تطبيق لإدارة المهام باستخدام الذكاء الاصطناعي، يساعدك على تنظيم مهامك اليومية، استخراج التفاصيل من النصوص والصور، وإرسال تذكيرات ذكية.',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '٣. إنشاء الحساب',
        icon: Icons.person_outline,
        content: 'يجب أن تقدم معلومات دقيقة وكاملة عند إنشاء حساب. أنت مسؤول عن الحفاظ على سرية معلومات حسابك وكلمة المرور الخاصة بك.',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '٤. استخدام التطبيق',
        icon: Icons.phone_android_outlined,
        content: '''
• استخدام التطبيق للأغراض القانونية فقط
• عدم إساءة استخدام الخدمة أو محاولة اختراقها
• احترام حقوق الملكية الفكرية للتطبيق
• عدم تحميل محتوى ضار أو غير قانوني
''',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '٥. الذكاء الاصطناعي',
        icon: Icons.auto_awesome,
        content: 'يستخدم التطبيق تقنيات الذكاء الاصطناعي لتحليل النصوص واستخراج البيانات. قد تختلف دقة النتائج حسب جودة البيانات المدخلة.',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '٦. التعديلات على الخدمة',
        icon: Icons.update,
        content: 'نحتفظ بالحق في تعديل أو إيقاف الخدمة في أي وقت دون إشعار مسبق. سنبذل جهدنا لإعلامك بأي تغييرات جوهرية.',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '٧. إنهاء الخدمة',
        icon: Icons.cancel_outlined,
        content: 'يمكنك إنهاء حسابك في أي وقت. نحتفظ بالحق في تعليق أو إنهاء حسابك إذا انتهكت هذه الشروط.',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '٨. جهة الاتصال',
        icon: Icons.contact_mail,
        content: 'للاستفسارات حول هذه الشروط، يرجى التواصل معنا عبر: support@secondmind.com',
      ),
    ];
  }

  List<Widget> _buildPrivacySections() {
    return [
      _buildSection(
        title: '١. المعلومات التي نجمعها',
        icon: Icons.data_usage,
        content: '''
📋 معلومات الحساب:
   • الاسم الكامل
   • البريد الإلكتروني
   • صورة الملف الشخصي (اختياري)

✅ بيانات المهام:
   • عناوين وأوصاف المهام
   • التواريخ والأوقات المحددة
   • المواقع والروابط المرتبطة

📊 بيانات الاستخدام:
   • تفاعلاتك مع التطبيق
   • الإعدادات والتفضيلات
   • سجل النشاطات والإنجازات

📱 معلومات الجهاز:
   • نوع الجهاز ونظام التشغيل
   • إصدار التطبيق
''',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '٢. كيفية استخدام معلوماتك',
        icon: Icons.settings_applications,
        content: '''
🎯 تقديم وتحسين خدمات التطبيق
👤 إدارة حسابك والمهام الخاصة بك
🔔 إرسال الإشعارات والتذكيرات المهمة
📈 تحليل استخدام التطبيق لتحسين الأداء
🎨 تخصيص تجربتك بناءً على تفضيلاتك
🛡️ حماية أمن التطبيق والمستخدمين
''',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '٣. تخزين البيانات وأمانها',
        icon: Icons.security,
        content: '''
💾 يتم تخزين بياناتك محلياً على جهازك
☁️ لا يتم رفع بياناتك إلى خوادم خارجية (باستثناء خدمات الطرف الثالث التي تختار استخدامها)
🔒 نستخدم إجراءات أمنية تقنية لحماية بياناتك
🗑️ يمكنك تصدير أو حذف بياناتك في أي وقت
''',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '٤. مشاركة المعلومات',
        icon: Icons.share,
        content: '''
نحن لا نبيع أو نشارك معلوماتك الشخصية مع أطراف ثالثة، إلا في الحالات التالية:

✓ بموافقتك الصريحة والمسبقة
✓ للامتثال للقوانين واللوائح المعمول بها
✓ لحماية حقوقنا وممتلكاتنا
✓ في حالة الاندماج أو الاستحواذ (مع إشعارك مسبقاً)
''',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '٥. حقوقك',
        icon: Icons.gavel,
        content: '''
🔍 الحق في الوصول إلى بياناتك الشخصية
✏️ الحق في تصحيح بياناتك غير الدقيقة
🗑️ الحق في حذف حسابك وبياناتك
🚫 الحق في الاعتراض على معالجة بياناتك
📤 الحق في نقل بياناتك إلى خدمة أخرى
⏸️ الحق في سحب موافقتك في أي وقت
''',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '٦. خدمات الطرف الثالث',
        icon: Icons.apps,
        content: '''
قد يتكامل تطبيق SecondMind مع خدمات خارجية مثل:

📅 Google Calendar (لمزامنة المهام)
📅 Apple Calendar (لمزامنة المهام)
💳 خدمات الدفع (في المستقبل)

هذه الخدمات لها سياسات الخصوصية الخاصة بها.
''',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '٧. خصوصية الأطفال',
        icon: Icons.family_restroom,
        content: 'تطبيق SecondMind موجه للمستخدمين الذين تبلغ أعمارهم 13 عاماً أو أكثر. نحن لا نجمع عمداً معلومات شخصية من الأطفال دون سن 13 عاماً.',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '٨. تحديثات سياسة الخصوصية',
        icon: Icons.update,
        content: 'قد نقوم بتحديث سياسة الخصوصية من وقت لآخر. سنقوم بإعلامك بأي تغييرات جوهرية عن طريق إشعار داخل التطبيق أو تحديث تاريخ "آخر تحديث".',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '٩. الاتصال بنا',
        icon: Icons.contact_mail,
        content: '''
لأي استفسارات حول سياسة الخصوصية، يرجى التواصل معنا:

📧 البريد الإلكتروني: support@secondmind.com
🌐 الموقع الإلكتروني: www.secondmind.com/privacy
📍 العنوان: SecondMind, Technology Park, Riyadh, Saudi Arabia
''',
      ),
    ];
  }

  //============================================================================
  // SECTION CARD
  //============================================================================
  Widget _buildSection({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppTheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 22, color: AppTheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.headlineMd.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content,
            style: AppTheme.bodyMd.copyWith(
              height: 1.7,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  //============================================================================
  // SIMPLE CARD
  //============================================================================
  Widget _buildCard({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppTheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 22, color: AppTheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.headlineMd.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: AppTheme.bodyMd.copyWith(
              height: 1.7,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  //============================================================================
  // FOOTER
  //============================================================================
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withOpacity(0.06),
            AppTheme.primaryContainer.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Text(
            '© 2026 SecondMind. جميع الحقوق محفوظة.',
            style: AppTheme.labelSm.copyWith(color: AppTheme.outline),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'SecondMind - عقلك الثاني الذي لا ينسى',
            style: AppTheme.labelMd.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFooterButton('📜 شروط الخدمة', false),
              const SizedBox(width: 12),
              _buildFooterButton('🔒 سياسة الخصوصية', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton(String title, bool isPrivacyPage) {
    final isCurrent = (isPrivacyPage == isPrivacy);
    
    return TextButton(
      onPressed: () {
        if (!isCurrent) {
          if (isPrivacyPage) {
            Get.to(() => const PrivacyPolicyScreen());
          } else {
            Get.to(() => const TermsScreen(isPrivacy: false));
          }
        }
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        backgroundColor: isCurrent
            ? AppTheme.primaryContainer.withOpacity(0.2)
            : AppTheme.primaryContainer.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        title,
        style: AppTheme.labelMd.copyWith(
          color: isCurrent ? AppTheme.primary : AppTheme.outline,
          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}