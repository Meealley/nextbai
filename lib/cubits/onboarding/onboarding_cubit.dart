import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(OnboardingState.initial());

  // Initialize with custom number of pages if needed
  void initialize({int totalPages = 3}) {
    emit(state.copyWith(totalPages: totalPages));
  }

  // Navigate to the next page
  void nextPage() {
    if (state.currentPage < state.totalPages - 1) {
      emit(state.copyWith(currentPage: state.currentPage + 1));
    } else {
      // If we're on the last page, complete onboarding
      completeOnboarding();
    }
  }

  // Navigate to the previous page
  void previousPage() {
    if (state.currentPage > 0) {
      emit(state.copyWith(currentPage: state.currentPage - 1));
    }
  }

  // Skip to the end of onboarding
  void skipOnboarding() {
    completeOnboarding();
  }

  // Mark onboarding as completed and save to SharedPreferences
  Future<void> completeOnboarding() async {
    // Update state
    emit(state.copyWith(status: OnboardingStatus.completed));

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showOnboarding', false);
  }

  // Reset onboarding if needed (e.g., for testing or when user chooses to see tutorial again)
  Future<void> resetOnboarding() async {
    emit(OnboardingState(
      status: OnboardingStatus.inProgress,
      currentPage: 0,
      totalPages: state.totalPages,
    ));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showOnboarding', true);
  }
}
