// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'login_cubit.dart';

enum LogInStatus { initial, loading, success, successLocationNeeded, failure }

class LoginState extends Equatable {
  final LogInStatus logInStatus;

  final CustomError error;

  const LoginState({required this.logInStatus, required this.error});

  factory LoginState.initial() {
    return LoginState(
      logInStatus: LogInStatus.initial,
      error: CustomError(),
    );
  }

  @override
  List<Object> get props => [logInStatus, error];

  @override
  bool get stringify => true;

  LoginState copyWith({
    LogInStatus? logInStatus,
    CustomError? error,
  }) {
    return LoginState(
      logInStatus: logInStatus ?? this.logInStatus,
      error: error ?? this.error,
    );
  }
}
