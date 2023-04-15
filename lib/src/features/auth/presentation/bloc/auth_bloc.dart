import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/repository/auth_repository.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository _repository;
  StreamSubscription<User?>? _authenticationStreamSubscription;

  AuthenticationBloc({required AuthenticationRepository repository})
      : _repository = repository,
        super(AuthenticationInitial()) {
    on<AuthenticationStarted>(_authenticationStarted);
    on<AuthenticationLoggedOut>(_authenticationLoggedOut);
    on<AuthenticationStatusChanged>(_authenticationStatusChanged);
    on<AuthenticationGoogleSignInRequested>(_googleSignInRequested);
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
}
