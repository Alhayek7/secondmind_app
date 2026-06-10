import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:secondmind/data/models/event_model.dart';
import 'package:secondmind/data/services/notification_service.dart';

class EventService {
  static late Box<EventModel> _eventsBox;
  
  static Future<void> init() async {
    _eventsBox = await Hive.openBox<EventModel>('events');
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
  }
  
  static Future<void> deleteEvent(String id) async {
    await _eventsBox.delete(id);
  }
  
  static int get eventsCount => _eventsBox.length;
}