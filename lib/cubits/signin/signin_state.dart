part of 'signin_cubit.dart';

enum SignInStatus { initial, loading, success, successLocationNeeded, failure }

class SigninState extends Equatable {
  final SignInStatus signInStatus;

  final CustomError error;

  const SigninState({
    required this.signInStatus,
    required this.error,
  });

  factory SigninState.initial() {
    return const SigninState(
      signInStatus: SignInStatus.initial,
      error: CustomError(),
    );
  }

  @override
  List<Object?> get props => [signInStatus, error];

  @override
  bool get stringify => true;

  SigninState copyWith({
    SignInStatus? signInStatus,
    // UserModel? user,
    CustomError? error,
  }) {
    return SigninState(
      signInStatus: signInStatus ?? this.signInStatus,
      error: error ?? this.error,
    );
  }
}
