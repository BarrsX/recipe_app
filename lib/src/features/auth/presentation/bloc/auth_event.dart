import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AuthenticationStarted extends AuthenticationEvent {
  final String email;
  final String password;

  const AuthenticationStarted({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthenticationLoggedOut extends AuthenticationEvent {}

class AuthenticationLoggedIn extends AuthenticationEvent {
  final User user;

  const AuthenticationLoggedIn({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthenticationStatusChanged extends AuthenticationEvent {
  final User? user;

  const AuthenticationStatusChanged(this.user);

  @override
  List<Object> get props => [user!];
}

class AuthenticationGoogleSignInRequested extends AuthenticationEvent {}

class AuthenticationPhoneNumberRequested extends AuthenticationEvent {
  final String phoneNumber;
  final BuildContext context;

  AuthenticationPhoneNumberRequested({required this.phoneNumber, required this.context});
}

class AuthenticationPhoneCodeEntered extends AuthenticationEvent {
  final String code;
  final String? verificationId;

  AuthenticationPhoneCodeEntered({required this.code, this.verificationId});
}

class AuthenticationCodeEntered extends AuthenticationEvent {
  final String verificationId;
  final String code;

  const AuthenticationCodeEntered({
    required this.verificationId,
    required this.code,
  });

  @override
  List<Object> get props => [verificationId, code];
}
