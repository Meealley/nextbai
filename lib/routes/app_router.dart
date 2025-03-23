import 'package:go_router/go_router.dart';
import 'package:nextbai/presentation/auth/auth_screen.dart';
import 'package:nextbai/presentation/auth/forgot_password.dart';
import 'package:nextbai/presentation/auth/login_screen.dart';
import 'package:nextbai/presentation/home.dart';
import 'package:nextbai/presentation/onboardingscreen/onboarding_screen.dart';
import 'package:nextbai/repository/auth_repository.dart';
import 'package:nextbai/routes/pages.dart';

class AppRouter {
  final bool showOnboarding;

  final AuthRepository authRepository;

  AppRouter(this.authRepository, {required this.showOnboarding});

  GoRouter get router => GoRouter(
        initialLocation: showOnboarding ? Pages.onboarding : Pages.login,
        routes: [
          GoRoute(
            path: Pages.onboarding,
            name: 'onboarding',
            builder: (context, state) => OnboardingScreen(),
          ),
          GoRoute(
            path: Pages.auth,
            name: Pages.auth,
            builder: (context, state) => AuthScreen(),
          ),
          GoRoute(
            path: Pages.login,
            name: Pages.login,
            builder: (context, state) => LoginScreen(),
          ),
          GoRoute(
            path: Pages.forgotPassword,
            name: Pages.forgotPassword,
            builder: (context, state) => ForgotPassword(),
          ),
          GoRoute(
            path: Pages.homeScreen,
            name: Pages.homeScreen,
            builder: (context, state) => HomePage(),
          ),
        ],
        redirect: (context, state) {
          final isLoggedIn = authRepository.isUserLoggedIn();
          final currentPath = state.uri.path; // Alternative to subloc

          final isAuthPage =
              currentPath == Pages.auth || currentPath == Pages.login;

          if (isLoggedIn && isAuthPage) {
            return Pages
                .homeScreen; // Redirect logged-in users away from auth pages
          } else if (!isLoggedIn && currentPath == Pages.homeScreen) {
            return Pages.login; // Redirect non-logged-in users to auth page
          }
          return null; // No redirection needed
        },
      );
}
