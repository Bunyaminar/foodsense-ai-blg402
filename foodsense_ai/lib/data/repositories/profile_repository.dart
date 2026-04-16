import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile_model.dart';
import '../../core/constants/app_constants.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<void> createProfile(ProfileModel profile) async {
    await _firestore
        .collection(AppConstants.firestoreProfilesCollection)
        .doc(profile.userId)
        .set(profile.toJson());
  }
  
  Future<ProfileModel?> getProfile(String userId) async {
    final doc = await _firestore
        .collection(AppConstants.firestoreProfilesCollection)
        .doc(userId)
        .get();
    
    if (!doc.exists) return null;
    return ProfileModel.fromJson(doc.data()!);
  }
  
  Future<void> updateProfile(ProfileModel profile) async {
    await _firestore
        .collection(AppConstants.firestoreProfilesCollection)
        .doc(profile.userId)
        .update(profile.toJson());
  }
  
  Future<bool> hasProfile(String userId) async {
    final doc = await _firestore
        .collection(AppConstants.firestoreProfilesCollection)
        .doc(userId)
        .get();
    return doc.exists;
  }
}
