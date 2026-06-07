import 'package:hive_flutter/hive_flutter.dart';
import 'package:secondmind/data/models/task_model.dart';

class StorageService {
  static late Box<TaskModel> _tasksBox;
  static late Box _settingsBox;
  
  static Future<void> init() async {
    _tasksBox = await Hive.openBox<TaskModel>('tasks');
    _settingsBox = await Hive.openBox('settings');
  }
  
  // Task methods
  List<TaskModel> getAllTasks() {
    return _tasksBox.values.toList();
  }
  
  Future<void> saveTask(TaskModel task) async {
    await _tasksBox.put(task.id, task);
  }
  
  Future<void> updateTask(TaskModel task) async {
    await _tasksBox.put(task.id, task);
  }
  
  Future<void> deleteTask(String taskId) async {
    await _tasksBox.delete(taskId);
  }
  
  TaskModel? getTask(String taskId) {
    return _tasksBox.get(taskId);
  }
  
  // Settings methods
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }
  
  dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }
}