class UserProfile {
  final int id;
  final String displayName;
  final String country;
  final String bio;
  final String? profilePictureUrl; // قد تكون null
  final int age;
  final String gender;

  UserProfile({
    required this.id,
    required this.displayName,
    required this.country,
    required this.bio,
    this.profilePictureUrl,
    required this.age,
    required this.gender,
  });

  // دالة لإنشاء نموذج من JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      displayName: json['displayName'],
      country: json['country'],
      bio: json['bio'],
      profilePictureUrl: json['profilePictureUrl'],
      age: json['age'],
      gender: json['gender'],
    );
  }

  // دالة لتحويل النموذج إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'country': country,
      'bio': bio,
      'profilePictureUrl': profilePictureUrl,
      'age': age,
      'gender': gender,
    };
  }
}