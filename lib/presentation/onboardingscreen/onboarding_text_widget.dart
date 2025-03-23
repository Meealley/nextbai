import 'package:flutter/material.dart';

class OnboardingTextWidget extends StatelessWidget {
  const OnboardingTextWidget({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.backgroundColor,
  });

  final String title;
  final String description;
  final String imagePath;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              imagePath,
              width: 250,
              height: 250,
            ),
          ),
          // Image.asset(
          //   imagePath,
          //   width: 250,
          //   height: 250,
          // ),
          const SizedBox(height: 40),
          Text(
            textAlign: TextAlign.center,
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
