import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_color.dart';

class AppTheme {
  static final ThemeData themeData = ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor.primaryColor, brightness: Brightness.light),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: AppColor.primaryColor,
        statusBarIconBrightness: Brightness.light,
      )),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: AppColor.textColor),
        displayMedium: TextStyle(color: AppColor.textColor),
        displaySmall: TextStyle(color: AppColor.textColor),
        headlineMedium: TextStyle(color: AppColor.textColor),
        headlineSmall: TextStyle(color: AppColor.textColor),
        titleLarge: TextStyle(color: AppColor.textColor),
        titleMedium: TextStyle(color: AppColor.textColor),
        titleSmall: TextStyle(color: AppColor.textColor),
        bodyLarge: TextStyle(color: AppColor.textColor),
        bodyMedium: TextStyle(color: AppColor.textColor),
        bodySmall: TextStyle(color: AppColor.textColor),
        labelLarge: TextStyle(color: AppColor.textColor),
        labelSmall: TextStyle(color: AppColor.textColor),
      ));

  static var statusBarDesign = SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarIconBrightness: Brightness.light));
}
