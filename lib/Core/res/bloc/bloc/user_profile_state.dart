import 'package:equatable/equatable.dart';
import 'package:hazodashborad/Core/res/Model/UserProfile.dart';

enum UserProfileStatus {
  initial,
  loading,
  loaded,
  saving,
  deleting,
  success,   // نجاح عملية تعديل
  deleted,   // نجاح حذف
  failure,
}

class UserProfileState extends Equatable {
  final UserProfileStatus status;
  final UserProfile? profile;
  final String? error;

  const UserProfileState({
    this.status = UserProfileStatus.initial,
    this.profile,
    this.error,
  });

  UserProfileState copyWith({
    UserProfileStatus? status,
    UserProfile? profile,
    String? error,
  }) {
    return UserProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, profile, error];
}
