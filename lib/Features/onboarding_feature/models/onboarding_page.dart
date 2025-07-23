import 'package:flutter/material.dart';

class OnboardingPage {
  final String icon;
  final String titleKey; // Translation key for title
  final String descriptionKey; // Translation key for description
  final Color buttonColor;
  final String route;

  OnboardingPage({
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
    required this.buttonColor,
    required this.route,
  });
}
