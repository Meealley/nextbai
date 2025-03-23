import 'package:flutter/material.dart';
import 'package:nextbai/theme/app_colors.dart';
import 'package:sizer/sizer.dart';

class CustomTextField extends StatelessWidget {
  final String? labelText;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final String? errorText;
  final TextInputType textInputType;
  final TextEditingController textEditingController;
  final bool obscureText; // Add this for password visibility control
  final Widget? suffixIcon; // Add this for the visibility toggle button
  final Widget? prefixIcon;

  const CustomTextField({
    super.key,
    this.labelText,
    this.validator,
    this.onSaved,
    this.errorText,
    required this.textInputType,
    required this.textEditingController,
    this.obscureText = false, // Default value is false for non-password fields
    this.suffixIcon,
    this.prefixIcon, // Optional, used for visibility toggle
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: textInputType,
      controller: textEditingController,
      style:
          obscureText ? TextStyle(fontSize: 17.sp) : TextStyle(fontSize: 16.sp),
      validator: validator,
      onSaved: onSaved,
      obscureText: obscureText, // Use the passed obscureText value
      cursorHeight: obscureText ? 24 : 23,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        errorText: errorText,
        // errorStyle: AppTextStyles.errorTextMessage,
        labelText: labelText,
        // labelStyle: AppTextStyles.bodyText,
        labelStyle: TextStyle(
          color: AppColors.grey,
          fontSize: 15.7.sp,
        ),
        contentPadding: const EdgeInsets.only(
          top: 1,
          bottom: 0,
          left: 6,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          borderSide: BorderSide(
            color: Colors.black,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          borderSide: BorderSide(
            color: Colors.black,
          ),
        ),
        suffixIcon: suffixIcon, // Set the suffix icon for toggling visibility
      ),
    );
  }
}
