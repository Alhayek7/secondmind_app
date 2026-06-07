// lib/features/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:secondmind/core/theme/app_theme.dart';
import 'package:secondmind/core/routes/app_routes.dart';
import 'package:secondmind/data/services/auth_service.dart';
import 'package:secondmind/features/rate/rate_app_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // إعدادات الإشعارات
  bool _smartReminders = true;
  bool _dailySummary = false;
  bool _aiMotivation = true;
  bool _smartContextual = false;
  
  // إعدادات الذكاء الاصطناعي
  String _selectedAIModel = 'GPT-4o-mini (OpenAI)';
  final List<DropdownMenuItem<String>> _aiModelItems = const [
    DropdownMenuItem(value: 'Gemini 1.5 Pro (Google)', child: Text('Gemini 1.5 Pro (Google)')),
    DropdownMenuItem(value: 'GPT-4o-mini (OpenAI)', child: Text('GPT-4o-mini (OpenAI)')),
    DropdownMenuItem(value: 'Claude 3.5 Sonnet (Anthropic)', child: Text('Claude 3.5 Sonnet (Anthropic)')),
  ];
  
  // إعدادات المظهر
  bool _darkMode = false;
  String _selectedLanguage = 'ar';
  
  // إعدادات الخصوصية
  bool _analyticsEnabled = true;
  bool _backupEnabled = false;
  
  // إعدادات أخرى
  String _appVersion = '2.4.0-stable';
  String _lastSync = 'منذ 3 ساعات';

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
      title: const Text('الإعدادات'),
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
        // قسم الذكاء الاصطناعي
        _buildSection('نموذج الذكاء الاصطناعي', Icons.psychology_outlined, _buildAIModelCard()),
        const SizedBox(height: 20),
        
        // قسم الإشعارات الذكية
        _buildSection('الإشعارات الذكية', Icons.notifications_outlined, _buildNotificationsCard()),
        const SizedBox(height: 20),
        
        // قسم المظهر واللغة
        _buildSection('المظهر واللغة', Icons.palette_outlined, _buildAppearanceCard()),
        const SizedBox(height: 20),
        
        // قسم التكامل والربط
        _buildSection('التكامل والربط', Icons.hub_outlined, _buildIntegrationsCard()),
        const SizedBox(height: 20),
        
        // قسم الخصوصية والأمان
        _buildSection('الخصوصية والأمان', Icons.privacy_tip_outlined, _buildPrivacyCard()),
        const SizedBox(height: 20),
        
        // قسم عن التطبيق
        _buildSection('عن التطبيق', Icons.info_outline, _buildAppInfoCard()),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(title, style: AppTheme.labelMd.copyWith(color: AppTheme.outline, letterSpacing: 0.5)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  //============================================================================
  // AI MODEL CARD
  //============================================================================
  Widget _buildAIModelCard() {
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
            Text('اختر المحرك المفضل', style: AppTheme.bodyMd),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedAIModel,
                  isExpanded: true,
                  icon: Icon(Icons.expand_more, color: AppTheme.outline),
                  items: _aiModelItems,
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedAIModel = value);
                    _showSnackbar('تم تغيير نموذج الذكاء الاصطناعي');
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: AppTheme.outline),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'يتم توفير التوازن بين السرعة والدقة افتراضياً',
                    style: AppTheme.labelSm.copyWith(color: AppTheme.outline),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //============================================================================
  // NOTIFICATIONS CARD
  //============================================================================
  Widget _buildNotificationsCard() {
    return Card(
      color: AppTheme.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            title: 'تذكيرات ذكية',
            subtitle: 'تذكيرات تعتمد على سياق يومك',
            value: _smartReminders,
            onChanged: (v) => setState(() => _smartReminders = v),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildSwitchTile(
            title: 'الملخص اليومي',
            subtitle: 'موجز مسائي لإنجازات اليوم',
            value: _dailySummary,
            onChanged: (v) => setState(() => _dailySummary = v),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildSwitchTile(
            title: 'رسائل تحفيزية بالذكاء الاصطناعي',
            subtitle: 'تلقي رسائل مشجعة مخصصة لأهدافك',
            value: _aiMotivation,
            onChanged: (v) => setState(() => _aiMotivation = v),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildSwitchTile(
            title: 'تذكيرات سياقية ذكية',
            subtitle: 'تذكيرات تتكيف مع جدولك وموقعك',
            value: _smartContextual,
            onChanged: (v) => setState(() => _smartContextual = v),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: AppTheme.bodyLg),
      subtitle: Text(subtitle, style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryContainer.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          value ? Icons.notifications_active : Icons.notifications_off,
          size: 20,
          color: value ? AppTheme.primary : AppTheme.outline,
        ),
      ),
    );
  }

  //============================================================================
  // APPEARANCE CARD
  //============================================================================
  Widget _buildAppearanceCard() {
    return Card(
      color: AppTheme.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _buildThemeTile(),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildLanguageTile(),
        ],
      ),
    );
  }

  Widget _buildThemeTile() {
    return ListTile(
      leading: Icon(Icons.dark_mode, color: AppTheme.primary),
      title: Text('الوضع المظلم', style: AppTheme.bodyLg),
      subtitle: Text('واجهة داكنة مريحة للعين', style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
      trailing: Switch(
        value: _darkMode,
        onChanged: (value) {
          setState(() => _darkMode = value);
          Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
          _showSnackbar(value ? 'تم تفعيل الوضع المظلم' : 'تم تفعيل الوضع الفاتح');
        },
        activeColor: AppTheme.primary,
      ),
    );
  }

  Widget _buildLanguageTile() {
    return ListTile(
      leading: Icon(Icons.language, color: AppTheme.primary),
      title: Text('اللغة', style: AppTheme.bodyLg),
      subtitle: Text('اختر لغة التطبيق', style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
      trailing: DropdownButton<String>(
        value: _selectedLanguage,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'ar', child: Text('العربية')),
          DropdownMenuItem(value: 'en', child: Text('English')),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedLanguage = value);
            _showSnackbar('سيتم تغيير اللغة بعد إعادة تشغيل التطبيق');
          }
        },
      ),
    );
  }

  //============================================================================
  // INTEGRATIONS CARD
  //============================================================================
  Widget _buildIntegrationsCard() {
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
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showSnackbar('سيتم إضافة ربط تقويم Google قريباً'),
                icon: const Icon(Icons.calendar_month),
                label: const Text('الربط مع تقويم Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryContainer,
                  foregroundColor: AppTheme.onPrimaryContainer,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sync, size: 14, color: AppTheme.outline),
                const SizedBox(width: 6),
                Text(_lastSync, style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //============================================================================
  // PRIVACY CARD
  //============================================================================
  Widget _buildPrivacyCard() {
    return Card(
      color: AppTheme.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            title: 'إرسال بيانات الاستخدام',
            subtitle: 'ساعدنا في تحسين التطبيق',
            value: _analyticsEnabled,
            onChanged: (v) => setState(() => _analyticsEnabled = v),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildSwitchTile(
            title: 'النسخ الاحتياطي السحابي',
            subtitle: 'مزامنة بياناتك عبر الأجهزة',
            value: _backupEnabled,
            onChanged: (v) => setState(() => _backupEnabled = v),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildExportDataTile(),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildClearDataTile(),
        ],
      ),
    );
  }

  Widget _buildExportDataTile() {
    return ListTile(
      leading: Icon(Icons.download_outlined, color: AppTheme.primary),
      title: Text('تصدير البيانات', style: AppTheme.bodyLg),
      subtitle: Text('تصدير جميع مهامك وبياناتك', style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
      trailing: Icon(Icons.chevron_left, color: AppTheme.outline),
      onTap: () => _showSnackbar('سيتم إضافة تصدير البيانات قريباً'),
    );
  }

  Widget _buildClearDataTile() {
    return ListTile(
      leading: Icon(Icons.delete_sweep_outlined, color: AppTheme.error),
      title: Text('مسح جميع البيانات', style: AppTheme.bodyLg.copyWith(color: AppTheme.error)),
      subtitle: Text('حذف جميع المهام والإعدادات', style: AppTheme.labelSm.copyWith(color: AppTheme.error.withValues(alpha: 0.7))),
      trailing: Icon(Icons.chevron_left, color: AppTheme.error),
      onTap: () => _showClearDataDialog(),
    );
  }

  //============================================================================
  // APP INFO CARD
  //============================================================================
  Widget _buildAppInfoCard() {
    return Card(
      color: AppTheme.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _buildInfoTile(Icons.star_outline, 'قيم التطبيق', 'قيّمنا في المتجر', () => Get.to(() => const RateAppScreen())),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildInfoTile(Icons.share_outlined, 'شارك التطبيق', 'أرسل التطبيق لأصدقائك', _shareApp),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildInfoTile(Icons.description_outlined, 'شروط الخدمة', 'اقرأ شروط الاستخدام', () => Get.toNamed(AppRoutes.terms)),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildInfoTile(Icons.privacy_tip_outlined, 'سياسة الخصوصية', 'كيف نتعامل مع بياناتك', () => Get.toNamed(AppRoutes.privacy)),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildVersionTile(),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildLogoutTile(),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary),
      title: Text(title, style: AppTheme.bodyLg),
      subtitle: Text(subtitle, style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
      trailing: Icon(Icons.chevron_left, color: AppTheme.outline),
      onTap: onTap,
    );
  }

  Widget _buildVersionTile() {
    return ListTile(
      leading: Icon(Icons.info_outline, color: AppTheme.outline),
      title: Text('إصدار التطبيق', style: AppTheme.bodyLg),
      subtitle: Text(_appVersion, style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.primaryContainer.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('أحدث إصدار', style: AppTheme.labelSm.copyWith(color: AppTheme.primary)),
      ),
    );
  }

  Widget _buildLogoutTile() {
    return ListTile(
      leading: Icon(Icons.logout, color: AppTheme.error),
      title: Text('تسجيل الخروج', style: AppTheme.bodyLg.copyWith(color: AppTheme.error)),
      subtitle: Text('تسجيل الخروج من حسابك', style: AppTheme.labelSm.copyWith(color: AppTheme.error.withValues(alpha: 0.7))),
      trailing: Icon(Icons.chevron_left, color: AppTheme.error),
      onTap: _showLogoutDialog,
    );
  }

  //============================================================================
  // DIALOGS & ACTIONS
  //============================================================================
  void _showSnackbar(String message) {
    Get.snackbar(
      'تنبيه',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: AppTheme.primaryContainer,
      colorText: AppTheme.onPrimaryContainer,
    );
  }

  void _shareApp() async {
    const shareText = '''
📱 *SecondMind* - عقلك الثاني الذي لا ينسى

تطبيق إدارة مهام بالذكاء الاصطناعي يساعدك على:
✅ تنظيم مهامك اليومية
🤖 استخراج التفاصيل من النصوص والصور
📊 تحليل إنتاجيتك
🎯 تحسين تركيزك

📥 حمل التطبيق الآن:
https://secondmind.app/download
    ''';
    await Share.share(shareText);
  }

  void _showClearDataDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('مسح جميع البيانات', style: AppTheme.headlineMd.copyWith(color: AppTheme.error)),
        content: const Text('هل أنت متأكد؟ سيتم حذف جميع مهامك وإعداداتك نهائياً.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showSnackbar('تم مسح جميع البيانات');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('تسجيل الخروج', style: AppTheme.headlineMd.copyWith(color: AppTheme.error)),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              AuthService.to.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

}