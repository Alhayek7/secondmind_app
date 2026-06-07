// lib/features/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:secondmind/core/theme/app_theme.dart';
import 'package:secondmind/core/routes/app_routes.dart';
import 'package:secondmind/features/legal/terms_screen.dart';
import 'package:secondmind/features/legal/privacy_policy_screen.dart';
import 'package:secondmind/data/services/auth_service.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _isLoading = false.obs;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //============================================================================
  // LOGIC METHODS
  //============================================================================

Future<void> _handleLogin() async {
  if (_emailController.text.isEmpty) {
    _showErrorSnackbar('الرجاء إدخال البريد الإلكتروني');
    return;
  }
  if (_passwordController.text.isEmpty) {
    _showErrorSnackbar('الرجاء إدخال كلمة المرور');
    return;
  }
  if (!_emailController.text.contains('@')) {
    _showErrorSnackbar('الرجاء إدخال بريد إلكتروني صحيح');
    return;
  }

  _isLoading.value = true;
  await Future.delayed(const Duration(seconds: 1));
  _isLoading.value = false;
  
  // ✅ إضافة تسجيل الدخول في خدمة المصادقة
  AuthService.to.login();
  
  Get.offAllNamed(AppRoutes.tasks);
}

Future<void> _handleGuestLogin() async {
  _isLoading.value = true;
  await Future.delayed(const Duration(milliseconds: 800));
  _isLoading.value = false;
  
  // ✅ إضافة تسجيل الدخول في خدمة المصادقة
  AuthService.to.login();
  
  Get.offAllNamed(AppRoutes.tasks);
}



  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'تنبيه',
      message,
      backgroundColor: AppTheme.errorContainer,
      colorText: AppTheme.onErrorContainer,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  //============================================================================
  // UI BUILD
  //============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 20),
                _buildWelcomeText(),
                const SizedBox(height: 40),
                _buildLoginCard(),
                const SizedBox(height: 20),
                _buildSignupLink(),
                const SizedBox(height: 20),
                _buildFooterLinks(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //============================================================================
  // WIDGET COMPONENTS
  //============================================================================

  Widget _buildLogo() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(
        Icons.task_alt_rounded,
        size: 45,
        color: Colors.white,
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'مرحباً بك مجدداً',
          style: AppTheme.headlineLg.copyWith(
            color: AppTheme.primary,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'في واحة الإنتاجية',
          style: AppTheme.bodyMd.copyWith(
            color: AppTheme.onSurfaceVariant,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildEmailField(),
            const SizedBox(height: 20),
            _buildPasswordField(),
            const SizedBox(height: 16),
            _buildOptionsRow(),
            const SizedBox(height: 28),
            _buildLoginButton(),
            const SizedBox(height: 16),
            _buildGuestButton(),
            const SizedBox(height: 24),
            _buildDivider(),
            const SizedBox(height: 20),
            _buildSocialButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'البريد الإلكتروني',
          style: AppTheme.labelMd.copyWith(
            color: AppTheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            hintText: 'name@example.com',
            hintStyle: AppTheme.bodyMd.copyWith(color: AppTheme.outline),
            prefixIcon: Icon(Icons.email_outlined, color: AppTheme.outline, size: 22),
            filled: true,
            fillColor: AppTheme.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'كلمة المرور',
          style: AppTheme.labelMd.copyWith(
            color: AppTheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: AppTheme.bodyMd.copyWith(color: AppTheme.outline),
            prefixIcon: Icon(Icons.lock_outline, color: AppTheme.outline, size: 22),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppTheme.outline,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: AppTheme.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) => setState(() => _rememberMe = value ?? false),
                activeColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
            const SizedBox(width: 8),
            Text('تذكرني', style: AppTheme.bodyMd.copyWith(color: AppTheme.onSurfaceVariant, fontSize: 13)),
          ],
        ),
        TextButton(
          onPressed: () => _showErrorSnackbar('سيتم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني'),
          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          child: Text('نسيت كلمة المرور؟', style: AppTheme.labelSm.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading.value ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.onPrimary,
          elevation: 2,
          shadowColor: AppTheme.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading.value
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : const Text('تسجيل الدخول', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    ));
  }

  Widget _buildGuestButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: _isLoading.value ? null : _handleGuestLogin,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppTheme.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading.value
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 20, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Text('دخول مستخدم تجريبي', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.primary)),
                ],
              ),
      ),
    ));
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppTheme.outlineVariant, thickness: 0.8)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('أو المتابعة عبر', style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
        ),
        Expanded(child: Divider(color: AppTheme.outlineVariant, thickness: 0.8)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showErrorSnackbar('سيتم إضافة تسجيل الدخول عبر Google قريباً'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              side: BorderSide(color: AppTheme.outlineVariant),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.g_mobiledata, size: 20),
                const SizedBox(width: 8),
                Text('جوجل', style: TextStyle(color: AppTheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showErrorSnackbar('سيتم إضافة تسجيل الدخول عبر Apple قريباً'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              side: BorderSide(color: AppTheme.outlineVariant),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.apple, size: 20),
                const SizedBox(width: 8),
                Text('آبل', style: TextStyle(color: AppTheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('ليس لديك حساب؟', style: AppTheme.bodyMd.copyWith(color: AppTheme.onSurfaceVariant)),
        TextButton(
          onPressed: () => Get.toNamed(AppRoutes.signup),
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          child: Text('إنشاء حساب جديد', style: AppTheme.labelMd.copyWith(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildFooterLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => Get.to(() => const TermsScreen(isPrivacy: false)),
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: Size.zero),
          child: Text('شروط الخدمة', style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
        ),
        Text('•', style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
        TextButton(
          onPressed: () => Get.to(() => const PrivacyPolicyScreen()),
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: Size.zero),
          child: Text('سياسة الخصوصية', style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
        ),
      ],
    );
  }
}