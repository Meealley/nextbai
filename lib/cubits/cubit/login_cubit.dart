import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nextbai/repository/auth_repository.dart';
import 'package:nextbai/utils/custom_error.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  LoginCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(LoginState.initial());

  Future<void> logIn({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(logInStatus: LogInStatus.loading));

    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      log("Firebase Log-in success: $user");
      emit(state.copyWith(logInStatus: LogInStatus.success));
    } on EmailAlreadyInUseException {
      emit(state.copyWith(
          logInStatus: LogInStatus.failure,
          error: CustomError(message: 'Email already in use')));
    } on InvalidEmailException {
      emit(state.copyWith(
          logInStatus: LogInStatus.failure,
          error: CustomError(message: 'Invalid email')));
    } on NetworkException {
      emit(state.copyWith(
          logInStatus: LogInStatus.failure,
          error: CustomError(message: 'Network error')));
    } catch (e) {
      log(e.toString());
      emit(state.copyWith(
          logInStatus: LogInStatus.failure,
          error: CustomError(message: 'Login failed')));
    }
  }

  // Sign out
  Future<void> signOut() async {
    emit(state.copyWith(logInStatus: LogInStatus.loading));

    try {
      await _authRepository.signOut();
      emit(state.copyWith(logInStatus: LogInStatus.initial));
    } catch (e) {
      log(e.toString());
      emit(state.copyWith(logInStatus: LogInStatus.failure));
    }
  }
}
