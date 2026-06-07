// lib/features/focus/focus_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:secondmind/core/theme/app_theme.dart';
import 'package:secondmind/core/routes/app_routes.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with TickerProviderStateMixin {
  // Timer variables
  int _timeLeft = 25 * 60;
  final int _totalTime = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;
  
  // Animation controllers
  late AnimationController _pulseController;
  
  // Audio players
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioPlayer? _currentPlayer;
  String? _currentPlayingSound;
  
  // Volume
  double _volume = 0.5;
  bool _isMuted = false;
  
  // Selected sound
  String _selectedSound = 'Rain';
  final List<String> _sounds = ['Rain', 'Forest', 'Noise', 'Lo-fi', 'Ocean', 'Fire'];
  final Map<String, IconData> _soundIcons = {
    'Rain': Icons.water_drop,
    'Forest': Icons.forest,
    'Noise': Icons.air,
    'Lo-fi': Icons.headphones,
    'Ocean': Icons.waves,
    'Fire': Icons.whatshot,
  };
  final Map<String, String> _soundFiles = {
    'Rain': 'rain.mp3',
    'Forest': 'forest.mp3',
    'Noise': 'noise.mp3',
    'Lo-fi': 'lofi.mp3',
    'Ocean': 'ocean.mp3',
    'Fire': 'fire.mp3',
  };
  
  // Focus stats
  int _totalFocusMinutes = 0;
  int _completedSessions = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerComplete.listen((event) {
      // إعادة تشغيل الصوت تلقائياً عند الانتهاء (للتكرار)
      if (_isRunning && _currentPlayingSound != null) {
        _playSound(_selectedSound);
      }
    });
    
    _audioPlayer.setVolume(_volume);
  }

  Future<void> _playSound(String sound) async {
    try {
      // إيقاف الصوت الحالي
      await _audioPlayer.stop();
      
      // تشغيل الصوت الجديد من الملف المحلي
      final filePath = 'sounds/${_soundFiles[sound]}';
      await _audioPlayer.play(AssetSource(filePath));
      _currentPlayingSound = sound;
      
      // تحديث حالة mute
      if (_isMuted) {
        await _audioPlayer.setVolume(0);
      } else {
        await _audioPlayer.setVolume(_volume);
      }
      
      // عرض رسالة توضيحية
      Get.snackbar(
        'تشغيل الصوت',
        'جاري تشغيل صوت $sound',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(milliseconds: 800),
        backgroundColor: AppTheme.primaryContainer.withValues(alpha: 0.9),
        colorText: AppTheme.onPrimaryContainer,
      );
    } catch (e) {
      debugPrint('Error playing sound: $e');
      Get.snackbar(
        'تنبيه',
        'لم يتم العثور على ملف الصوت، يرجى إضافته إلى مجلد assets/sounds/',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorContainer,
        colorText: AppTheme.onErrorContainer,
      );
    }
  }

  Future<void> _stopSound() async {
    await _audioPlayer.stop();
    _currentPlayingSound = null;
  }

  void _changeVolume(double value) {
    setState(() {
      _volume = value;
      if (!_isMuted) {
        _audioPlayer.setVolume(value);
      }
    });
    
    Get.snackbar(
      'مستوى الصوت',
      'تم تغيير مستوى الصوت إلى ${(value * 100).round()}%',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(milliseconds: 800),
      backgroundColor: AppTheme.primaryContainer,
      colorText: AppTheme.onPrimaryContainer,
    );
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      if (_isMuted) {
        _audioPlayer.setVolume(0);
      } else {
        _audioPlayer.setVolume(_volume);
      }
    });
    
    Get.snackbar(
      _isMuted ? 'تم كتم الصوت' : 'تم إلغاء كتم الصوت',
      _isMuted ? 'الأصوات المحيطة مكتومة حالياً' : 'تم استعادة مستوى الصوت',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      if (_timeLeft == 0) _resetTimer();
      _isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timeLeft > 0) {
          setState(() => _timeLeft--);
        } else {
          _timerComplete();
        }
      });
      
      // تشغيل الصوت المحدد عند بدء الجلسة
      if (!_isMuted) {
        _playSound(_selectedSound);
      }
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    _stopSound();
    setState(() {
      _timeLeft = _totalTime;
      _isRunning = false;
    });
  }

  void _timerComplete() {
    _timer?.cancel();
    _stopSound();
    setState(() {
      _isRunning = false;
      _timeLeft = 0;
      _completedSessions++;
      _totalFocusMinutes += 25;
    });
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('انتهى وقت التركيز!'),
        content: const Text('أحسنت! خذ استراحة لمدة 5 دقائق.'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _resetTimer();
            },
            child: Text('بدء جلسة جديدة', style: AppTheme.labelMd.copyWith(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatTotalTime(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (_timeLeft / _totalTime);
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildTimerSection(progress),
              const SizedBox(height: 24),
              _buildControlButtons(),
              const SizedBox(height: 24),
              _buildAmbientSounds(),
              const SizedBox(height: 24),
              _buildStatsSection(),
              const SizedBox(height: 20),
              _buildSmartTip(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('التركيز الذهني'),
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppTheme.surface.withValues(alpha: 0.8),
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildTimerSection(double progress) {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: AppTheme.neumorphicShadow,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 230,
                  height: 230,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: AppTheme.surfaceContainerHighest,
                    color: AppTheme.primary,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(_timeLeft),
                      style: AppTheme.displayLg.copyWith(fontSize: 42, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text('دقائق متبقية', style: AppTheme.labelMd.copyWith(color: AppTheme.outline)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _startTimer,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppTheme.neumorphicShadow,
            ),
            child: Icon(_isRunning ? Icons.pause : Icons.play_arrow, size: 36, color: AppTheme.primary),
          ),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: _resetTimer,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppTheme.neumorphicShadow,
            ),
            child: Icon(Icons.refresh, size: 28, color: AppTheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildAmbientSounds() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم مع أيقونة
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
                  child: Icon(Icons.music_note, size: 18, color: AppTheme.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  'الأصوات المحيطة',
                  style: AppTheme.labelMd.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                // زر كتم الصوت
                GestureDetector(
                  onTap: _toggleMute,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      size: 18,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // مؤشر الصوت المحدد
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.volume_up, size: 12, color: AppTheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        _selectedSound,
                        style: AppTheme.labelSm.copyWith(color: AppTheme.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          
          // شبكة الأصوات المحيطة
          SizedBox(
            height: 95,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _sounds.length,
              itemBuilder: (context, index) {
                final sound = _sounds[index];
                final isSelected = _selectedSound == sound;
                final isPlaying = _currentPlayingSound == sound && _isRunning;
                
                return GestureDetector(
                  onTap: () async {
                    setState(() => _selectedSound = sound);
                    if (_isRunning && !_isMuted) {
                      await _playSound(sound);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 14),
                    width: 80,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppTheme.primaryGradient : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                              ...AppTheme.neumorphicShadow,
                            ]
                          : AppTheme.neumorphicShadow,
                      border: isSelected
                          ? null
                          : Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : AppTheme.primaryContainer.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                _soundIcons[sound],
                                size: 26,
                                color: isSelected ? Colors.white : AppTheme.primary,
                              ),
                            ),
                            if (isPlaying)
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          sound,
                          style: AppTheme.labelSm.copyWith(
                            color: isSelected ? Colors.white : AppTheme.onSurfaceVariant,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 8),
          
          // شريط التحكم في الصوت
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Icon(Icons.volume_down, size: 14, color: AppTheme.outline),
                Expanded(
                  child: Slider(
                    value: _volume,
                    onChanged: (value) {
                      _changeVolume(value);
                    },
                    activeColor: AppTheme.primary,
                    inactiveColor: AppTheme.outlineVariant,
                    min: 0,
                    max: 1,
                  ),
                ),
                Icon(Icons.volume_up, size: 14, color: AppTheme.outline),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.neumorphicShadow,
            ),
            child: Column(
              children: [
                Text(_formatTotalTime(_totalFocusMinutes), style: AppTheme.headlineMd.copyWith(color: AppTheme.primary)),
                const SizedBox(height: 4),
                Text('وقت التركيز اليوم', style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.neumorphicShadow,
            ),
            child: Column(
              children: [
                Text('$_completedSessions', style: AppTheme.headlineMd.copyWith(color: AppTheme.primary)),
                const SizedBox(height: 4),
                Text('جلسات مكتملة', style: AppTheme.labelSm.copyWith(color: AppTheme.outline)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmartTip() {
    final List<String> tips = [
      '💡 أخذ استراحة لمدة 5 دقائق الآن سيعزز تركيزك بنسبة 20% في الساعة القادمة.',
      '💧 شرب الماء يساعد في تحسين التركيز بنسبة 14%.',
      '🧘 الجلوس بوضعية مستقيمة يزيد التركيز بنسبة 15%.',
      '📵 تجنب المشتتات الرقمية يضاعف إنتاجيتك.',
      '📝 تقسيم المهام الكبيرة إلى أجزاء صغيرة يسهل إنجازها.',
      '🎯 حدد هدفاً واحداً لكل جلسة تركيز.',
      '🌿 بيئة العمل المرتبة تزيد الإنتاجية بنسبة 30%.',
    ];
    
    final randomTip = tips[DateTime.now().millisecondsSinceEpoch % tips.length];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryContainer.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb, color: AppTheme.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              randomTip,
              style: AppTheme.bodyMd.copyWith(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -4), blurRadius: 20)],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.dashboard_customize, 'المهام', AppRoutes.tasks),
                _buildNavItem(Icons.bar_chart_outlined, 'الإحصائيات', AppRoutes.stats),
                _buildNavItem(Icons.timer, 'تركيز', '/focus'),
                _buildNavItem(Icons.settings_outlined, 'الإعدادات', AppRoutes.settings),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, String route) {
    final isSelected = route == '/focus';
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryContainer.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? AppTheme.primary : AppTheme.outline, size: 22),
            const SizedBox(height: 2),
            Text(label, style: AppTheme.labelSm.copyWith(color: isSelected ? AppTheme.primary : AppTheme.outline, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}