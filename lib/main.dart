// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:secondmind/core/theme/app_theme.dart';
import 'package:secondmind/core/routes/app_routes.dart';
import 'package:secondmind/data/models/task_model.dart';
import 'package:secondmind/data/models/event_model.dart';
import 'package:secondmind/data/services/storage_service.dart';
import 'package:secondmind/data/services/auth_service.dart';
import 'package:secondmind/features/tasks/controllers/task_controller.dart';
import 'package:secondmind/data/services/notification_service.dart';
import 'package:secondmind/data/services/event_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  // ✅ تسجيل جميع الـ adapters
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(TaskStatusAdapter());
  Hive.registerAdapter(TaskPriorityAdapter());
  Hive.registerAdapter(TaskCategoryAdapter());
  Hive.registerAdapter(AttendanceTypeAdapter());
  Hive.registerAdapter(EventModelAdapter()); // ✅ أضف هذا
  
  await Hive.openBox<TaskModel>('tasks');
  await Hive.openBox('settings');
  await Hive.openBox<EventModel>('events');
  
  await EventService.init();
  await StorageService.init();
  await Get.put(AuthService()).init();
  Get.put(TaskController());
  
  await NotificationService.initialize();
  
  runApp(const SecondMindApp());
}

class SecondMindApp extends StatelessWidget {
  const SecondMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SecondMind',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      locale: const Locale('ar', 'SA'),
      fallbackLocale: const Locale('ar', 'SA'),
    );
  }
}