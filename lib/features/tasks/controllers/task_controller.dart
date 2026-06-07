import 'package:get/get.dart';
import 'package:secondmind/data/models/task_model.dart';
import 'package:secondmind/data/services/storage_service.dart';

enum TaskFilter { all, inProgress, completed }

extension TaskFilterExtension on TaskFilter {
  String get displayName {
    switch (this) {
      case TaskFilter.all: return 'الكل';
      case TaskFilter.inProgress: return 'قيد التنفيذ';
      case TaskFilter.completed: return 'مكتمل';
    }
  }
}

class TaskController extends GetxController {
  var tasks = <TaskModel>[].obs;
  var selectedFilter = TaskFilter.all.obs;
  
  List<TaskFilter> get filters => TaskFilter.values;
  
  List<TaskModel> get filteredTasks {
    switch (selectedFilter.value) {
      case TaskFilter.all: return tasks;
      case TaskFilter.inProgress: return tasks.where((t) => t.status != TaskStatus.completed).toList();
      case TaskFilter.completed: return tasks.where((t) => t.status == TaskStatus.completed).toList();
    }
  }
  
  // ============ إحصائيات حقيقية ============
  
  int get totalTasks => tasks.length;
  
  int get completedTasks => tasks.where((t) => t.status == TaskStatus.completed).length;
  
  int get pendingTasks => totalTasks - completedTasks;
  
  int get completionRate => totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0;
  
  int get urgentTasks => tasks.where((t) => t.priority == TaskPriority.urgent).length;
  
  int get totalWorkMinutes => tasks.fold(0, (sum, task) => sum + (task.timeSpent ?? 0));
  
  double get totalWorkHours => (totalWorkMinutes / 60);
  
  double get focusRate {
    if (completedTasks == 0) return 0.0;
    final completedOnTime = tasks.where((t) => 
      t.status == TaskStatus.completed && 
      t.dueDate != null && 
      t.dueDate!.isAfter(DateTime.now())
    ).length;
    return (completedOnTime / completedTasks * 100);
  }
  
  int get streakDays {
    if (completedTasks == 0) return 0;
    int streak = 0;
    var currentDate = DateTime.now();
    while (true) {
      final hasTaskOnDate = tasks.any((t) => 
        t.completedAt != null &&
        t.completedAt!.year == currentDate.year &&
        t.completedAt!.month == currentDate.month &&
        t.completedAt!.day == currentDate.day
      );
      if (hasTaskOnDate) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
  
  Map<TaskCategory, int> get tasksByCategory {
    final Map<TaskCategory, int> stats = {};
    for (var category in TaskCategory.values) {
      stats[category] = tasks.where((t) => t.category == category).length;
    }
    return stats;
  }
  
  Map<TaskCategory, int> get completedTasksByCategory {
    final Map<TaskCategory, int> stats = {};
    for (var category in TaskCategory.values) {
      stats[category] = tasks.where((t) => t.status == TaskStatus.completed && t.category == category).length;
    }
    return stats;
  }
  
  TaskCategory get topCategory {
    if (tasks.isEmpty) return TaskCategory.other;
    return tasksByCategory.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
  
  List<int> get weeklyTasks {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day - now.weekday + 1);
    final List<int> weekly = List.filled(7, 0);
    for (var task in tasks) {
      if (task.createdAt.isAfter(startOfWeek)) {
        final dayIndex = task.createdAt.weekday - 1;
        weekly[dayIndex]++;
      }
    }
    return weekly;
  }
  
  List<int> get weeklyCompletedTasks {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day - now.weekday + 1);
    final List<int> weekly = List.filled(7, 0);
    for (var task in tasks) {
      if (task.status == TaskStatus.completed && 
          task.completedAt != null && 
          task.completedAt!.isAfter(startOfWeek)) {
        final dayIndex = task.completedAt!.weekday - 1;
        weekly[dayIndex]++;
      }
    }
    return weekly;
  }

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }
  
  void loadTasks() {
    tasks.value = StorageService.getAllTasks();
  }
  
  Future<void> addTask(TaskModel task) async {
    await StorageService.saveTask(task);
    loadTasks();  // بدون await
  }
  
  Future<void> updateTask(TaskModel task) async {
    await StorageService.updateTask(task);
    loadTasks();  // بدون await
  }
  
  Future<void> updateTaskStatus(String taskId, TaskStatus currentStatus) async {
    final task = tasks.firstWhere((t) => t.id == taskId);
    TaskStatus newStatus;
    DateTime? completedAt = task.completedAt;
    int? timeSpent = task.timeSpent;
    
    switch (currentStatus) {
      case TaskStatus.new_:
        newStatus = TaskStatus.inProgress;
        break;
      case TaskStatus.inProgress:
        newStatus = TaskStatus.completed;
        completedAt = DateTime.now();
        timeSpent = (task.timeSpent ?? 0) + 30;
        break;
      case TaskStatus.completed:
        newStatus = TaskStatus.new_;
        completedAt = null;
        break;
    }
    
    final updatedTask = task.copyWith(
      status: newStatus,
      completedAt: completedAt,
      timeSpent: timeSpent,
    );
    await updateTask(updatedTask);
  }
  
  Future<void> deleteTask(String taskId) async {
    await StorageService.deleteTask(taskId);
    loadTasks();  // بدون await
  }
}