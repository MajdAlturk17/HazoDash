import 'package:bloc/bloc.dart';
import 'user_profile_event.dart';
import 'user_profile_state.dart';
import 'package:hazodashborad/Core/res/Service/UserService.dart';
import 'package:hazodashborad/Core/res/Model/UserProfile.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final UserService service;

  UserProfileBloc({required this.service}) : super(const UserProfileState()) {
    on<LoadUserProfile>(_onLoad);
    on<PatchUserProfile>(_onPatch);
    on<DeleteUserProfile>(_onDelete);
  }

  Future<void> _onLoad(LoadUserProfile e, Emitter<UserProfileState> emit) async {
    emit(state.copyWith(status: UserProfileStatus.loading));
    try {
      final profile = await service.getUserProfile(e.userId, e.token);
      emit(state.copyWith(status: UserProfileStatus.loaded, profile: profile, error: null));
    } catch (err) {
      emit(state.copyWith(status: UserProfileStatus.failure, error: err.toString()));
    }
  }

  Future<void> _onPatch(PatchUserProfile e, Emitter<UserProfileState> emit) async {
    emit(state.copyWith(status: UserProfileStatus.saving));
    try {
      final updated = await service.patchUserProfile(
        userId: e.userId,
        token: e.token,
        displayName: e.displayName,
        country: e.country,
        bio: e.bio,
        age: e.age,
        gender: e.gender,
      );
      emit(state.copyWith(status: UserProfileStatus.success, profile: updated, error: null));
      // بعد النجاح، ارجع للحالة loaded لتحديث الواجهة بثبات
      emit(state.copyWith(status: UserProfileStatus.loaded));
    } catch (err) {
      emit(state.copyWith(status: UserProfileStatus.failure, error: err.toString()));
    }
  }

  Future<void> _onDelete(DeleteUserProfile e, Emitter<UserProfileState> emit) async {
    emit(state.copyWith(status: UserProfileStatus.deleting));
    try {
      final ok = await service.deleteUser(e.userId, e.token);
      if (ok) {
        emit(state.copyWith(status: UserProfileStatus.deleted));
      } else {
        throw Exception('Delete failed');
      }
    } catch (err) {
      emit(state.copyWith(status: UserProfileStatus.failure, error: err.toString()));
    }
  }
}
