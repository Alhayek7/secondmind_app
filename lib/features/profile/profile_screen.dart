// lib/features/profile/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:secondmind/core/theme/app_theme.dart';
import 'package:secondmind/core/routes/app_routes.dart';
import 'package:secondmind/data/models/task_model.dart';
import 'package:secondmind/data/services/auth_service.dart';
import 'package:secondmind/features/tasks/controllers/task_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController(text: 'سارة أحمد');
  final _emailController = TextEditingController(text: 'sara@example.com');
  final _phoneController = TextEditingController(text: '+966 5XXXXXXXX');
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isEditing = false;
  bool _isChangingPassword = false;
  bool _notificationsEnabled = true;
  bool _aiRecommendations = true;
  bool _darkMode = false;
  File? _profileImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  //============================================================================
  // PROFILE IMAGE
  //============================================================================
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('التقاط صورة'),
              onTap: () async {
                Navigator.pop(context);
                final image =
                    await _picker.pickImage(source: ImageSource.camera);
                if (image != null)
                  setState(() => _profileImage = File(image.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('اختيار من المعرض'),
              onTap: () async {
                Navigator.pop(context);
                final image =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (image != null)
                  setState(() => _profileImage = File(image.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  //============================================================================
  // CHANGE PASSWORD
  //============================================================================
  Future<void> _changePassword() async {
    if (_newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      Get.snackbar('تنبيه', 'الرجاء إدخال كلمة المرور الجديدة');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      Get.snackbar('تنبيه', 'كلمة المرور غير متطابقة');
      return;
    }
    if (_newPasswordController.text.length < 6) {
      Get.snackbar('تنبيه', 'كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return;
    }

    // محاكاة تغيير كلمة المرور
    Get.back();
    Get.snackbar('نجاح', 'تم تغيير كلمة المرور بنجاح');
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    setState(() => _isChangingPassword = false);
  }

  //============================================================================
  // EXPORT DATA
  //============================================================================
  Future<void> _exportData() async {
    final taskController = Get.find<TaskController>();
    final tasks = taskController.tasks;

    final exportData = {
      'user': {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
      },
      'tasks': tasks
          .map((task) => {
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
              })
          .toList(),
      'stats': {
        'totalTasks': tasks.length,
        'completedTasks':
            tasks.where((t) => t.status == TaskStatus.completed).length,
        'completionRate': tasks.isEmpty
            ? 0
            : (tasks.where((t) => t.status == TaskStatus.completed).length /
                    tasks.length *
                    100)
                .round(),
      },
      'exportDate': DateTime.now().toIso8601String(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
        '${directory.path}/secondmind_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonString);

    Share.shareXFiles(
      [XFile(file.path)],
      text: '📊 تصدير بيانات SecondMind',
    );

    Get.snackbar('نجاح', 'تم تصدير البيانات بنجاح');
  }

  //============================================================================
  // DELETE ACCOUNT
  //============================================================================
  Future<void> _deleteAccount() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('حذف الحساب',
            style: AppTheme.headlineMd.copyWith(color: AppTheme.error)),
        content: const Text(
            'هل أنت متأكد من حذف حسابك؟ سيتم حذف جميع بياناتك نهائياً.'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // حذف جميع المهام
      final taskController = Get.find<TaskController>();
      for (var task in taskController.tasks) {
        await taskController.deleteTask(task.id);
      }
      AuthService.to.logout();
    }
  }

  //============================================================================
  // SHARE APP
  //============================================================================
  Future<void> _shareApp() async {
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

  //============================================================================
  // RATE APP
  //============================================================================
  Future<void> _rateApp() async {
    // رابط المتجر (سيتم تحديثه عند النشر)
    const url =
        'https://play.google.com/store/apps/details?id=com.secondmind.app';
    await Share.share('قيم تطبيق SecondMind: $url');
  }

  //============================================================================
  // TOGGLE DARK MODE
  //============================================================================
  void _toggleDarkMode(bool value) {
    setState(() => _darkMode = value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    Get.snackbar('تم التغيير',
        value ? 'تم تفعيل الوضع المظلم' : 'تم تفعيل الوضع الفاتح');
  }

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();
    final completedTasks = taskController.tasks
        .where((t) => t.status == TaskStatus.completed)
        .length;
    final totalTasks = taskController.tasks.length;
    final completionRate =
        totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileImage(),
            const SizedBox(height: 24),
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildStatsCard(completedTasks, totalTasks, completionRate),
            const SizedBox(height: 20),
            _buildPreferencesCard(),
            const SizedBox(height: 20),
            _buildSecurityCard(),
            const SizedBox(height: 20),
            _buildAppActionsCard(),
            const SizedBox(height: 20),
            _buildLogoutButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_isEditing ? 'تعديل الملف الشخصي' : 'الملف الشخصي'),
      centerTitle: true,
      backgroundColor: AppTheme.surface.withValues(alpha: 0.95),
      elevation: 0,
          leading: IconButton(  // ✅ أضف هذا
      icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.primary),
      onPressed: () => Get.back(),
    ),
      automaticallyImplyLeading: false,
      actions: [
        if (!_isEditing)
          TextButton.icon(
            onPressed: () => setState(() => _isEditing = true),
            icon: Icon(Icons.edit, size: 18, color: AppTheme.primary),
            label: Text('تعديل',
                style: AppTheme.labelMd.copyWith(color: AppTheme.primary)),
          )
        else
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    _resetFields();
                  });
                },
                icon: Icon(Icons.close, size: 18, color: AppTheme.error),
                label: Text('إلغاء',
                    style: AppTheme.labelMd.copyWith(color: AppTheme.error)),
              ),
              TextButton.icon(
                onPressed: _saveProfile,
                icon: Icon(Icons.check, size: 18, color: AppTheme.primary),
                label: Text('حفظ',
                    style: AppTheme.labelMd.copyWith(color: AppTheme.primary)),
              ),
            ],
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _resetFields() {
    _nameController.text = 'سارة أحمد';
    _emailController.text = 'sara@example.com';
    _phoneController.text = '+966 5XXXXXXXX';
  }

  void _saveProfile() {
    setState(() => _isEditing = false);
    Get.snackbar('تم الحفظ', 'تم تحديث الملف الشخصي بنجاح');
  }

  //============================================================================
  // PROFILE IMAGE WIDGET
  //============================================================================
  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
              boxShadow: AppTheme.mediumShadow,
            ),
            child: ClipOval(
              child: _profileImage != null
                  ? Image.file(_profileImage!, fit: BoxFit.cover)
                  : const Icon(Icons.person, size: 55, color: Colors.white),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  //============================================================================
  // INFO CARD
  //============================================================================
  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTextField(
            label: 'الاسم الكامل',
            controller: _nameController,
            icon: Icons.person_outline,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'البريد الإلكتروني',
            controller: _emailController,
            icon: Icons.email_outlined,
            enabled: _isEditing,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'رقم الهاتف',
            controller: _phoneController,
            icon: Icons.phone_outlined,
            enabled: _isEditing,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.labelMd),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: enabled ? AppTheme.softShadow : null,
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            style: AppTheme.bodyLg,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppTheme.outline),
              filled: true,
              fillColor: enabled
                  ? AppTheme.surfaceContainerLow
                  : AppTheme.surfaceContainerLowest,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppTheme.primary, width: 1.5)),
            ),
          ),
        ),
      ],
    );
  }

  //============================================================================
  // STATS CARD
  //============================================================================
  Widget _buildStatsCard(int completed, int total, int rate) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withValues(alpha: 0.05),
            AppTheme.primaryContainer.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Icon(Icons.check_circle_outline,
                    size: 28, color: AppTheme.statusCompleted),
                const SizedBox(height: 8),
                Text('$completed',
                    style: AppTheme.headlineLg.copyWith(
                        fontSize: 22, color: AppTheme.statusCompleted)),
                const SizedBox(height: 4),
                Text('مهام مكتملة', style: AppTheme.labelSm),
              ],
            ),
          ),
          Container(width: 1, height: 50, color: AppTheme.outlineVariant),
          Expanded(
            child: Column(
              children: [
                Icon(Icons.trending_up, size: 28, color: AppTheme.primary),
                const SizedBox(height: 8),
                Text('$rate%',
                    style: AppTheme.headlineLg
                        .copyWith(fontSize: 22, color: AppTheme.primary)),
                const SizedBox(height: 4),
                Text('نسبة الإنجاز', style: AppTheme.labelSm),
              ],
            ),
          ),
          Container(width: 1, height: 50, color: AppTheme.outlineVariant),
          Expanded(
            child: Column(
              children: [
                Icon(Icons.local_fire_department,
                    size: 28, color: AppTheme.statusPending),
                const SizedBox(height: 8),
                Text('$total',
                    style: AppTheme.headlineLg
                        .copyWith(fontSize: 22, color: AppTheme.statusPending)),
                const SizedBox(height: 4),
                Text('إجمالي المهام', style: AppTheme.labelSm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //============================================================================
  // PREFERENCES CARD
  //============================================================================
  Widget _buildPreferencesCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text('التفضيلات',
                style: AppTheme.labelMd
                    .copyWith(color: AppTheme.outline, letterSpacing: 0.5)),
          ),
          _buildSwitchTile(
              'إشعارات المهام',
              'تنبيهات للمهام القادمة',
              _notificationsEnabled,
              (v) => setState(() => _notificationsEnabled = v)),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildSwitchTile(
              'توصيات الذكاء الاصطناعي',
              'اقتراحات ذكية لتحسين إنتاجيتك',
              _aiRecommendations,
              (v) => setState(() => _aiRecommendations = v)),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildSwitchTile('الوضع المظلم', 'واجهة داكنة مريحة للعين', _darkMode,
              _toggleDarkMode),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: AppTheme.bodyLg),
      subtitle: Text(subtitle,
          style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            color: AppTheme.primaryContainer.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12)),
        child: Icon(
            value ? Icons.notifications_active : Icons.notifications_off,
            size: 20,
            color: value ? AppTheme.primary : AppTheme.outline),
      ),
    );
  }

  //============================================================================
  // SECURITY CARD
  //============================================================================
  Widget _buildSecurityCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text('الأمان',
                style: AppTheme.labelMd
                    .copyWith(color: AppTheme.outline, letterSpacing: 0.5)),
          ),
          ListTile(
            leading: Icon(Icons.lock_outline, color: AppTheme.primary),
            title: const Text('تغيير كلمة المرور'),
            trailing: Icon(Icons.chevron_left, color: AppTheme.outline),
            onTap: () => _showChangePasswordDialog(),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          ListTile(
            leading: Icon(Icons.download_outlined, color: AppTheme.primary),
            title: const Text('تصدير البيانات'),
            trailing: Icon(Icons.chevron_left, color: AppTheme.outline),
            onTap: _exportData,
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    setState(() => _isChangingPassword = true);
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تغيير كلمة المرور'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'كلمة المرور الجديدة'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
                setState(() => _isChangingPassword = false);
              },
              child: const Text('إلغاء')),
          ElevatedButton(
              onPressed: _changePassword,
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              child: const Text('تغيير')),
        ],
      ),
    );
  }

  //============================================================================
  // APP ACTIONS CARD
  //============================================================================
  Widget _buildAppActionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text('التطبيق',
                style: AppTheme.labelMd
                    .copyWith(color: AppTheme.outline, letterSpacing: 0.5)),
          ),
          ListTile(
            leading: Icon(Icons.share_outlined, color: AppTheme.primary),
            title: const Text('مشاركة التطبيق'),
            trailing: Icon(Icons.chevron_left, color: AppTheme.outline),
            onTap: _shareApp,
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          ListTile(
            leading: Icon(Icons.star_outline, color: AppTheme.primary),
            title: const Text('تقييم التطبيق'),
            trailing: Icon(Icons.chevron_left, color: AppTheme.outline),
            onTap: () => Get.toNamed(AppRoutes.rate),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          ListTile(
            leading: Icon(Icons.description_outlined, color: AppTheme.primary),
            title: const Text('شروط الخدمة'),
            trailing: Icon(Icons.chevron_left, color: AppTheme.outline),
            onTap: () => Get.toNamed(AppRoutes.terms),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined, color: AppTheme.primary),
            title: const Text('سياسة الخصوصية'),
            trailing: Icon(Icons.chevron_left, color: AppTheme.outline),
            onTap: () => Get.toNamed(AppRoutes.privacy),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          ListTile(
            leading: Icon(Icons.info_outline, color: AppTheme.outline),
            title: const Text('إصدار التطبيق'),
            trailing: Text('v1.0.0',
                style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
          ),
        ],
      ),
    );
  }

  //============================================================================
  // LOGOUT BUTTON
  //============================================================================
  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListTile(
        onTap: _showLogoutDialog,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: AppTheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.logout, color: AppTheme.error),
        ),
        title: Text('تسجيل الخروج',
            style: AppTheme.bodyLg
                .copyWith(color: AppTheme.error, fontWeight: FontWeight.w600)),
        subtitle: Text('تسجيل الخروج من حسابك',
            style: AppTheme.labelSm
                .copyWith(color: AppTheme.error.withValues(alpha: 0.7))),
        trailing: Icon(Icons.chevron_left, color: AppTheme.error),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('تسجيل الخروج',
            style: AppTheme.headlineMd.copyWith(color: AppTheme.error)),
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
