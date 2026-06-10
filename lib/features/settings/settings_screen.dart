// lib/features/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:secondmind/core/theme/app_theme.dart';
import 'package:secondmind/core/routes/app_routes.dart';
import 'package:secondmind/data/services/auth_service.dart';
import 'package:secondmind/features/rate/rate_app_screen.dart';
import 'package:secondmind/data/services/sound_service.dart';
import 'package:secondmind/features/tasks/controllers/task_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Box? _settingsBox;
  bool _isLoading = true;
  
  // إعدادات الإشعارات
  bool _smartReminders = true;
  bool _dailySummary = false;
  bool _aiMotivation = true;
  bool _smartContextual = false;
  
  // إعدادات الصوت
  double _soundVolume = 0.7;
  bool _soundEnabled = true;
  
  // إعدادات المظهر
  bool _darkMode = false;
  String _selectedLanguage = 'ar';
  
  // إعدادات الخصوصية
  bool _analyticsEnabled = true;
  
  // إعدادات أخرى
  String _appVersion = '1.0.0';
  String _lastSync = '';

  @override
  void initState() {
    super.initState();
    _initializeSettings();
    _getAppVersion();
  }

  Future<void> _initializeSettings() async {
    _settingsBox = await Hive.openBox('settings');
    await _loadSettings();
    await _updateLastSync();
    setState(() => _isLoading = false);
  }

  Future<void> _loadSettings() async {
    if (_settingsBox == null) return;
    setState(() {
      _smartReminders = _settingsBox!.get('smartReminders', defaultValue: true);
      _dailySummary = _settingsBox!.get('dailySummary', defaultValue: false);
      _aiMotivation = _settingsBox!.get('aiMotivation', defaultValue: true);
      _smartContextual = _settingsBox!.get('smartContextual', defaultValue: false);
      _soundVolume = _settingsBox!.get('soundVolume', defaultValue: 0.7);
      _soundEnabled = _settingsBox!.get('soundEnabled', defaultValue: true);
      _darkMode = _settingsBox!.get('darkMode', defaultValue: false);
      _selectedLanguage = _settingsBox!.get('language', defaultValue: 'ar');
      _analyticsEnabled = _settingsBox!.get('analyticsEnabled', defaultValue: true);
    });
    
    if (_darkMode) {
      Get.changeThemeMode(ThemeMode.dark);
    } else {
      Get.changeThemeMode(ThemeMode.light);
    }
    
    await SoundService.setVolume(_soundVolume);
    if (!_soundEnabled) {
      await SoundService.setVolume(0);
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    if (_settingsBox != null) {
      await _settingsBox!.put(key, value);
    }
  }

  void _getAppVersion() {
    _appVersion = '1.0.0';
  }

  Future<void> _updateLastSync() async {
    if (_settingsBox == null) return;
    final lastSync = _settingsBox!.get('lastSync');
    if (lastSync != null) {
      final date = DateTime.parse(lastSync);
      final difference = DateTime.now().difference(date);
      if (difference.inHours < 1) {
        _lastSync = 'منذ ${difference.inMinutes} دقيقة';
      } else if (difference.inDays < 1) {
        _lastSync = 'منذ ${difference.inHours} ساعة';
      } else {
        _lastSync = 'منذ ${difference.inDays} يوم';
      }
    } else {
      _lastSync = 'لم تتم المزامنة بعد';
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? 'خطأ' : 'تنبيه',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: isError ? AppTheme.errorContainer : AppTheme.primaryContainer,
      colorText: isError ? AppTheme.onErrorContainer : AppTheme.onPrimaryContainer,
    );
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'نجاح',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: AppTheme.statusCompleted,
      colorText: Colors.white,
    );
  }

  void _toggleDarkMode(bool value) async {
    setState(() => _darkMode = value);
    await _saveSetting('darkMode', value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    _showSnackbar(value ? 'تم تفعيل الوضع المظلم' : 'تم تفعيل الوضع الفاتح');
  }

  void _toggleSound(bool value) async {
    setState(() => _soundEnabled = value);
    await _saveSetting('soundEnabled', value);
    if (value) {
      await SoundService.setVolume(_soundVolume);
      await SoundService.playNotificationSound();
    } else {
      await SoundService.setVolume(0);
    }
    _showSnackbar(value ? 'تم تفعيل الأصوات' : 'تم إيقاف الأصوات');
  }

  void _changeVolume(double value) async {
    setState(() => _soundVolume = value);
    await _saveSetting('soundVolume', value);
    if (_soundEnabled) {
      await SoundService.setVolume(value);
      await SoundService.playNotificationSound();
    }
  }

  void _shareApp() async {
    const shareText = '''
📱 *SecondMind* - عقلك الثاني الذي لا ينسى

تطبيق إدارة مهام بالذكاء الاصطناعي يساعدك على:
✅ تنظيم مهامك اليومية
🤖 استخراج التفاصيل من النصوص والصور
📊 تحليل إنتاجيتك
🎯 تحسين تركيزك
📅 تقويم ذكي للمهام
🔔 إشعارات وتذكيرات ذكية

📥 حمل التطبيق الآن:
https://secondmind.app/download
    ''';
    await Share.share(shareText);
    _showSuccessSnackbar('تم مشاركة التطبيق بنجاح');
  }

  Future<void> _clearAllData() async {
    try {
      final taskController = Get.find<TaskController>();
      for (var task in taskController.tasks) {
        await taskController.deleteTask(task.id);
      }
      
      if (_settingsBox != null) {
        await _settingsBox!.clear();
      }
      await _loadSettings();
      
      _showSuccessSnackbar('تم مسح جميع البيانات بنجاح');
    } catch (e) {
      _showSnackbar('حدث خطأ أثناء مسح البيانات: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
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
        _buildSection('الصوت', Icons.volume_up, _buildSoundCard()),
        const SizedBox(height: 20),
        _buildSection('الإشعارات الذكية', Icons.notifications_outlined, _buildNotificationsCard()),
        const SizedBox(height: 20),
        _buildSection('المظهر واللغة', Icons.palette_outlined, _buildAppearanceCard()),
        const SizedBox(height: 20),
        _buildSection('البيانات', Icons.storage, _buildDataCard()),
        const SizedBox(height: 20),
        _buildSection('الخصوصية والأمان', Icons.privacy_tip_outlined, _buildPrivacyCard()),
        const SizedBox(height: 20),
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: AppTheme.primary),
              ),
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
  // SOUND CARD
  //============================================================================
  Widget _buildSoundCard() {
    return Card(
      color: AppTheme.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text('تفعيل الأصوات', style: AppTheme.bodyLg),
            subtitle: Text('تشغيل الأصوات والإشعارات الصوتية', style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
            value: _soundEnabled,
            onChanged: _toggleSound,
            activeColor: AppTheme.primary,
            secondary: Icon(_soundEnabled ? Icons.volume_up : Icons.volume_off, color: AppTheme.primary),
          ),
          if (_soundEnabled)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.volume_down, size: 20, color: AppTheme.outline),
                      Expanded(
                        child: Slider(
                          value: _soundVolume,
                          onChanged: _changeVolume,
                          activeColor: AppTheme.primary,
                          inactiveColor: AppTheme.outlineVariant,
                          min: 0,
                          max: 1,
                        ),
                      ),
                      Icon(Icons.volume_up, size: 20, color: AppTheme.outline),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'مستوى الصوت: ${(_soundVolume * 100).round()}%',
                    style: AppTheme.labelSm.copyWith(color: AppTheme.outline),
                  ),
                ],
              ),
            ),
        ],
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
            onChanged: (v) async {
              setState(() => _smartReminders = v);
              await _saveSetting('smartReminders', v);
              _showSnackbar(v ? 'تم تفعيل التذكيرات الذكية' : 'تم إيقاف التذكيرات الذكية');
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildSwitchTile(
            title: 'الملخص اليومي',
            subtitle: 'موجز مسائي لإنجازات اليوم',
            value: _dailySummary,
            onChanged: (v) async {
              setState(() => _dailySummary = v);
              await _saveSetting('dailySummary', v);
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildSwitchTile(
            title: 'رسائل تحفيزية بالذكاء الاصطناعي',
            subtitle: 'تلقي رسائل مشجعة مخصصة لأهدافك',
            value: _aiMotivation,
            onChanged: (v) async {
              setState(() => _aiMotivation = v);
              await _saveSetting('aiMotivation', v);
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildSwitchTile(
            title: 'تذكيرات سياقية ذكية',
            subtitle: 'تذكيرات تتكيف مع جدولك وموقعك',
            value: _smartContextual,
            onChanged: (v) async {
              setState(() => _smartContextual = v);
              await _saveSetting('smartContextual', v);
            },
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
          ListTile(
            leading: Icon(Icons.dark_mode, color: AppTheme.primary),
            title: Text('الوضع المظلم', style: AppTheme.bodyLg),
            subtitle: Text('واجهة داكنة مريحة للعين', style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
            trailing: Switch(
              value: _darkMode,
              onChanged: _toggleDarkMode,
              activeColor: AppTheme.primary,
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
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
              onChanged: (value) async {
                if (value != null) {
                  setState(() => _selectedLanguage = value);
                  await _saveSetting('language', value);
                  _showSnackbar('سيتم تغيير اللغة بعد إعادة تشغيل التطبيق');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  //============================================================================
  // DATA CARD
  //============================================================================
  Widget _buildDataCard() {
    return Card(
      color: AppTheme.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'خيارات التصدير',
              style: AppTheme.labelMd.copyWith(
                color: AppTheme.outline,
                letterSpacing: 0.5,
              ),
            ),
          ),
          _buildExportOption(
            icon: Icons.code,
            title: 'تصدير كـ JSON',
            subtitle: 'ملف JSON للنسخ الاحتياطي',
            color: Colors.blue,
            onTap: _exportAsJSON,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildExportOption(
            icon: Icons.table_chart,
            title: 'تصدير كـ CSV',
            subtitle: 'ملف CSV للاستخدام في Excel',
            color: Colors.green,
            onTap: _exportAsCSV,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildExportOption(
            icon: Icons.picture_as_pdf,
            title: 'تصدير كـ HTML',
            subtitle: 'تقرير HTML قابل للطباعة',
            color: Colors.red,
            onTap: _exportAsPDF,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildExportOption(
            icon: Icons.share,
            title: 'مشاركة الملخص',
            subtitle: 'مشاركة ملخص مهامك عبر التطبيقات',
            color: Colors.orange,
            onTap: _shareAppData,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildExportOption(
            icon: Icons.delete_sweep,
            title: 'مسح جميع البيانات',
            subtitle: 'حذف جميع المهام والإعدادات نهائياً',
            color: AppTheme.error,
            onTap: _showClearDataDialog,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: AppTheme.bodyLg.copyWith(
          color: isDestructive ? AppTheme.error : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.labelSm.copyWith(color: AppTheme.outline),
      ),
      trailing: Icon(
        Icons.chevron_left,
        color: isDestructive ? AppTheme.error : AppTheme.outline,
      ),
      onTap: onTap,
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
            onChanged: (v) async {
              setState(() => _analyticsEnabled = v);
              await _saveSetting('analyticsEnabled', v);
            },
          ),
        ],
      ),
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
          ListTile(
            leading: Icon(Icons.star_outline, color: AppTheme.primary),
            title: Text('قيم التطبيق', style: AppTheme.bodyLg),
            subtitle: Text('قيّمنا في المتجر', style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
            trailing: Icon(Icons.chevron_left, color: AppTheme.outline),
            onTap: () => Get.to(() => const RateAppScreen()),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: Icon(Icons.share_outlined, color: AppTheme.primary),
            title: Text('شارك التطبيق', style: AppTheme.bodyLg),
            subtitle: Text('أرسل التطبيق لأصدقائك', style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
            trailing: Icon(Icons.chevron_left, color: AppTheme.outline),
            onTap: _shareApp,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: Icon(Icons.description_outlined, color: AppTheme.primary),
            title: Text('شروط الخدمة', style: AppTheme.bodyLg),
            subtitle: Text('اقرأ شروط الاستخدام', style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
            trailing: Icon(Icons.chevron_left, color: AppTheme.outline),
            onTap: () => Get.toNamed(AppRoutes.terms),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined, color: AppTheme.primary),
            title: Text('سياسة الخصوصية', style: AppTheme.bodyLg),
            subtitle: Text('كيف نتعامل مع بياناتك', style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
            trailing: Icon(Icons.chevron_left, color: AppTheme.outline),
            onTap: () => Get.toNamed(AppRoutes.privacy),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
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
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: Icon(Icons.logout, color: AppTheme.error),
            title: Text('تسجيل الخروج', style: AppTheme.bodyLg.copyWith(color: AppTheme.error)),
            subtitle: Text('تسجيل الخروج من حسابك', style: AppTheme.labelSm.copyWith(color: AppTheme.error.withValues(alpha: 0.7))),
            trailing: Icon(Icons.chevron_left, color: AppTheme.error),
            onTap: _showLogoutDialog,
          ),
        ],
      ),
    );
  }

  //============================================================================
  // DIALOGS
  //============================================================================
  void _showClearDataDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('مسح جميع البيانات', style: AppTheme.headlineMd.copyWith(color: AppTheme.error)),
        content: const Text('هل أنت متأكد؟ سيتم حذف جميع مهامك وإعداداتك نهائياً.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء', style: AppTheme.labelMd.copyWith(color: AppTheme.outline)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _clearAllData();
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
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء', style: AppTheme.labelMd.copyWith(color: AppTheme.outline)),
          ),
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

  //============================================================================
  // EXPORT FUNCTIONS
  //============================================================================

  Future<void> _exportAsJSON() async {
    try {
      final taskController = Get.find<TaskController>();
      final tasks = taskController.tasks;
      
      final exportData = {
        'appName': 'SecondMind',
        'exportDate': DateTime.now().toIso8601String(),
        'version': _appVersion,
        'totalTasks': tasks.length,
        'stats': {
          'completedTasks': taskController.completedTasks,
          'completionRate': taskController.completionRate,
          'missedTasks': taskController.missedTasks,
          'urgentTasks': taskController.urgentTasks,
        },
        'tasks': tasks.map((task) => {
          'id': task.id,
          'title': task.title,
          'description': task.description,
          'dueDate': task.dueDate?.toIso8601String(),
          'status': task.status.index,
          'priority': task.priority.index,
          'category': task.category.index,
          'createdAt': task.createdAt.toIso8601String(),
          'completedAt': task.completedAt?.toIso8601String(),
          'location': task.location,
          'attendanceType': task.attendanceType?.index,
          'meetingLink': task.meetingLink,
          'organizer': task.organizer,
          'contactPhone': task.contactPhone,
          'contactEmail': task.contactEmail,
          'registrationLink': task.registrationLink,
          'fee': task.fee,
          'additionalNotes': task.additionalNotes,
        }).toList(),
      };
      
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'secondmind_export_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '📊 تصدير بيانات SecondMind (JSON)\n\nتم تصدير ${tasks.length} مهمة بنجاح',
      );
      
      _showSuccessSnackbar('تم تصدير ${tasks.length} مهمة بتنسيق JSON');
    } catch (e) {
      _showSnackbar('حدث خطأ أثناء تصدير البيانات: $e', isError: true);
    }
  }

  Future<void> _exportAsCSV() async {
    try {
      final taskController = Get.find<TaskController>();
      final tasks = taskController.tasks;
      
      String csvText = 'ID,العنوان,الوصف,التاريخ,الحالة,الأولوية,التصنيف,المكان,الجهة المنظمة,الرسوم,تاريخ الإنشاء\n';
      
      for (var task in tasks) {
        csvText += '"${task.id}","${_escapeCSV(task.title)}","${_escapeCSV(task.description ?? '')}",';
        csvText += '"${task.dueDate ?? ''}","${task.status.index}","${task.priority.index}","${task.category.index}",';
        csvText += '"${_escapeCSV(task.location ?? '')}","${_escapeCSV(task.organizer ?? '')}","${_escapeCSV(task.fee ?? '')}","${task.createdAt}"\n';
      }
      
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'secondmind_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvText, encoding: utf8);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '📊 تصدير بيانات SecondMind (CSV)\n\nيمكن فتح الملف في Excel أو Google Sheets',
      );
      
      _showSuccessSnackbar('تم تصدير ${tasks.length} مهمة بتنسيق CSV');
    } catch (e) {
      _showSnackbar('حدث خطأ أثناء تصدير البيانات: $e', isError: true);
    }
  }

  Future<void> _exportAsPDF() async {
    try {
      final taskController = Get.find<TaskController>();
      final tasks = taskController.tasks;
      
      String htmlContent = '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>SecondMind - تصدير المهام</title>
        <style>
          body { font-family: Arial, sans-serif; direction: rtl; padding: 20px; }
          h1 { color: #4A6458; text-align: center; }
          .stats { background: #f5f5f5; padding: 15px; border-radius: 10px; margin-bottom: 20px; }
          .task { border: 1px solid #ddd; padding: 15px; margin-bottom: 15px; border-radius: 8px; }
          .task-title { font-size: 18px; font-weight: bold; color: #4A6458; }
          .task-detail { margin: 5px 0; color: #666; }
        </style>
      </head>
      <body>
        <h1>📊 SecondMind - تقرير المهام</h1>
        <div class="stats">
          <h3>📈 ملخص الإحصائيات</h3>
          <p>📅 تاريخ التصدير: ${DateTime.now()}</p>
          <p>📋 إجمالي المهام: ${tasks.length}</p>
          <p>✅ المهام المكتملة: ${taskController.completedTasks}</p>
          <p>📊 نسبة الإنجاز: ${taskController.completionRate}%</p>
          <p>⚠️ المهام الفائتة: ${taskController.missedTasks}</p>
          <p>🔴 المهام العاجلة: ${taskController.urgentTasks}</p>
        </div>
      ''';
      
      for (var task in tasks) {
        htmlContent += '''
        <div class="task">
          <div class="task-title">📌 ${_escapeHtml(task.title)}</div>
          <div class="task-detail">📝 ${_escapeHtml(task.description ?? 'لا يوجد وصف')}</div>
          <div class="task-detail">📅 التاريخ: ${task.dueDate ?? 'غير محدد'}</div>
        </div>
        ''';
      }
      
      htmlContent += '''
      </body>
      </html>
      ''';
      
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'secondmind_export_${DateTime.now().millisecondsSinceEpoch}.html';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(htmlContent, encoding: utf8);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '📊 تصدير بيانات SecondMind (HTML)\n\nيمكن فتح الملف في أي متصفح',
      );
      
      _showSuccessSnackbar('تم تصدير ${tasks.length} مهمة كتقرير HTML');
    } catch (e) {
      _showSnackbar('حدث خطأ أثناء تصدير التقرير: $e', isError: true);
    }
  }

  String _escapeCSV(String text) {
    return text.replaceAll('"', '""').replaceAll('\n', ' ');
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  Future<void> _shareAppData() async {
    try {
      final taskController = Get.find<TaskController>();
      final tasks = taskController.tasks;
      
      String shareText = '📱 *SecondMind* - ملخص مهامي\n\n';
      shareText += '📅 التاريخ: ${DateTime.now()}\n';
      shareText += '📊 إجمالي المهام: ${tasks.length}\n';
      shareText += '✅ المهام المكتملة: ${taskController.completedTasks}\n';
      shareText += '📈 نسبة الإنجاز: ${taskController.completionRate}%\n';
      shareText += '⚠️ المهام الفائتة: ${taskController.missedTasks}\n\n';
      shareText += '━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
      shareText += '📌 *قائمة المهام:*\n\n';
      
      for (var task in tasks.take(10)) {
        shareText += '• ${task.title}\n';
        if (task.dueDate != null) {
          shareText += '  📅 ${task.dueDate}\n';
        }
      }
      
      if (tasks.length > 10) {
        shareText += '\n... و ${tasks.length - 10} مهام أخرى\n';
      }
      
      shareText += '\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
      shareText += '📱 SecondMind - عقلك الثاني الذي لا ينسى\n';
      
      await Share.share(shareText);
      _showSuccessSnackbar('تم مشاركة ملخص المهام بنجاح');
    } catch (e) {
      _showSnackbar('حدث خطأ أثناء المشاركة: $e', isError: true);
    }
  }
}