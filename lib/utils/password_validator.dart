String? passwordValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return "Password is required";
  }
  if (value.length < 6) {
    return "Password must be at least 6 characters long";
  }
  if (!RegExp(r'^[A-Z]').hasMatch(value)) {
    return "Password must start with a capital letter";
  }
  if (!RegExp(r'\d').hasMatch(value)) {
    return "Password must contain at least one number";
  }
  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
    return "Password must contain at least one special character";
  }
  return null;
}

String? confirmPasswordValidator(String? value, String password) {
  if (value == null || value.trim().isEmpty) {
    return "Confirm password is required";
  }
  if (value != password) {
    return "Passwords do not match 👀";
  }
  return null;
}
