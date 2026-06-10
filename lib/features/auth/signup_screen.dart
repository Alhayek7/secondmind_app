// lib/features/auth/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:secondmind/core/theme/app_theme.dart';
import 'package:secondmind/core/routes/app_routes.dart';
import 'package:secondmind/features/legal/terms_screen.dart';
import 'package:secondmind/features/legal/privacy_policy_screen.dart';
import 'package:secondmind/data/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _isLoading = false.obs;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

Future<void> _handleSignup() async {
  if (_nameController.text.trim().isEmpty) {
    _showErrorSnackbar('الرجاء إدخال الاسم الكامل');
    return;
  }
  if (_emailController.text.trim().isEmpty) {
    _showErrorSnackbar('الرجاء إدخال البريد الإلكتروني');
    return;
  }
  if (!_emailController.text.contains('@')) {
    _showErrorSnackbar('الرجاء إدخال بريد إلكتروني صحيح');
    return;
  }
  if (_passwordController.text.isEmpty) {
    _showErrorSnackbar('الرجاء إدخال كلمة المرور');
    return;
  }
  if (_passwordController.text.length < 6) {
    _showErrorSnackbar('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
    return;
  }
  if (_passwordController.text != _confirmPasswordController.text) {
    _showErrorSnackbar('كلمة المرور غير متطابقة');
    return;
  }
  if (!_agreeTerms) {
    _showErrorSnackbar('يجب الموافقة على شروط الخدمة وسياسة الخصوصية');
    return;
  }

  _isLoading.value = true;
  await Future.delayed(const Duration(seconds: 1));
  _isLoading.value = false;
  
  // ✅ حفظ حالة تسجيل الدخول
  await AuthService.to.login();
  
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
      title: const Text('إنشاء حساب جديد'),
      centerTitle: true,
      backgroundColor: AppTheme.surface.withOpacity(0.95),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.primary),
        onPressed: () => Get.back(),
      ),
    );
  }

  //============================================================================
  // BODY
  //============================================================================
  Widget _buildBody() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildLogo(),
            const SizedBox(height: 16),
            _buildHeader(),
            const SizedBox(height: 32),
            _buildSignupCard(),
            const SizedBox(height: 20),
            _buildLoginLink(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  //============================================================================
  // LOGO
  //============================================================================
  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
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
        size: 42,
        color: Colors.white,
      ),
    );
  }

  //============================================================================
  // HEADER
  //============================================================================
  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'إنشاء حساب جديد',
          style: AppTheme.headlineLg.copyWith(
            color: AppTheme.primary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'ابدأ رحلتك نحو الإنتاجية الهادئة اليوم',
          style: AppTheme.bodyMd.copyWith(
            color: AppTheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  //============================================================================
  // SIGNUP CARD
  //============================================================================
  Widget _buildSignupCard() {
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
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildNameField(),
          const SizedBox(height: 18),
          _buildEmailField(),
          const SizedBox(height: 18),
          _buildPasswordField(),
          const SizedBox(height: 18),
          _buildConfirmPasswordField(),
          const SizedBox(height: 20),
          _buildTermsCheckbox(),
          const SizedBox(height: 28),
          _buildSignupButton(),
          const SizedBox(height: 24),
          _buildDivider(),
          const SizedBox(height: 20),
          _buildSocialButtons(),
        ],
      ),
    );
  }

  //============================================================================
  // NAME FIELD
  //============================================================================
  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الاسم الكامل',
          style: AppTheme.labelMd.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'أدخل اسمك هنا',
            prefixIcon: Icon(Icons.person_outline, color: AppTheme.outline),
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
          ),
        ),
      ],
    );
  }

  //============================================================================
  // EMAIL FIELD
  //============================================================================
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'البريد الإلكتروني',
          style: AppTheme.labelMd.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            hintText: 'example@email.com',
            prefixIcon: Icon(Icons.email_outlined, color: AppTheme.outline),
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
          ),
        ),
      ],
    );
  }

  //============================================================================
  // PASSWORD FIELD
  //============================================================================
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'كلمة المرور',
          style: AppTheme.labelMd.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            hintText: '•••••••• (6 أحرف على الأقل)',
            prefixIcon: Icon(Icons.lock_outline, color: AppTheme.outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppTheme.outline,
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
          ),
        ),
      ],
    );
  }

  //============================================================================
  // CONFIRM PASSWORD FIELD
  //============================================================================
  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تأكيد كلمة المرور',
          style: AppTheme.labelMd.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: Icon(Icons.lock_outline, color: AppTheme.outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppTheme.outline,
              ),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
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
          ),
        ),
      ],
    );
  }

  //============================================================================
  // TERMS CHECKBOX
  //============================================================================
  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: _agreeTerms,
            onChanged: (value) => setState(() => _agreeTerms = value ?? false),
            activeColor: AppTheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTheme.labelSm,
              children: [
                const TextSpan(
                  text: 'أوافق على ',
                  style: TextStyle(color: Color(0xFF424844)),
                ),
                TextSpan(
                  text: 'شروط الخدمة',
                  style: const TextStyle(color: Color(0xFF4A6458), fontWeight: FontWeight.bold),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => Get.to(() => const TermsScreen(isPrivacy: false)),
                ),
                const TextSpan(
                  text: ' و ',
                  style: TextStyle(color: Color(0xFF424844)),
                ),
                TextSpan(
                  text: 'سياسة الخصوصية',
                  style: const TextStyle(color: Color(0xFF4A6458), fontWeight: FontWeight.bold),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => Get.to(() => const PrivacyPolicyScreen()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  //============================================================================
  // SIGNUP BUTTON
  //============================================================================
  Widget _buildSignupButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading.value ? null : _handleSignup,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
        child: _isLoading.value
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : const Text('إنشاء الحساب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    ));
  }

  //============================================================================
  // DIVIDER
  //============================================================================
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppTheme.outlineVariant, thickness: 0.8)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('أو الاشتراك بواسطة', style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
        ),
        Expanded(child: Divider(color: AppTheme.outlineVariant, thickness: 0.8)),
      ],
    );
  }

  //============================================================================
  // SOCIAL BUTTONS
  //============================================================================
  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showErrorSnackbar('سيتم إضافة التسجيل عبر Google قريباً'),
            icon: const Icon(Icons.g_mobiledata, size: 20),
            label: const Text('جوجل'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              side: BorderSide(color: AppTheme.outlineVariant),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showErrorSnackbar('سيتم إضافة التسجيل عبر Apple قريباً'),
            icon: const Icon(Icons.apple, size: 20),
            label: const Text('آبل'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              side: BorderSide(color: AppTheme.outlineVariant),
            ),
          ),
        ),
      ],
    );
  }

  //============================================================================
  // LOGIN LINK
  //============================================================================
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('لديك حساب بالفعل؟', style: AppTheme.bodyMd),
        TextButton(
          onPressed: () => Get.back(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'تسجيل الدخول',
            style: AppTheme.labelMd.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}