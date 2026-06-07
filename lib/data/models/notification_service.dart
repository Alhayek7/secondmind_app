// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notifications = 
//       FlutterLocalNotificationsPlugin();
  
//   static Future<void> initialize() async {
//     tz.initializeTimeZones();
    
//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
    
//     const DarwinInitializationSettings iosSettings =
//         DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
    
//     const InitializationSettings settings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
    
//     await _notifications.initialize(settings);
//   }
  
//   static Future<void> showNotification({
//     required int id,
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'task_channel',
//       'تذكيرات المهام',
//       channelDescription: 'إشعارات لتذكيرك بمهامك',
//       importance: Importance.high,
//       priority: Priority.high,
//     );
    
//     const NotificationDetails details = NotificationDetails(
//       android: androidDetails,
//     );
    
//     await _notifications.show(id, title, body, details, payload: payload);
//   }
  
//   static Future<void> scheduleNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledTime,
//     String? payload,
//   }) async {
//     final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
//       scheduledTime,
//       tz.local,
//     );
    
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'task_channel',
//       'تذكيرات المهام',
//       channelDescription: 'إشعارات لتذكيرك بمهامك',
//       importance: Importance.high,
//       priority: Priority.high,
//     );
    
//     const NotificationDetails details = NotificationDetails(
//       android: androidDetails,
//     );
    
//     await _notifications.zonedSchedule(
//       id,
//       title,
//       body,
//       scheduledTZ,
//       details,
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       payload: payload,
//     );
//   }
  
//   static Future<void> cancelNotification(int id) async {
//     await _notifications.cancel(id);
//   }
  
//   static Future<void> cancelAllNotifications() async {
//     await _notifications.cancelAll();
//   }
// }