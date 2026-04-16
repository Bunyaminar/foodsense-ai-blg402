import 'package:flutter/foundation.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();
  
  ProfileModel? _profile;
  bool _isLoading = false;
  String? _errorMessage;
  
  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<bool> createProfile({
    required String userId,
    String? name,
    List<String>? allergies,
    String? dietType,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _profile = ProfileModel(
        userId: userId,
        name: name,
        allergies: allergies ?? [],
        dietType: dietType,
      );
      
      await _repository.createProfile(_profile!);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Profil oluşturulurken hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _profile = await _repository.getProfile(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Profil yüklenirken hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> hasProfile(String userId) async {
    return await _repository.hasProfile(userId);
  }
}
