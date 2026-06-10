// lib/data/services/sound_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();
  static final AudioPlayer _backgroundPlayer = AudioPlayer();
  
// صوت الإشعار (قصير أيضاً)
static Future<void> playNotificationSound() async {
  try {
    await _player.play(AssetSource('sounds/notification.mp3'));
    debugPrint('🔊 تم تشغيل صوت الإشعار');
    
    Future.delayed(const Duration(milliseconds: 2000), () async {
      await _player.stop();
    });
  } catch (e) {
    debugPrint('❌ خطأ في تشغيل صوت الإشعار: $e');
  }
}

// صوت إكمال المهمة
static Future<void> playTaskCompleteSound() async {
  try {
    await _player.play(AssetSource('sounds/task_complete.mp3'));
    debugPrint('🔊 تم تشغيل صوت إكمال المهمة');
    
    Future.delayed(const Duration(milliseconds: 2500), () async {
      await _player.stop();
    });
  } catch (e) {
    debugPrint('❌ خطأ في تشغيل صوت الإكمال: $e');
  }
}
  
  // تشغيل صوت بدء التركيز

static Future<void> playFocusStartSound() async {
  try {
    await _player.play(AssetSource('sounds/focus_start.mp3'));
    debugPrint('🔊 تم تشغيل صوت بدء التركيز');
    
    // ✅ إيقاف الصوت تلقائياً بعد 2.5 ثانية
    Future.delayed(const Duration(milliseconds: 2500), () async {
      await _player.stop();
      debugPrint('🔇 تم إيقاف صوت بدء التركيز (بعد 2.5 ثانية)');
    });
  } catch (e) {
    debugPrint('❌ خطأ في تشغيل صوت بدء التركيز: $e');
  }
}
  
  // تشغيل صوت انتهاء التركيز
  static Future<void> playFocusEndSound() async {
    try {
      await _player.play(AssetSource('sounds/focus_end.mp3'));
    } catch (e) {
      debugPrint('❌ خطأ في تشغيل صوت انتهاء التركيز: $e');
    }
  }
  
  // تشغيل صوت خلفية للتركيز (مع تكرار)
  static Future<void> playBackgroundSound(String soundName) async {
    try {
      await _backgroundPlayer.stop();
      await _backgroundPlayer.play(AssetSource('sounds/$soundName.mp3'));
      // ✅ الطريقة الصحيحة للتكرار في الإصدار الجديد
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      debugPrint('❌ خطأ في تشغيل الصوت الخلفي: $e');
    }
  }
  
  // إيقاف الصوت الخلفي
  static Future<void> stopBackgroundSound() async {
    await _backgroundPlayer.stop();
  }
  
  // تغيير مستوى الصوت
  static Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
    await _backgroundPlayer.setVolume(volume);
  }
  
  // إيقاف جميع الأصوات
  static Future<void> stopAllSounds() async {
    await _player.stop();
    await _backgroundPlayer.stop();
  }
  
  static void dispose() {
    _player.dispose();
    _backgroundPlayer.dispose();
  }
}