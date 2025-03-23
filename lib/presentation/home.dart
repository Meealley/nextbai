import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nextbai/cubits/cubit/login_cubit.dart';
import 'package:nextbai/routes/pages.dart';
import 'package:nextbai/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state.logInStatus == LogInStatus.initial) {
            context.go(Pages.login);
            log("User logged out successfully");
          }
        },
        child: Column(
          children: [
            Center(
              child: Text("Please be informed that this is the home page"),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<LoginCubit>().signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.background,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Sign out",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
