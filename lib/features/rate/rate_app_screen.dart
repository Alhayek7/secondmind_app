// lib/features/rate/rate_app_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:secondmind/core/theme/app_theme.dart';


class RateAppScreen extends StatefulWidget {
  const RateAppScreen({super.key});

  @override
  State<RateAppScreen> createState() => _RateAppScreenState();
}

class _RateAppScreenState extends State<RateAppScreen> {
  double _rating = 0;  // ✅ تغيير إلى double
  String _feedback = '';
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _ratingOptions = [
    {'stars': 1, 'emoji': '😞', 'title': 'سيء جداً', 'color': const Color(0xFFE74C3C)},
    {'stars': 2, 'emoji': '🙁', 'title': 'سيء', 'color': const Color(0xFFE67E22)},
    {'stars': 3, 'emoji': '😐', 'title': 'متوسط', 'color': const Color(0xFFF39C12)},
    {'stars': 4, 'emoji': '🙂', 'title': 'جيد', 'color': const Color(0xFF2ECC71)},
    {'stars': 5, 'emoji': '😍', 'title': 'ممتاز', 'color': const Color(0xFF4A6458)},
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      Get.snackbar(
        'تنبيه',
        'الرجاء اختيار تقييم للتطبيق',
        backgroundColor: AppTheme.errorContainer,
        colorText: AppTheme.onErrorContainer,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isSubmitting = false);

    if (_rating >= 4) {
      _showRateOnStoreDialog();
    } else {
      _showFeedbackDialog();
    }
  }

  void _showRateOnStoreDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.favorite, color: AppTheme.statusCompleted),
            const SizedBox(width: 10),
            const Text('شكراً لك!'),
          ],
        ),
        content: Text(
          'نحن سعداء بأنك تحب SecondMind! هل يمكنك تقييمنا في المتجر؟',
          style: AppTheme.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _shareFeedback();
            },
            child: Text('ليس الآن', style: AppTheme.labelMd.copyWith(color: AppTheme.outline)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _openStore();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.onPrimary,
            ),
            child: const Text('تقييم الآن'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('ساعدنا في التحسين'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'نأسف أن تجربتك لم تكن مثالية. هل يمكنك إخبارنا بالمشكلة؟',
              style: AppTheme.bodyMd,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'اكتب ملاحظاتك هنا...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء', style: AppTheme.labelMd.copyWith(color: AppTheme.outline)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _submitFeedback();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.onPrimary,
            ),
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  void _submitFeedback() {
    final feedback = _feedbackController.text.trim();
    if (feedback.isNotEmpty) {
      Get.snackbar(
        'شكراً لك',
        'تم إرسال ملاحظاتك بنجاح. سنعمل على تحسين التطبيق.',
        backgroundColor: AppTheme.primary,
        colorText: AppTheme.onPrimary,
      );
      _feedbackController.clear();
    } else {
      Get.snackbar(
        'تنبيه',
        'الرجاء كتابة ملاحظاتك قبل الإرسال',
        backgroundColor: AppTheme.errorContainer,
        colorText: AppTheme.onErrorContainer,
      );
    }
  }

  void _shareFeedback() {
    final selectedOption = _ratingOptions.firstWhere((o) => o['stars'] == _rating.toInt());
    final ratingText = selectedOption['title'];
    final shareText = '''
📱 *SecondMind* - تقييم التطبيق

⭐ تقييمي: ${_rating.toInt()}/5 ($ratingText)

📥 حمل التطبيق الآن:
https://secondmind.app/download
    ''';
    Share.share(shareText);
  }

  Future<void> _openStore() async {
    const androidUrl = 'https://play.google.com/store/apps/details?id=com.secondmind.app';
    const iosUrl = 'https://apps.apple.com/app/secondmind/id123456789';
    
    try {
      if (await canLaunchUrl(Uri.parse(androidUrl))) {
        await launchUrl(Uri.parse(androidUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      Get.snackbar('خطأ', 'لا يمكن فتح المتجر حالياً');
    }
  }

  Future<void> _skipRating() async {
    Get.back();
    Get.snackbar(
      'تم التخطي',
      'يمكنك تقييم التطبيق لاحقاً من الإعدادات',
      backgroundColor: AppTheme.outlineVariant,
      colorText: AppTheme.onSurface,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedOption = _rating > 0
        ? _ratingOptions.firstWhere((o) => o['stars'] == _rating.toInt())
        : null;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: _buildBody(selectedOption),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('تقييم التطبيق'),
      centerTitle: true,
      backgroundColor: AppTheme.surface.withValues(alpha: 0.95),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.primary),
        onPressed: () => Get.back(),
      ),
      actions: [
        TextButton(
          onPressed: _skipRating,
          child: Text('تخطي', style: AppTheme.labelMd.copyWith(color: AppTheme.outline)),
        ),
      ],
    );
  }

  Widget _buildBody(Map<String, dynamic>? selectedOption) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildStarsSection(),
            const SizedBox(height: 32),
            if (selectedOption != null) _buildFeedbackSection(selectedOption),
            const SizedBox(height: 32),
            _buildSubmitButton(),
            const SizedBox(height: 20),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(Icons.star, size: 45, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Text(
          'ما مدى رضاك عن SecondMind؟',
          style: AppTheme.headlineMd.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'شاركنا رأيك لنساعد في تحسين التطبيق',
          style: AppTheme.bodyMd.copyWith(color: AppTheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildStarsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starValue = index + 1;
            final isSelected = starValue <= _rating;
            final color = isSelected
                ? _ratingOptions.firstWhere((o) => o['stars'] == starValue)['color'] as Color
                : AppTheme.outline;
            return GestureDetector(
              onTap: () => setState(() => _rating = starValue.toDouble()),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  isSelected ? Icons.star : Icons.star_border,
                  size: 48,
                  color: color,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        if (_rating > 0)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _rating > 0 ? 1 : 0,
            child: Column(
              children: [
                Text(
                  _ratingOptions.firstWhere((o) => o['stars'] == _rating.toInt())['emoji'],
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  _ratingOptions.firstWhere((o) => o['stars'] == _rating.toInt())['title'],
                  style: AppTheme.labelLg.copyWith(
                    color: _ratingOptions.firstWhere((o) => o['stars'] == _rating.toInt())['color'] as Color,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFeedbackSection(Map<String, dynamic> selectedOption) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (selectedOption['color'] as Color).withValues(alpha: 0.08),
                  (selectedOption['color'] as Color).withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: (selectedOption['color'] as Color).withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.edit_note, color: selectedOption['color'] as Color),
                    const SizedBox(width: 10),
                    Text(
                      'أخبرنا المزيد (اختياري)',
                      style: AppTheme.labelMd.copyWith(color: selectedOption['color'] as Color),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _feedbackController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'ما الذي أعجبك؟ ما الذي يمكن تحسينه؟',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppTheme.surfaceContainerLow,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitRating,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'إرسال التقييم',
                    style: AppTheme.labelLg.copyWith(fontWeight: FontWeight.w600 ,color: Colors.white, ),
                    
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'تقييمك يساعدنا في تحسين التطبيق وتقديم تجربة أفضل',
      style: AppTheme.labelSm.copyWith(color: AppTheme.outline),
      textAlign: TextAlign.center,
    );
  }
}