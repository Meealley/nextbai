// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'onboarding_cubit.dart';

enum OnboardingStatus { inProgress, completed }

class OnboardingState extends Equatable {
  final OnboardingStatus status;
  final int currentPage;
  final int totalPages;

  const OnboardingState(
      {required this.status,
      required this.currentPage,
      required this.totalPages});

  factory OnboardingState.initial() {
    return OnboardingState(
        status: OnboardingStatus.inProgress, currentPage: 0, totalPages: 3);
  }

  @override
  List<Object> get props => [status, currentPage, totalPages];

  @override
  bool get stringify => true;

  OnboardingState copyWith({
    OnboardingStatus? status,
    int? currentPage,
    int? totalPages,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
