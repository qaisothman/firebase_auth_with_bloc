import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

extension CustomColorScheme on ColorScheme {
  Color get primaryPressed => const Color(0xFF537AE4);

  Color get primaryVariantPressed => const Color(0xFFEFF7FF);
  Color get secondaryPressed => const Color(0xFF9CF2FF);
  Color get success => const Color(0xFF63D09F);
  Color get successPressed => const Color(0xFF57F0AB);
  Color get onSuccess => const Color(0xFFFFFFFF);
  Color get successSurface => const Color(0xFF30664E);
  Color get errorPressed => const Color(0xFFFF908C);
  Color get errorSurface => const Color(0xFF621B16);
  Color get overlay => const Color(0xFF000000).withOpacity(0.75);
  Color get inputBG => const Color(0xFFF3F4FA);
  Color get surfacePrimary => const Color(0xFFF9FAFD);
  Color get kHighEmphasis => const Color(0XFF223754);
  Color get kMedEmphasis => const Color(0XFF7A8798);
  Color get kLowEmphasis => const Color(0XFFB6C5DC);
}

extension TextStyleExtension on TextStyle {
  TextStyle? get highEmphasis => copyWith(color: const Color(0XFF223754));
  TextStyle? get medEmphasis => copyWith(color: const Color(0XFF7A8798));
  TextStyle? get lowEmphasis => copyWith(color: const Color(0XFFB6C5DC));
  TextStyle? get onPrimary => copyWith(color: const Color(0xFFFFFFFF));
}

extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
}

ThemeData get lightTheme => ThemeData(
      brightness: Brightness.light,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: Colors.white,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        color: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 10,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return const Color(0XFF6971DA).withOpacity(.48);
          }
          return const Color(0XFF6971DA);
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return const Color(0XFF6971DA).withOpacity(.48);
          }
          return const Color(0XFF6971DA).withOpacity(.48);
        }),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      primaryColor: const Color(0XFF6971DA),
      colorScheme: const ColorScheme(
        primary: Color(0XFF2E5FE3),
        onPrimary: Colors.white,
        primaryContainer: Color(0XFFE7F1FC),
        secondary: Color(0XFF77E5F6),
        onSecondary: Color(0XFF223754),
        // secondaryVariant: Color(0XFF77E5F6),
        background: Colors.white,
        onBackground: Color(0XFFF4F5FC),
        error: Color(0XFFE55752),
        onError: Colors.white,
        surface: Color(0XFFECF0F6),
        onSurface: Colors.white,
        brightness: Brightness.light,
      ),
    );
