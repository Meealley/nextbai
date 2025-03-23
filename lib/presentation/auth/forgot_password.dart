import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nextbai/routes/pages.dart';
import 'package:nextbai/theme/app_colors.dart';
import 'package:nextbai/utils/custom_text_field.dart';
import 'package:sizer/sizer.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 3.h,
              ),
              GestureDetector(
                onTap: () => context.go(Pages.login),
                child: Icon(
                  FontAwesomeIcons.circleChevronLeft,
                  size: 25.sp,
                  color: AppColors.background,
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              Form(
                key: _formKey,
                autovalidateMode: _autovalidateMode,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Text(
                      "Enter email associated with your account and we'll send an email with instructions to reset your password ",
                      style: TextStyle(
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                    CustomTextField(
                      textInputType: TextInputType.text,
                      textEditingController: _emailController,
                      labelText: "enter your email here",
                      prefixIcon: Icon(
                        FontAwesomeIcons.envelope,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.background,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Forgot Password",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
