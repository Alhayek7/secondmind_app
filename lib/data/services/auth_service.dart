import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();
  
  final RxBool _isLoggedIn = false.obs;
  bool get isLoggedIn => _isLoggedIn.value;
  
  late Box _settingsBox;
  
  Future<AuthService> init() async {
    _settingsBox = Hive.box('settings');
    final savedLogin = _settingsBox.get('isLoggedIn', defaultValue: false);
    _isLoggedIn.value = savedLogin;
    return this;
  }
  
  Future<void> login() async {
    _isLoggedIn.value = true;
    await _settingsBox.put('isLoggedIn', true);
  }
  
  Future<void> logout() async {
    _isLoggedIn.value = false;
    await _settingsBox.put('isLoggedIn', false);
    Get.offAllNamed('/login');
  }
}