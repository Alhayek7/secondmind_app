// lib/data/services/auth_service.dart
import 'package:get/get.dart';
import 'package:secondmind/core/routes/app_routes.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();
  
  final RxBool _isLoggedIn = false.obs;
  
  bool get isLoggedIn => _isLoggedIn.value;
  
  Future<AuthService> init() async {
    // التحقق من وجود جلسة سابقة (يمكن تخزينها في SharedPreferences)
    _isLoggedIn.value = false; // مؤقتاً
    return this;
  }
  
  void login() {
    _isLoggedIn.value = true;
  }
  
  void logout() {
    _isLoggedIn.value = false;
    Get.offAllNamed(AppRoutes.login);
  }
  
  Future<bool> checkAuth() async {
    if (!isLoggedIn) {
      await Get.toNamed(AppRoutes.login);
      return false;
    }
    return true;
  }
}