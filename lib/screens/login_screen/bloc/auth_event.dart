import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthSignupRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  AuthSignupRequested(this.name, this.email, this.password);

  @override
  List<Object?> get props => [name, email, password];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {}
