import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hazodashborad/Core/res/Service/AuthService.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc(this.authService) : super(AuthInitial()) {


    // Login
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await authService.login(
          email: event.email,
          password: event.password,
        );

        /// token يجب أن يكون String ناتج من response.body مباشرة
        emit(AuthSuccess(token));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
