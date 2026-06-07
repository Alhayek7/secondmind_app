import 'package:hive_flutter/hive_flutter.dart';
import 'package:secondmind/data/models/task_model.dart';

class StorageService {
  static late Box<TaskModel> _tasksBox;
  
  static Future<void> init() async {
    _tasksBox = await Hive.openBox<TaskModel>('tasks');
  }
  
  static List<TaskModel> getAllTasks() {
    return _tasksBox.values.toList();
  }
  
static Future<void> saveTask(TaskModel task) async {
  print('💾 حفظ المهمة: ${task.title} (${task.id})');
  await _tasksBox.put(task.id, task);
  print('💾 تم الحفظ، عدد المهام: ${_tasksBox.length}');
  print('💾 جميع المهام: ${_tasksBox.values.map((t) => t.title).toList()}');
}
  static Future<void> updateTask(TaskModel task) async {
    await _tasksBox.put(task.id, task);
  }
  
  static Future<void> deleteTask(String taskId) async {
    await _tasksBox.delete(taskId);
  }
  
  static TaskModel? getTask(String taskId) {
    return _tasksBox.get(taskId);
  }
  
  static Future<void> clearAllTasks() async {
    await _tasksBox.clear();
  }
}
