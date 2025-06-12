import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String login;
  final String senha;

  const AuthLoginRequested({
    required this.login,
    required this.senha,
  });

  @override
  List<Object?> get props => [login, senha];
}

class AuthLogoutRequested extends AuthEvent {}