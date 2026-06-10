// lib/data/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:math';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static int _generateId() {
    return Random().nextInt(10000) + 1;
  }
  
  static Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(settings);
  }
  
  // إشعار فوري (id اختياري)
  static Future<void> showNotification({
    int? id,
    required String title,
    required String body,
    String? payload,
    bool playSound = true,
  }) async {
    final notificationId = id ?? _generateId();
    
    final androidDetails = AndroidNotificationDetails(
      'task_channel',
      'تذكيرات المهام',
      channelDescription: 'إشعارات لتذكيرك بمهامك',
      importance: Importance.high,
      priority: Priority.high,
      playSound: playSound,
      sound: playSound ? const RawResourceAndroidNotificationSound('notification') : null,
    );
    
    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );
    
    await _notifications.show(notificationId, title, body, details, payload: payload);
  }
  
  // إشعار مجدول للمهمة
  static Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );
    
    final androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'تذكيرات المهام',
      channelDescription: 'تذكير بالمهام المستحقة',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    
    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );
    
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTZ,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }
  
  // إشعار إكمال مهمة
  static Future<void> showTaskCompleteNotification(String taskTitle) async {
    final id = _generateId();
    
    final androidDetails = AndroidNotificationDetails(
      'complete_channel',
      'إكمال المهام',
      channelDescription: 'تهانينا على إكمال المهمة',
      importance: Importance.low,
      priority: Priority.low,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('task_complete'),
    );
    
    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );
    
    await _notifications.show(
      id,
      '🎉 مكتمل!',
      'تم إكمال مهمة: $taskTitle',
      details,
    );
  }
  
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
  
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}