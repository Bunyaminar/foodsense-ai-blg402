import 'package:firebase_auth/firebase_auth.dart';
import '../../core/exceptions/auth_exception.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserModel(
        uid: user.uid,
        email: user.email!,
        emailVerified: user.emailVerified,
        displayName: user.displayName,
      );
    });
  }
  
  Future<UserModel> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.sendEmailVerification();
      return UserModel(
        uid: credential.user!.uid,
        email: credential.user!.email!,
        emailVerified: credential.user!.emailVerified,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(e.code);
    }
  }
  
  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel(
        uid: credential.user!.uid,
        email: credential.user!.email!,
        emailVerified: credential.user!.emailVerified,
        displayName: credential.user!.displayName,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(e.code);
    }
  }
  
  Future<void> logout() async {
    await _auth.signOut();
  }
  
  Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }
  
  Future<void> resendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }
}
