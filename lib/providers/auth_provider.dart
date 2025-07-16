// providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  String? _userId;
  String? _userName;
  String? _userEmail;
  String? _token;
  bool _isAuthenticated = false;
  final AuthService _authService = AuthService();

  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    _userName = prefs.getString('userName');
    _userEmail = prefs.getString('userEmail');
    _token = prefs.getString('token');
    _isAuthenticated = _userId != null && _token != null;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final data = await _authService.login(email, password);
    _userId = data['userId']?.toString() ?? data['id']?.toString();
    _userName = data['username'] ?? data['name'] ?? email.split('@').first;
    _userEmail = data['email'] ?? email;
    _token = data['token'];
    _isAuthenticated = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', _userId ?? '');
    await prefs.setString('userName', _userName ?? '');
    await prefs.setString('userEmail', _userEmail ?? '');
    await prefs.setString('token', _token ?? '');
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    final data = await _authService.register(name, email, password);
    // Optionally auto-login after registration
    await login(email, password);
  }

  Future<void> logout() async {
    _userId = null;
    _userName = null;
    _userEmail = null;
    _token = null;
    _isAuthenticated = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('token');
    notifyListeners();
  }

  Future<void> forgotPassword(String email) async {
    await _authService.forgotPassword(email);
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await _authService.resetPassword(token, newPassword);
  }
}
