import 'package:flutter/material.dart';

class TextStyles {
  static double headingLarge(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 32;
    if (width < 900) return 48;
    return 64;
  }

  static double headingMedium(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 24;
    if (width < 900) return 36;
    return 48;
  }

  static double headingSmall(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 18;
    if (width < 900) return 24;
    return 32;
  }

  static double regularText(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 12;
    if (width < 900) return 16;
    return 16;
  }
}