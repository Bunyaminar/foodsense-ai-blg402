import 'app_exception.dart';

class AuthException extends AppException {
  AuthException(String message, {String? code}) : super(message, code: code);
  
  factory AuthException.fromFirebaseCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return AuthException('Bu e-posta adresi zaten kullanımda', code: code);
      case 'invalid-email':
        return AuthException('Geçersiz e-posta adresi', code: code);
      case 'weak-password':
        return AuthException('Şifre en az 6 karakter olmalıdır', code: code);
      case 'user-not-found':
        return AuthException('Kullanıcı bulunamadı', code: code);
      case 'wrong-password':
        return AuthException('Hatalı şifre', code: code);
      default:
        return AuthException('Bir hata oluştu: $code', code: code);
    }
  }
}
