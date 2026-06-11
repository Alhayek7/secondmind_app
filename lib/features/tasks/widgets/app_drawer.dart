// lib/features/tasks/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondmind/core/theme/app_theme.dart';
import 'package:secondmind/core/routes/app_routes.dart';
import 'package:secondmind/features/help/help_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'سارة أحمد',
                  style: AppTheme.headlineMd.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'sara@example.com',
                  style: AppTheme.bodyMd.copyWith(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // قائمة التنقل
          _buildDrawerItem(
            icon: Icons.person_outline,
            title: 'الملف الشخصي',
            onTap: () {
              Get.back();
              Get.toNamed(AppRoutes.profile);
            },
          ),
          _buildDrawerItem(
            icon: Icons.settings_outlined,
            title: 'الإعدادات',
            onTap: () {
              Get.back();
              Get.toNamed(AppRoutes.settings);
            },
          ),
          _buildDrawerItem(
            icon: Icons.help_outline,
            title: 'المساعدة والدعم',
            onTap: () {
              Get.back();
              Get.to(() => const HelpScreen());
            },
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'تسجيل الخروج',
            onTap: () {
              Get.back();
              _showLogoutDialog();
            },
            isDestructive: true,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'الإصدار 1.0.0',
              style: AppTheme.labelSm.copyWith(color: AppTheme.outline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading:
          Icon(icon, color: isDestructive ? AppTheme.error : AppTheme.primary),
      title: Text(
        title,
        style: AppTheme.bodyLg.copyWith(
          color: isDestructive ? AppTheme.error : AppTheme.onSurface,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Colors.transparent,
      hoverColor: AppTheme.primaryContainer.withValues(alpha: 0.1),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('تسجيل الخروج',
            style: AppTheme.headlineMd.copyWith(color: AppTheme.error)),
        content: Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟',
            style: AppTheme.bodyMd),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء',
                style: AppTheme.labelMd.copyWith(color: AppTheme.outline)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: AppTheme.onError,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
