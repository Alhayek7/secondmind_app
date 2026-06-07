// lib/features/focus/focus_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondmind/core/theme/app_theme.dart';
import 'package:secondmind/core/routes/app_routes.dart';
import 'package:secondmind/features/tasks/controllers/task_controller.dart';


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
  
  // Selected sound
  String _selectedSound = 'ضوضاء';
  final List<String> _sounds = ['ضوضاء', 'مطر', 'غابة', 'تأمل'];
  final Map<String, IconData> _soundIcons = {
    'ضوضاء': Icons.waves,
    'مطر': Icons.water_drop,
    'غابة': Icons.forest,
    'تأمل': Icons.self_improvement,
  };
  
  // Focus stats
  int _totalFocusMinutes = 260;
  int _completedSessions = 6;

@override
void initState() {
  super.initState();
  _pulseController = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat(reverse: true);
  
  // تحميل الإحصائيات من TaskController
  final taskController = Get.find<TaskController>();
  _totalFocusMinutes = taskController.totalWorkMinutes;
  _completedSessions = taskController.completedTasks;
}

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
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
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = _totalTime;
      _isRunning = false;
    });
  }

  void _timerComplete() {
    _timer?.cancel();
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
    );
  }

// استبدل دالة _buildAppBar بهذا:

PreferredSizeWidget _buildAppBar() {
  return AppBar(
    title: const Text('التركيز الذهني'),
    centerTitle: true,
    elevation: 0,
    backgroundColor: AppTheme.surface.withValues(alpha: 0.8),
    automaticallyImplyLeading: false,
    // تم إزالة actions بالكامل
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
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedSound = sound);
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
        
        // شريط تقدم للصوت
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Icon(Icons.volume_down, size: 14, color: AppTheme.outline),
              Expanded(
                child: Slider(
                  value: 0.7,
                  onChanged: (value) {},
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
    'أخذ استراحة لمدة 5 دقائق الآن سيعزز تركيزك بنسبة 20% في الساعة القادمة.',
    'شرب الماء يساعد في تحسين التركيز بنسبة 14%.',
    'الجلوس بوضعية مستقيمة يزيد التركيز بنسبة 15%.',
    'تجنب المشتتات الرقمية يضاعف إنتاجيتك.',
    'تقسيم المهام الكبيرة إلى أجزاء صغيرة يسهل إنجازها.',
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