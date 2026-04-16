class ProfileModel {
  final String userId;
  final String? name;
  final List<String> allergies;
  final String? dietType;
  final DateTime createdAt;
  
  ProfileModel({
    required this.userId,
    this.name,
    this.allergies = const [],
    this.dietType,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
  
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'allergies': allergies,
      'dietType': dietType,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['userId'],
      name: json['name'],
      allergies: List<String>.from(json['allergies'] ?? []),
      dietType: json['dietType'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
  
  ProfileModel copyWith({String? name, List<String>? allergies, String? dietType}) {
    return ProfileModel(
      userId: userId,
      name: name ?? this.name,
      allergies: allergies ?? this.allergies,
      dietType: dietType ?? this.dietType,
      createdAt: createdAt,
    );
  }
}
