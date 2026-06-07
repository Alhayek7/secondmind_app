// lib/core/middleware/auth_middleware.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondmind/core/routes/app_routes.dart';
import 'package:secondmind/data/services/auth_service.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 0;
  
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    
    // الصفحات التي لا تحتاج مصادقة
    final publicRoutes = [
      AppRoutes.splash,
      AppRoutes.login,
      AppRoutes.signup,
    ];
    
    if (authService.isLoggedIn == false && !publicRoutes.contains(route)) {
      return const RouteSettings(name: AppRoutes.login);
    }
    
    return null;
  }
}