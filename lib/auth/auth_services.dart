import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tasklistapp/services/supabaseservices.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthService extends ChangeNotifier {

  final SupabaseService _supabase = SupabaseService();

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  bool _loading = false;
  String? _error;

  AuthStatus get status => _status;
  User? get user => _user;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthService() {
    _init();
  }

  void _init() {

    _user = _supabase.currentUser;

    _status = _user != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;

    _supabase.authStateChanges.listen((data) {
      _user = data.session?.user;

      _status = _user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;

      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {

    try {
      _setLoading(true);
      _setError(null);

      await _supabase.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      return true;

    } on AuthException catch (e) {
      _setError(e.message);
      return false;

    } catch (_) {
      _setError("Something went wrong");
      return false;

    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {

    try {
      _setLoading(true);
      _setError(null);

      await _supabase.signIn(email: email, password: password);

      return true;

    } on AuthException catch (e) {
      _setError(e.message);
      return false;

    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {

    try {
      _setLoading(true);
      await _supabase.signOut();
    } catch (_) {
      _setError("Sign out failed");
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {

    try {
      _setLoading(true);
      _setError(null);

      await _supabase.resetPassword(email);

      return true;

    } catch (_) {
      _setError("Failed to send reset email");
      return false;

    } finally {
      _setLoading(false);
    }
  }
}