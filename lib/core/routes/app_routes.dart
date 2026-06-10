// lib/core/routes/app_routes.dart
import 'package:get/get.dart';
import 'package:secondmind/core/middleware/auth_middleware.dart';
import 'package:secondmind/features/splash/splash_screen.dart';
import 'package:secondmind/features/auth/login_screen.dart';
import 'package:secondmind/features/auth/signup_screen.dart';
import 'package:secondmind/features/tasks/tasks_screen.dart';
import 'package:secondmind/features/add_task/add_task_screen.dart';
import 'package:secondmind/features/settings/settings_screen.dart';
import 'package:secondmind/features/stats/stats_screen.dart';
import 'package:secondmind/features/notifications/notifications_screen.dart';
import 'package:secondmind/features/profile/profile_screen.dart';
import 'package:secondmind/features/qr_scanner/qr_scanner_screen.dart';
import 'package:secondmind/features/legal/terms_screen.dart';
import 'package:secondmind/features/legal/privacy_policy_screen.dart';
import 'package:secondmind/features/focus/focus_screen.dart';
import 'package:secondmind/features/tasks/task_details_screen.dart';
import 'package:secondmind/features/rate/rate_app_screen.dart';
import 'package:secondmind/features/calendar/calendar_screen.dart';


class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String tasks = '/tasks';
  static const String addTask = '/add-task';
  static const String settings = '/settings';
  static const String stats = '/stats';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String qrScanner = '/qr-scanner';
  static const String terms = '/terms';
  static const String privacy = '/privacy';
  static const String focus = '/focus';
  static const String taskDetails = '/task-details';
static const String rate = '/rate';
  static const String calendar = '/calendar';


  static List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: signup, page: () => const SignupScreen()),
    GetPage(name: tasks, page: () => TasksScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: addTask, page: () => const AddTaskScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: settings, page: () => const SettingsScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: stats, page: () => const StatsScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: notifications, page: () => const NotificationsScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: profile, page: () => const ProfileScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: qrScanner, page: () => const QRScannerScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: terms, page: () => const TermsScreen(isPrivacy: false)),
    GetPage(name: privacy, page: () => const PrivacyPolicyScreen()),
    GetPage(name: focus, page: () => const FocusScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: taskDetails, page: () => TaskDetailsScreen(task: Get.arguments['task']), middlewares: [AuthMiddleware()]),
    GetPage(name: rate, page: () => const RateAppScreen()),
        GetPage(name: calendar, page: () => const CalendarScreen(), middlewares: [AuthMiddleware()]),


  ];
}