// ignore_for_file: use_build_context_synchronously, invalid_use_of_visible_for_testing_member

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nextbai/cubits/onboarding/onboarding_cubit.dart';
import 'package:nextbai/presentation/onboardingscreen/onboarding_text_widget.dart';
import 'package:nextbai/theme/app_colors.dart';
import 'package:nextbai/utils/wave_clipper.dart';
import 'package:sizer/sizer.dart';
// import 'cubit/onboarding_cubit.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    context.read<OnboardingCubit>().initialize(totalPages: 3);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToAuthScreen(BuildContext context) {
    // Navigate to the auth screen
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        // When page changes in the cubit, update the page controller
        _pageController.animateToPage(
          state.currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );

        // If onboarding is completed, navigate to home
        if (state.status == OnboardingStatus.completed) {
          // You'll need to implement this navigation based on your router
          // Navigator.of(context).pushReplacementNamed('/home');
          _navigateToAuthScreen(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    height: MediaQuery.of(context).size.height *
                        0.5, // 40% of screen height

                    color: AppColors.background,
                  ),
                ),
              ),
              Column(
                children: [
                  // Skip button
                  SizedBox(
                    height: 3.h,
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextButton(
                        onPressed: () => context
                            .read<OnboardingCubit>()
                            .completeOnboarding()
                            .then((_) {
                          _navigateToAuthScreen(context);
                        }),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Onboarding content pages
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        // Update the cubit when page changes manually
                        final currentPage =
                            context.read<OnboardingCubit>().state.currentPage;
                        if (index != currentPage) {
                          // ignore: invalid_use_of_protected_member
                          context.read<OnboardingCubit>().emit(context
                              .read<OnboardingCubit>()
                              .state
                              .copyWith(currentPage: index));
                        }
                      },
                      children: [
                        OnboardingTextWidget(
                            title: 'Your Marketplace, Right Next Door!',
                            description:
                                'Discover amazing products from local and global vendors—all in one place.',
                            imagePath: 'assets/images/onboard1.png',
                            backgroundColor: Colors.blue.shade100),
                        OnboardingTextWidget(
                            title: ' Find Anything, Anytime!',
                            description:
                                'From fashion to electronics, get everything you need with just a few taps.',
                            imagePath: 'assets/images/onboard3.png',
                            backgroundColor: Colors.green.shade100),
                        OnboardingTextWidget(
                            title: "Let's Get You Started!",
                            description:
                                'Enjoy seamless payments and real-time order tracking.Multiple payment options with secure checkout',
                            imagePath: 'assets/images/onboard2.png',
                            backgroundColor: Colors.orange.shade100),
                      ],
                    ),
                  ),

                  // Page indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        state.totalPages,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == state.currentPage
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Navigation buttons
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button (hidden on first page)
                        state.currentPage > 0
                            ? TextButton(
                                onPressed: () => context
                                    .read<OnboardingCubit>()
                                    .previousPage(),
                                child: const Text('Back'),
                              )
                            : const SizedBox(width: 80),

                        // Next/Done button
                        ElevatedButton(
                          onPressed: () =>
                              context.read<OnboardingCubit>().nextPage(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.background,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            state.currentPage == state.totalPages - 1
                                ? 'Get Started'
                                : 'Next',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
