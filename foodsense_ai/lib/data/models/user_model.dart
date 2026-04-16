class UserModel {
  final String uid;
  final String email;
  final bool emailVerified;
  final String? displayName;
  
  UserModel({
    required this.uid,
    required this.email,
    required this.emailVerified,
    this.displayName,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'emailVerified': emailVerified,
      'displayName': displayName,
    };
  }
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      emailVerified: json['emailVerified'] ?? false,
      displayName: json['displayName'],
    );
  }
}
