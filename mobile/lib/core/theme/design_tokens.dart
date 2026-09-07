import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF187456);
  static const deepGreen = Color(0xFF164D3B);
  static const softGreen = Color(0xFFDCEED9);
  static const mint = Color(0xFFE9F5EE);
  static const surfaceGreen = Color(0xFFF1F7F0);
  static const background = Color(0xFFFAFBF7);
  static const surface = Colors.white;
  static const yellow = Color(0xFFF3CC68);
  static const orange = Color(0xFF985322);
  static const softOrange = Color(0xFFFFF0DF);
  static const ink = Color(0xFF20372F);
  static const secondaryText = Color(0xFF5C7067);
  static const border = Color(0xFFDDE7DF);
}

abstract final class AppSpacing {
  static const xs = 4.0, sm = 8.0, md = 12.0, lg = 16.0, xl = 24.0, xxl = 32.0;
  static const page = EdgeInsets.fromLTRB(20, 16, 20, 32);
}

abstract final class AppRadius {
  static const small = BorderRadius.all(Radius.circular(12));
  static const card = BorderRadius.all(Radius.circular(24));
  static const node = BorderRadius.all(Radius.circular(32));
}

abstract final class AppShadows {
  static const soft = [
    BoxShadow(color: Color(0x0B164D3B), blurRadius: 20, offset: Offset(0, 5)),
  ];
}

abstract final class AppMotion {
  static const gentle = Duration(milliseconds: 280);
  static Duration duration(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : gentle;
}

abstract final class AppTypography {
  static const textTheme = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      height: 1.25,
      letterSpacing: -1,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.3,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.35,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.45,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 1.4,
    ),
    bodyLarge: TextStyle(fontSize: 16, height: 1.6),
    bodyMedium: TextStyle(fontSize: 14, height: 1.5),
    bodySmall: TextStyle(fontSize: 12, height: 1.5),
    labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
  );
}
