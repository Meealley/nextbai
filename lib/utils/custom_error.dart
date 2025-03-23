// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class CustomError extends Equatable {
  final String code;
  final String message;
  final String plugin;

  const CustomError({
    this.code = "",
    this.message = "",
    this.plugin = "",
  });

  @override
  List<Object> get props => [code, message, plugin];

  @override
  bool get stringify => true;

  // Extract a user-friendly error message
  String get userMessage {
    final regex = RegExp(r'\[(.*?)\]\s(.*)');
    final match = regex.firstMatch(message);
    if (match != null && match.groupCount >= 2) {
      return match.group(2)!;
    }
    return message;
  }
}
