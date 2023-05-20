import 'dart:async';

import '../../../home/presentation/home_screen.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/repository/auth_repository.dart';

import 'auth_event.dart';
import 'auth_state.dart';

import 'package:libphonenumber/libphonenumber.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  StreamSubscription<User?>? _authenticationStreamSubscription;
  final AuthenticationRepository _repository;

  AuthenticationBloc({AuthenticationRepository? repository})
      : _repository = repository ?? AuthenticationRepository(),
        super(AuthenticationInitial()) {
    on<AuthenticationStarted>(_authenticationStarted);
    on<AuthenticationLoggedOut>(_authenticationLoggedOut);
    on<AuthenticationStatusChanged>(_authenticationStatusChanged);
    on<AuthenticationGoogleSignInRequested>(_googleSignInRequested);
    // on<AuthenticationAppleSignInRequested>(_appleSignInRequested);
    on<AuthenticationPhoneNumberRequested>(_authenticationPhoneNumberRequested);
    on<AuthenticationPhoneCodeEntered>(_authenticationPhoneCodeEntered);
  }

  dynamic _authenticationPhoneCodeEntered(
      AuthenticationPhoneCodeEntered event, Emitter emit) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: event.verificationId!,
        smsCode: event.code,
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      emit(AuthenticationSucceeded(user: userCredential.user!));
    } on FirebaseAuthException catch (e) {
      emit(AuthenticationFailed(errorMessage: e.message!));
    } catch (e) {
      emit(AuthenticationFailed(errorMessage: e.toString()));
    }
  }

  dynamic _authenticationPhoneNumberRequested(
      AuthenticationPhoneNumberRequested event, Emitter emit) async {
    try {
      final formattedPhoneNumber = await PhoneNumberUtil.normalizePhoneNumber(
          phoneNumber: event.phoneNumber, isoCode: 'US');

      verificationCompleted(AuthCredential phoneAuthCredential) {
        print('Verification completed: $phoneAuthCredential');
        _authenticationStreamSubscription?.cancel();
        _authenticationStreamSubscription = null;
      }

      verificationFailed(FirebaseAuthException authException) {
        print(
            'Error: Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
      }

      codeSent(String verificationId, int? resendToken) async {
        String code = '';

        // show dialog to get verification code from user
        code = await showDialog(
          context: event.context,
          builder: (context) {
            return Builder(
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Enter Verification Code'),
                  content: TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      code = value;
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(code);
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                );
              },
            );
          },
        );

        try {
          UserCredential? user =
              await FirebaseAuth.instance.signInWithCredential(
            PhoneAuthProvider.credential(
                verificationId: verificationId, smsCode: code),
          );

          if (user != null) {
            // Not best practice to pass context to external class :(
            Navigator.push(
              event.context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
            print('Authentication successful!');
          } else {
            print('Error occurred during authentication');
          }
        } catch (e) {
          print('Error occurred during authentication: $e');
        }
      }

      codeAutoRetrievalTimeout(String verificationId) {
        print("auto retrieval timeout");
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (exception) {
      print("Error verifying phone number ${exception.toString()}");
    }
  }

  dynamic _googleSignInRequested(
      AuthenticationGoogleSignInRequested event, Emitter emit) async {
    try {
      UserCredential? userCredential = await _repository.signInWithGoogle();
      emit(AuthenticationGoogleSignInSucceeded(user: userCredential!.user!));
    } on FirebaseAuthException catch (e) {
      emit(AuthenticationGoogleSignInFailed(errorMessage: e.message!));
    } catch (e) {
      emit(AuthenticationGoogleSignInFailed(errorMessage: e.toString()));
    }
  }

  dynamic _authenticationStatusChanged(
      AuthenticationStatusChanged event, Emitter emit) async {
    if (event.user != null) {
      emit(AuthenticationSucceeded(user: event.user!));
    }
  }

  dynamic _authenticationStarted(
      AuthenticationStarted event, Emitter emit) async {
    try {
      await _repository.authenticateUser(
          email: event.email, password: event.password);
      _authenticationStreamSubscription = _repository.user.listen((user) {
        add(AuthenticationStatusChanged(user));
      });
    } catch (e) {
      emit(AuthenticationFailed(errorMessage: e.toString()));
    }
  }

  dynamic _authenticationLoggedOut(
      AuthenticationLoggedOut event, Emitter emit) async {
    print(event);
    await _repository.signOut();
    _authenticationStreamSubscription?.cancel();

    emit(AuthenticationInitial());
  }

  @override
  Future<void> close() {
    if (_authenticationStreamSubscription != null) {
      _authenticationStreamSubscription?.cancel();
    }
    return super.close();
  }

  // dynamic _appleSignInRequested(
  //     AuthenticationAppleSignInRequested event, Emitter emit) async {
  //   try {
  //     UserCredential? userCredential = await _repository.signInWithApple();
  //     emit(AuthenticationAppleSignInSucceeded(user: userCredential!.user!));
  //   } on FirebaseAuthException catch (e) {
  //     emit(AuthenticationAppleSignInFailed(errorMessage: e.message!));
  //   } catch (e) {
  //     emit(AuthenticationAppleSignInFailed(errorMessage: e.toString()));
  //   }
  // }
}
