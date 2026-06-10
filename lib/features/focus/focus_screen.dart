// lib/features/focus/focus_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:secondmind/core/theme/app_theme.dart';
import 'package:secondmind/data/services/sound_service.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with TickerProviderStateMixin {
  int _timeLeft = 25 * 60;
  int _totalTime = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;
  
  late AnimationController _pulseController;
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentPlayingSound;
  
  double _volume = 0.5;
  bool _isMuted = false;
  
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
  
  // متغيرات النصائح
  Timer? _tipsTimer;
  final List<String> _tips = [
    '💡 أخذ استراحة لمدة 5 دقائق الآن سيعزز تركيزك بنسبة 20% في الساعة القادمة.',
    '💧 شرب الماء يساعد في تحسين التركيز بنسبة 14%.',
    '🧘 الجلوس بوضعية مستقيمة يزيد التركيز بنسبة 15%.',
    '📵 تجنب المشتتات الرقمية يضاعف إنتاجيتك.',
    '📝 تقسيم المهام الكبيرة إلى أجزاء صغيرة يسهل إنجازها.',
    '🎯 حدد هدفاً واحداً لكل جلسة تركيز.',
    '🌿 بيئة العمل المرتبة تزيد الإنتاجية بنسبة 30%.',
    '🎧 الاستماع إلى الموسيقى الهادئة يحسن التركيز.',
    '🕐 قاعدة 20-20-20: كل 20 دقيقة، انظر لشيء على بعد 20 قدم لمدة 20 ثانية.',
    '😴 النوم الكافي يزيد الإنتاجية بنسبة 30%.',
  ];
  String _currentTip = '';
  
  // متغيرات الوقت المخصص
  int _customMinutes = 25;
  final List<int> _presetMinutes = [15, 25, 30, 45, 60];
  
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
    _currentTip = _tips[0];
    _startTipsTimer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerComplete.listen((event) {
      if (_isRunning && _currentPlayingSound != null) {
        _playSound(_selectedSound);
      }
    });
    _audioPlayer.setVolume(_volume);
  }

  Future<void> _playSound(String sound) async {
    try {
      await _audioPlayer.stop();
      final filePath = 'sounds/${_soundFiles[sound]}';
      await _audioPlayer.play(AssetSource(filePath));
      _currentPlayingSound = sound;
      
      if (_isMuted) {
        await _audioPlayer.setVolume(0);
      } else {
        await _audioPlayer.setVolume(_volume);
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
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
  }

  void _startTipsTimer() {
    _tipsTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) {
        final randomIndex = DateTime.now().millisecondsSinceEpoch % _tips.length;
        setState(() {
          _currentTip = _tips[randomIndex];
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tipsTimer?.cancel();
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) {
      _timer?.cancel();
      _stopSound();
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
    SoundService.playFocusEndSound();
    setState(() {
      _isRunning = false;
      _timeLeft = 0;
      _completedSessions++;
      _totalFocusMinutes += (_totalTime ~/ 60);
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

  void _showCustomTimeDialog() {
    int selectedMinutes = _customMinutes;
    
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.timer, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text('تحديد وقت التركيز', style: AppTheme.headlineMd),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('اختر المدة المناسبة للتركيز'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _presetMinutes.map((minutes) {
                return FilterChip(
                  label: Text('$minutes دقيقة'),
                  selected: selectedMinutes == minutes,
                  onSelected: (_) {
                    selectedMinutes = minutes;
                  },
                  selectedColor: AppTheme.primary,
                  labelStyle: TextStyle(
                    color: selectedMinutes == minutes ? Colors.white : AppTheme.onSurface,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'وقت مخصص (دقائق)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        selectedMinutes = int.tryParse(value) ?? 25;
                      }
                    },
                  ),
                ),
              ],
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
              setState(() {
                _customMinutes = selectedMinutes.clamp(1, 180);
                _totalTime = _customMinutes * 60;
                _timeLeft = _totalTime;
              });
              Get.snackbar(
                'تم التغيير',
                'تم ضبط وقت التركيز إلى $_customMinutes دقيقة',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.onPrimary,
            ),
            child: const Text('تطبيق'),
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
      appBar: AppBar(
        title: const Text('التركيز الذهني'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.surface.withValues(alpha: 0.8),
      ),
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
        const SizedBox(width: 24),
        GestureDetector(
          onTap: _showCustomTimeDialog,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppTheme.neumorphicShadow,
            ),
            child: Icon(Icons.timer_outlined, size: 28, color: AppTheme.primary),
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
                Text('الأصوات المحيطة', style: AppTheme.labelMd.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                const Spacer(),
                GestureDetector(
                  onTap: _toggleMute,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, size: 18, color: AppTheme.primary),
                  ),
                ),
                const SizedBox(width: 8),
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
                      Text(_selectedSound, style: AppTheme.labelSm.copyWith(color: AppTheme.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
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
                          ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)), ...AppTheme.neumorphicShadow]
                          : AppTheme.neumorphicShadow,
                      border: isSelected ? null : Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
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
                                color: isSelected ? Colors.white.withValues(alpha: 0.2) : AppTheme.primaryContainer.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(_soundIcons[sound], size: 26, color: isSelected ? Colors.white : AppTheme.primary),
                            ),
                            if (isPlaying)
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.play_arrow, size: 24, color: Colors.white),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(sound, style: AppTheme.labelSm.copyWith(
                          color: isSelected ? Colors.white : AppTheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 11,
                        )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Icon(Icons.volume_down, size: 14, color: AppTheme.outline),
                Expanded(
                  child: Slider(
                    value: _volume,
                    onChanged: _changeVolume,
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
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.neumorphicShadow),
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
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.neumorphicShadow),
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
              _currentTip,
              style: AppTheme.bodyMd.copyWith(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}