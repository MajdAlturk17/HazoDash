import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hazodashborad/Core/res/Service/UserService.dart';
import 'package:hazodashborad/Core/res/bloc/bloc/user_profile_bloc.dart';
import 'package:hazodashborad/Core/res/bloc/bloc/user_profile_event.dart';
import 'package:hazodashborad/Core/res/bloc/bloc/user_profile_state.dart';
import 'package:hazodashborad/Features/widgets/EditUserProfileSheet.dart';
import 'package:hazodashborad/Features/widgets/InfoRow.dart';

class UserProfilePage extends StatelessWidget {
  final int userId;
  final String token;

  const UserProfilePage({Key? key, required this.userId, required this.token})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          UserProfileBloc(service: UserService())
            ..add(LoadUserProfile(userId: userId, token: token)),
      child: _UserProfileView(userId: userId, token: token),
    );
  }
}

class _UserProfileView extends StatefulWidget {
  final int userId;
  final String token;
  const _UserProfileView({Key? key, required this.userId, required this.token})
    : super(key: key);

  @override
  State<_UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<_UserProfileView> {
  Future<void> _openEdit(BuildContext context, UserProfileState state) async {
    final p = state.profile!;
    final result = await showModalBottomSheet<EditUserProfileResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EditUserProfileSheet(
        currentDisplayName: p.displayName,
        currentCountry: p.country,
        currentBio: p.bio,
        currentAge: p.age,
        currentGender: p.gender,
      ),
    );

    if (!mounted || result == null || result.isEmpty) return;

    context.read<UserProfileBloc>().add(
      PatchUserProfile(
        userId: widget.userId,
        token: widget.token,
        displayName: result.displayName,
        country: result.country,
        bio: result.bio,
        age: result.age,
        gender: result.gender,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserProfileBloc, UserProfileState>(
      listener: (context, state) {
        if (state.status == UserProfileStatus.failure) {
          Fluttertoast.showToast(
            msg: state.error ?? 'Something went wrong',
            backgroundColor: Colors.red,
          );
        } else if (state.status == UserProfileStatus.success) {
          Fluttertoast.showToast(
            msg: "Profile updated",
            backgroundColor: Colors.green,
          );
        } else if (state.status == UserProfileStatus.deleted) {
          Fluttertoast.showToast(
            msg: "User deleted",
            backgroundColor: Colors.green,
          );
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final isLoading =
            state.status == UserProfileStatus.loading ||
            state.status == UserProfileStatus.initial;
        final isDeleting = state.status == UserProfileStatus.deleting;
        final isSaving = state.status == UserProfileStatus.saving;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 2,
            title: const Text(
              "User Profile",
              style: TextStyle(
                color: Color(0xFF192132),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF192132)),
            actions: [
              if (isSaving || isDeleting)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    child: SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            ],
          ),
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF5B8DEF)),
                )
              : state.profile == null
              ? Center(
                  child: Text(
                    state.error ?? 'No data',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : Center(
                  child: Card(
                    color: Colors.white,
                    elevation: 16,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                      side: const BorderSide(
                        color: Color(0xFFE4E7EE),
                        width: 2,
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 38,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: const Color(
                              0xFF5B8DEF,
                            ).withOpacity(0.12),
                            backgroundImage:
                                state.profile!.profilePictureUrl != null
                                ? NetworkImage(
                                    state.profile!.profilePictureUrl!,
                                  )
                                : null,
                            child: state.profile!.profilePictureUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 56,
                                    color: Color(0xFF5B8DEF),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            state.profile!.displayName,
                            style: const TextStyle(
                              color: Color(0xFF192132),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            state.profile!.displayName,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                          Divider(
                            height: 32,
                            thickness: 1,
                            color: Colors.grey[200],
                          ),
                          InfoRow(
                            title: "Country",
                            value: state.profile!.country,
                          ),
                          const SizedBox(height: 12),
                          InfoRow(title: "Bio", value: state.profile!.bio),
                          const SizedBox(height: 12),
                          InfoRow(
                            title: "Age",
                            value: state.profile!.age.toString(),
                          ),
                          const SizedBox(height: 12),
                          InfoRow(
                            title: "Gender",
                            value: state.profile!.gender,
                          ),
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5B8DEF),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                                icon: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "Edit",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: isSaving
                                    ? null
                                    : () => _openEdit(context, state),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          floatingActionButton: (state.status == UserProfileStatus.failure)
              ? FloatingActionButton.extended(
                  onPressed: () => context.read<UserProfileBloc>().add(
                    LoadUserProfile(userId: widget.userId, token: widget.token),
                  ),
                  label: const Text('Retry'),
                  icon: const Icon(Icons.refresh),
                )
              : null,
        );
      },
    );
  }
}
