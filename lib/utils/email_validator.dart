import 'package:email_validator/email_validator.dart';

String? emailValidator(String? email) {
  if (email == null || email.trim().isEmpty) {
    return "Email is required";
  }
  if (!EmailValidator.validate(email.trim())) {
    return "Enter a valid email address";
  }
  return null;
}
