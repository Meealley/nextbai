import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nextbai/cubits/cubit/login_cubit.dart';
import 'package:nextbai/cubits/onboarding/onboarding_cubit.dart';
import 'package:nextbai/cubits/signin/signin_cubit.dart';
import 'package:nextbai/firebase_options.dart';
import 'package:nextbai/models/user_hive.dart';
import 'package:nextbai/repository/auth_repository.dart';
import 'package:nextbai/routes/app_router.dart';
import 'package:nextbai/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive
  await Hive.initFlutter();

  //Reigester Hive
  Hive.registerAdapter(UserHiveAdapter());

  await Hive.openBox('authBox');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = prefs.getBool('showOnboarding') ?? true;
  runApp(NextBuyApp(
    showOnboarding: showOnboarding,
    authRepository: AuthRepository(),
  ));
}

class NextBuyApp extends StatelessWidget {
  final bool showOnboarding;
  final AuthRepository authRepository;

  const NextBuyApp(
      {super.key, required this.showOnboarding, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter(showOnboarding: showOnboarding, authRepository);

    return MultiBlocProvider(
      providers: [
        BlocProvider<OnboardingCubit>(
          create: (context) => OnboardingCubit(),
        ),
        BlocProvider<SigninCubit>(
          create: (context) => SigninCubit(authRepository: authRepository),
        ),
        BlocProvider<LoginCubit>(
          create: (context) => LoginCubit(authRepository: authRepository),
        ),
      ],
      child: Sizer(
        builder: (context, _, __) {
          return MaterialApp.router(
            theme: ThemeData(
              fontFamily: 'DM Sans',
              primaryColor: AppColors.background,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.background,
                primary: AppColors.background,
                secondary:
                    Color(0xFFE69520), // Optional: Adjust secondary color
              ),
            ),
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}
