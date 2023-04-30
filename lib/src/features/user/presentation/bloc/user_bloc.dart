import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/repository/user_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _repository;

  UserBloc({UserRepository? repository})
      : _repository = repository ?? UserRepository(),
        super(UserInitial());

  User? getUser() {
    User? user = _repository.getUser();
    return user;
  }
}
