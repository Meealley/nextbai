import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nextbai/models/user_model.dart';
import 'package:nextbai/repository/auth_repository.dart';
import 'package:nextbai/utils/custom_error.dart';

part 'signin_state.dart';

class SigninCubit extends Cubit<SigninState> {
  final AuthRepository _authRepository;

  SigninCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(SigninState.initial());

  Future<void> signUp({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  }) async {
    emit(state.copyWith(signInStatus: SignInStatus.loading));

    try {
      final user = await _authRepository.signUp(
        email: email,
        password: password,
        firstname: firstname,
        lastname: lastname,
      );
      log("Firebase sign-up success: $user");
      emit(state.copyWith(signInStatus: SignInStatus.success));
    } on EmailAlreadyInUseException {
      emit(state.copyWith(
          signInStatus: SignInStatus.failure,
          error: CustomError(message: 'Email already in use')));
    } on InvalidEmailException {
      emit(state.copyWith(
          signInStatus: SignInStatus.failure,
          error: CustomError(message: 'Invalid email')));
    } on WeakPasswordException {
      emit(state.copyWith(
          signInStatus: SignInStatus.failure,
          error: CustomError(message: 'Weak password')));
    } on NetworkException {
      emit(state.copyWith(
          signInStatus: SignInStatus.failure,
          error: CustomError(message: 'Network error')));
    } catch (e) {
      log(e.toString());
      emit(state.copyWith(
          signInStatus: SignInStatus.failure,
          error: CustomError(message: 'Sign-up failed')));
    }
  }

  /// **Sign in with Google**
  Future<void> signInWithGoogle() async {
    emit(state.copyWith(signInStatus: SignInStatus.loading));

    try {
      final user = await _authRepository.signInWithGoogle();
      log("Google sign-in success: ${user.email}");

      emit(
        state.copyWith(
          signInStatus: SignInStatus.success,
        ),
      );
    } on NetworkException {
      emit(state.copyWith(
        signInStatus: SignInStatus.failure,
        error: CustomError(message: 'Network error'),
      ));
    } on GenericAuthException {
      emit(state.copyWith(
        signInStatus: SignInStatus.failure,
        error: CustomError(message: 'Google sign-in failed'),
      ));
    } catch (e) {
      log("Google Sign-in Error: $e");
      emit(state.copyWith(
        signInStatus: SignInStatus.failure,
        error: CustomError(message: 'An unexpected error occurred'),
      ));
    }
  }

  // Sign In with Apple
  Future<void> signInWithApple() async {
    emit(state.copyWith(signInStatus: SignInStatus.loading));

    try {
      final user = await _authRepository.signInWithApple();
      log("Apple sign-in success: ${user.email}");

      emit(
        state.copyWith(
          signInStatus: SignInStatus.success,
        ),
      );
    } on NetworkException {
      emit(state.copyWith(
        signInStatus: SignInStatus.failure,
        error: CustomError(message: 'Network error'),
      ));
    } on GenericAuthException {
      emit(state.copyWith(
        signInStatus: SignInStatus.failure,
        error: CustomError(message: 'Apple sign-in failed'),
      ));
    } catch (e) {
      log("Google Sign-in Error: $e");
      emit(state.copyWith(
        signInStatus: SignInStatus.failure,
        error: CustomError(message: 'An unexpected error occurred'),
      ));
    }
  }
}
