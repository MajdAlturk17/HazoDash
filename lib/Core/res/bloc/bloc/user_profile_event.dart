import 'package:equatable/equatable.dart';

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends UserProfileEvent {
  final int userId;
  final String token;
  const LoadUserProfile({required this.userId, required this.token});
}

class PatchUserProfile extends UserProfileEvent {
  final int userId;
  final String token;
  final String? displayName;
  final String? country;
  final String? bio;
  final int? age;
  final String? gender;
  const PatchUserProfile({
    required this.userId,
    required this.token,
    this.displayName,
    this.country,
    this.bio,
    this.age,
    this.gender,
  });
}

class DeleteUserProfile extends UserProfileEvent {
  final int userId;
  final String token;
  const DeleteUserProfile({required this.userId, required this.token});
}
