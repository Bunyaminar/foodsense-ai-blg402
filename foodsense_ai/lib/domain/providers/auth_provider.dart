import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/exceptions/auth_exception.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isEmailVerified => _user?.emailVerified ?? false;
  
  AuthProvider() {
    _repository.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }
  
  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      _user = await _repository.register(email, password);
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      _user = await _repository.login(email, password);
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    notifyListeners();
  }
  
  Future<bool> checkEmailVerified() async {
    final isVerified = await _repository.checkEmailVerified();
    if (_user != null) {
      _user = UserModel(
        uid: _user!.uid,
        email: _user!.email,
        emailVerified: isVerified,
        displayName: _user!.displayName,
      );
      notifyListeners();
    }
    return isVerified;
  }
  
  Future<void> resendVerificationEmail() async {
    await _repository.resendVerificationEmail();
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
