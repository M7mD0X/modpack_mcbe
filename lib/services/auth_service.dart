import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/auth_user.dart';
import '../models/api_types.dart';
import 'api_service.dart';

/// Authentication service handling login, signup, verification.
class AuthService with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _baseUrl = 'https://mcbe-modpack-api.example.com';

  AuthUser? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  AuthUser? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;

  AuthService() {
    _loadFromStorage();
  }

  // ─── Storage ─────────────────────────────────────────────────────────

  Future<void> _loadFromStorage() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      final userJson = await _storage.read(key: _userKey);

      if (token != null && userJson != null) {
        _token = token;
        _user = AuthUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (_) {
      // Storage error - user needs to re-authenticate
      await clearAuth();
    }
  }

  Future<void> _saveToStorage() async {
    try {
      if (_token != null) {
        await _storage.write(key: _tokenKey, value: _token);
      }
      if (_user != null) {
        await _storage.write(key: _userKey, value: jsonEncode(_user!.toJson()));
      }
    } catch (_) {
      debugPrint('Failed to save auth state to secure storage');
    }
  }

  Future<void> clearAuth() async {
    _user = null;
    _token = null;
    _error = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
    notifyListeners();
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ─── Auth Methods ────────────────────────────────────────────────────

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse('$_baseUrl/api/auth/login');

      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({
              'email': email.trim().toLowerCase(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = AuthResultData.fromJson(json);
        _user = AuthUser(
          id: result.id,
          username: result.username,
          email: result.email,
          emailVerified: result.emailVerified,
        );
        _token = json['token']?.toString() ?? json['accessToken']?.toString();
        await _saveToStorage();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = json['message']?.toString() ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e is ApiException ? e.message : 'Network error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register a new account
  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse('$_baseUrl/api/auth/register');

      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({
              'username': username.trim(),
              'email': email.trim().toLowerCase(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Some APIs auto-login after registration
        final result = AuthResultData.fromJson(json);
        _user = AuthUser(
          id: result.id,
          username: result.username,
          email: result.email,
          emailVerified: false,
        );
        _token = json['token']?.toString() ?? json['accessToken']?.toString();
        if (_token != null) {
          await _saveToStorage();
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = json['message']?.toString() ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e is ApiException ? e.message : 'Network error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify email with OTP code
  Future<bool> verifyEmail(String email, String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse('$_baseUrl/api/auth/verify-email');

      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({
              'email': email.trim().toLowerCase(),
              'code': code.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        if (_user != null) {
          _user = _user!.copyWith(emailVerified: true);
          await _saveToStorage();
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = json['message']?.toString() ?? 'Verification failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e is ApiException ? e.message : 'Network error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Resend verification email
  Future<bool> resendVerification(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse('$_baseUrl/api/auth/resend-verification');

      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({
              'email': email.trim().toLowerCase(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        _error = json['message']?.toString() ?? 'Failed to resend verification';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout and clear stored credentials
  Future<void> logout() async {
    await clearAuth();
  }

  /// Refresh current user data from server
  Future<void> refreshUser() async {
    if (_token == null) return;

    try {
      final uri = Uri.parse('$_baseUrl/api/auth/me');

      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        _user = AuthUser.fromJson(json);
        await _saveToStorage();
        notifyListeners();
      } else {
        // Token might be expired
        await clearAuth();
      }
    } catch (_) {
      // Don't logout on network error, keep cached user
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
