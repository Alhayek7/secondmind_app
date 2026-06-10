import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondmind/core/theme/app_theme.dart';
import 'package:secondmind/core/routes/app_routes.dart';
import 'package:secondmind/data/services/sound_service.dart';
import 'package:secondmind/data/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:secondmind/data/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<Offset> _logoSlide;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _loaderFade;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermissions();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    // Logo animations
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Title animation
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOut),
      ),
    );

    // Subtitle animation
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 0.75, curve: Curves.easeOut),
      ),
    );

    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 0.75, curve: Curves.easeOut),
      ),
    );

    // Loader animation
    _loaderFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    // Pulse & glow
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.15, end: 0.35).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    _mainController.forward();

    // ✅ اختبار الأصوات بعد 1.5 ثانية
    Future.delayed(const Duration(milliseconds: 1500), () {
      _testSoundsAndNotifications();
    });

    // ✅ الانتقال إلى الصفحة المناسبة بعد 3.2 ثانية (مرة واحدة فقط)
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        if (AuthService.to.isLoggedIn) {
          Get.offAllNamed(AppRoutes.tasks);
        } else {
          Get.offAllNamed(AppRoutes.login);
        }
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  // ✅ دالة طلب أذونات الإشعارات (داخل الكلاس)
  Future<void> _requestNotificationPermissions() async {
    final status = await Permission.notification.request();

    if (status.isGranted) {
      debugPrint('✅ تم منح إذن الإشعارات');
      await NotificationService.initialize();
    } else if (status.isDenied) {
      debugPrint('❌ تم رفض إذن الإشعارات');
      Get.snackbar(
        'تنبيه',
        'لن تتمكن من استلام الإشعارات. يمكنك تفعيلها من إعدادات الهاتف.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorContainer,
        colorText: Colors.white,
      );
    }
  }

  // ✅ دالة اختبار الأصوات (داخل الكلاس)
  Future<void> _testSoundsAndNotifications() async {
    debugPrint('\n═══════════════════════════════════════════════════════════');
    debugPrint('🎵 تشغيل صوت الترحيب');
    debugPrint('═══════════════════════════════════════════════════════════');

    try {
      await SoundService.playNotificationSound();
      debugPrint('✅ تم تشغيل صوت الترحيب بنجاح');

      await NotificationService.showNotification(
        title: '✅ SecondMind جاهز!',
        body: 'التطبيق يعمل بكامل طاقته 🚀',
        playSound: false,
      );
    } catch (e) {
      debugPrint('❌ خطأ في تشغيل الصوت: $e');
    }
    debugPrint('═══════════════════════════════════════════════════════════\n');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          _buildBackgroundCircles(size),
          AnimatedBuilder(
            animation: _particleAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: _ParticlePainter(
                  progress: _particleAnimation.value,
                  color: AppTheme.primary,
                ),
              );
            },
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlideTransition(
                  position: _logoSlide,
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScale.value * _pulseAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(
                                      alpha: _glowAnimation.value * 0.3),
                                  blurRadius: 30,
                                  spreadRadius: 8,
                                ),
                                BoxShadow(
                                  color: AppTheme.primary.withValues(
                                      alpha: _glowAnimation.value * 0.15),
                                  blurRadius: 60,
                                  spreadRadius: 15,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/icons/icon.png',
                              width: 230,
                              height: 220,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          AppTheme.primary,
                          AppTheme.primary.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        'SecondMind',
                        style: AppTheme.headlineLg.copyWith(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SlideTransition(
                  position: _subtitleSlide,
                  child: FadeTransition(
                    opacity: _subtitleFade,
                    child: Text(
                      'عقلك الثاني الذي لا ينسى',
                      style: AppTheme.bodyMd.copyWith(
                        color: AppTheme.outline,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 70),
                FadeTransition(
                  opacity: _loaderFade,
                  child: _buildLoader(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundCircles(Size size) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -80,
              left: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(
                    alpha: 0.04 + _glowAnimation.value * 0.03,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              right: -60,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(
                    alpha: 0.05 + _glowAnimation.value * 0.03,
                  ),
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.15,
              right: 30,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              bottom: size.height * 0.2,
              left: 20,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: 0.07),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoader() {
    return Column(
      children: [
        SizedBox(
          width: 180,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: null,
                  minHeight: 3,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        FadeTransition(
          opacity: _loaderFade,
          child: Text(
            'جاري التحميل...',
            style: AppTheme.bodyMd.copyWith(
              color: AppTheme.outline.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

// رسام الجسيمات
class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;

  _ParticlePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final particles = [
      _Particle(0.15, 0.3, 3.0, 0.0),
      _Particle(0.8, 0.15, 2.0, 0.2),
      _Particle(0.25, 0.75, 2.5, 0.4),
      _Particle(0.7, 0.65, 3.5, 0.1),
      _Particle(0.5, 0.2, 2.0, 0.6),
      _Particle(0.9, 0.5, 1.5, 0.3),
      _Particle(0.1, 0.55, 2.0, 0.7),
      _Particle(0.6, 0.85, 2.5, 0.5),
    ];

    for (final p in particles) {
      final animProgress = (progress + p.offset) % 1.0;
      final opacity =
          (animProgress < 0.5 ? animProgress * 2 : (1.0 - animProgress) * 2) *
              0.25;

      paint.color = color.withValues(alpha: opacity);

      final dy = p.y * size.height - (animProgress * 40);
      canvas.drawCircle(
        Offset(p.x * size.width, dy),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Particle {
  final double x, y, radius, offset;
  const _Particle(this.x, this.y, this.radius, this.offset);
}