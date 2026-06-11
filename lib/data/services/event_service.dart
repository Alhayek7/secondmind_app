import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:secondmind/data/models/event_model.dart';
import 'package:secondmind/data/services/notification_service.dart';

class EventService {
  static late Box<EventModel> _eventsBox;
  static final RxInt unreadCountNotifier = 0.obs;
  
  static Future<void> init() async {
    _eventsBox = await Hive.openBox<EventModel>('events');
    _updateUnreadCount();
  }
  
  static void _updateUnreadCount() {
    unreadCountNotifier.value = _eventsBox.length;
  }
  
  static Future<void> addEvent({
    required String title,
    required String message,
    required String type,
    String? taskId,
  }) async {
    final event = EventModel(
      id: const Uuid().v4(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      taskId: taskId,
    );
    await _eventsBox.put(event.id, event);
    _updateUnreadCount();
    
    // عرض إشعار فوري
    await NotificationService.showNotification(
      title: title,
      body: message,
      playSound: true,
    );
  }
  
  static List<EventModel> getAllEvents() {
    final events = _eventsBox.values.toList();
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events;
  }
  
  static Future<void> clearAllEvents() async {
    await _eventsBox.clear();
    _updateUnreadCount();
  }
  
  static Future<void> deleteEvent(String id) async {
    await _eventsBox.delete(id);
    _updateUnreadCount();
  }
  
  static Future<void> markAllAsRead() async {
    // يمكن تنفيذ منطق تحديث حالة القراءة هنا
    // حالياً نعيد تعيين العداد فقط
    unreadCountNotifier.value = 0;
  }
  
  static int get eventsCount => _eventsBox.length;
}