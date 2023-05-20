import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];

  AuthenticationStatus get status {
    if (this is AuthenticationInitial || this is AuthenticationLoading) {
      return AuthenticationStatus.unknown;
    } else if (this is AuthenticationSucceeded) {
      return AuthenticationStatus.authenticated;
    } else if (this is AuthenticationFailed) {
      return AuthenticationStatus.unauthenticated;
    } else {
      throw Exception('Invalid state');
    }
  }
}

enum AuthenticationStatus {
  authenticated,
  unauthenticated,
  unknown,
}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationSucceeded extends AuthenticationState {
  final User user;

  const AuthenticationSucceeded({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthenticationFailed extends AuthenticationState {
  final String errorMessage;

  const AuthenticationFailed({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

class AuthenticationGoogleSignInFailed extends AuthenticationState {
  final String errorMessage;

  const AuthenticationGoogleSignInFailed({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

class AuthenticationGoogleSignInSucceeded extends AuthenticationState {
  final User user;

  const AuthenticationGoogleSignInSucceeded({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthenticationGoogleSignInInProgress extends AuthenticationState {}

class AuthenticationAppleSignInFailed extends AuthenticationState {
  final String errorMessage;

  const AuthenticationAppleSignInFailed({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

// class AuthenticationAppleSignInSucceeded extends AuthenticationState {
//   final User user;

//   const AuthenticationAppleSignInSucceeded({required this.user});

//   @override
//   List<Object> get props => [user];
// }

// class AuthenticationAppleSignInInProgress extends AuthenticationState {}

class AuthenticationPhoneNumberFailed extends AuthenticationState {
  final String errorMessage;

  const AuthenticationPhoneNumberFailed({required this.errorMessage});
}

class PhoneAuthStateCodeSent extends AuthenticationState {
  final String verificationId;
  final int? resendToken;
  final String phoneNumber;

  const PhoneAuthStateCodeSent(
      {required this.verificationId,
      this.resendToken,
      required this.phoneNumber});
}

class PhoneAuthStateCodeEntered extends AuthenticationState {

  const PhoneAuthStateCodeEntered();
}
