import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nextbai/cubits/cubit/login_cubit.dart';
import 'package:nextbai/routes/pages.dart';
import 'package:nextbai/theme/app_colors.dart';
import 'package:nextbai/utils/custom_text_field.dart';
import 'package:nextbai/utils/email_validator.dart';
import 'package:nextbai/utils/password_validator.dart';
import 'package:nextbai/utils/wave_clipper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  late TextEditingController _emailController, _passwordController;

  String? _email, _password;
  bool _obscureText = true;
  bool _loadWithProgress = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _loadCredentials();
  }

  @override
  void dispose() {
    super.dispose();

    _emailController.dispose();
    _passwordController.dispose();
  }

  // Load credentials from shared preferences
  Future<void> _loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('savedEmail') ?? '';
        _passwordController.text = prefs.getString('savedPassword') ?? '';
      }
    });
  }

  // Saved credentials when login is successful
  Future<void> _saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('savedEmail', _emailController.text);
      await prefs.setString('savedPassword', _passwordController.text);
    } else {
      await prefs.remove('savedEmail');
      await prefs.remove('savedPassword');
    }
    await prefs.setBool('rememberMe', _rememberMe);
  }

  void _submit() {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
      final form = _formKey.currentState;

      if (form == null || !form.validate()) return;

      form.save();

      _loadWithProgress = !_loadWithProgress;
      log("email: $_email, password: $_password");

      context.read<LoginCubit>().logIn(
            email: _email!,
            password: _password!,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) async {
        if (state.logInStatus == LogInStatus.success) {
          await _saveCredentials();
          context.go(Pages.homeScreen);
        } else if (state.logInStatus == LogInStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Login failed"),
              backgroundColor: AppColors.background,
            ),
          );
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppColors.white,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              // Background Image (Covers Halfway)
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

              // Login Form (Foreground)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 39,
                          spreadRadius: 9,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _autovalidateMode,
                      child: SizedBox(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            Text(
                              "Log into",
                              style: TextStyle(
                                  fontSize: 22.sp, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "your account",
                              style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.background),
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                            SizedBox(height: 2.h),
                            CustomTextField(
                              textInputType: TextInputType.text,
                              textEditingController: _emailController,
                              labelText: 'Email address',
                              validator: (value) {
                                return emailValidator(value);
                              },
                              onSaved: (String? value) {
                                setState(() {
                                  _email = value;
                                });
                              },
                            ),
                            SizedBox(height: 2.h),
                            CustomTextField(
                              textInputType: TextInputType.text,
                              textEditingController: _passwordController,
                              labelText: 'Password',
                              obscureText: _obscureText,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? FontAwesomeIcons.eyeSlash
                                      : FontAwesomeIcons.eye,
                                  size: 17.sp,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText =
                                        !_obscureText; // Toggle visibility
                                  });
                                },
                              ),
                              validator: (value) {
                                return passwordValidator(value);
                              },
                              onSaved: (value) {
                                setState(() {
                                  _password = value;
                                });
                              },
                            ),
                            SizedBox(height: 2.h),
                            ElevatedButton(
                              onPressed: _loadWithProgress ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _loadWithProgress
                                    ? AppColors.buttonLoading
                                    : AppColors.background,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                _loadWithProgress ? "Loading..." : "Login in",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 9.sp,
                                  ),
                                  child: Row(
                                    // mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 8,
                                        width: 8,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              _rememberMe = value!;
                                            });
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: 2.w,
                                      ),
                                      Text(
                                        "Remember Me",
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.go(Pages.forgotPassword),
                                  child: Text("Forgot Password?"),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            Column(
                              children: [
                                Center(
                                  child: Text("or log in with"),
                                ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.grey,
                                      radius: 3.h,
                                      child: CircleAvatar(
                                        radius: 3.h - 1,
                                        backgroundColor: AppColors.white,
                                        child: Center(
                                          child: SvgPicture.asset(
                                            "assets/images/Apple.svg",
                                            width: 36, // Adjust size as needed
                                            height: 36,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        width: 16), // Add spacing between icons
                                    CircleAvatar(
                                      radius: 3.h,
                                      backgroundColor: AppColors.grey,
                                      child: CircleAvatar(
                                        radius: 3.h - 1,
                                        backgroundColor: AppColors.white,
                                        child: SvgPicture.asset(
                                          "assets/images/google_icon.svg",
                                          width: 36, // Adjust size as needed
                                          height: 36,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Don't have an account?"),
                                    SizedBox(
                                      width: 1.w,
                                    ),
                                    GestureDetector(
                                      onTap: () => context.go(Pages.auth),
                                      child: Text(
                                        "Sign Up",
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
