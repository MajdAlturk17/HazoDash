import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class RegisterEvent extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  final String phoneNumber;

  RegisterEvent(this.fullName, this.email, this.password, this.phoneNumber);
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent(this.email, this.password);
}
