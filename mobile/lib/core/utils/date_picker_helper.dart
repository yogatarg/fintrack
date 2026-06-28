// lib/core/utils/date_picker_helper.dart — file baru

import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Wrapper showDatePicker dengan dark theme yang konsisten
Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,           // warna header & tanggal terpilih
            onPrimary: Colors.black,              // teks di atas primary
            surface: AppColors.surface,           // background calendar
            onSurface: AppColors.textPrimary,     // teks tanggal
            secondary: AppColors.accent,
            onSecondary: Colors.white,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
          dialogBackgroundColor: AppColors.surface,
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: AppColors.textPrimary),
            bodyLarge: TextStyle(color: AppColors.textPrimary),
            labelLarge: TextStyle(color: AppColors.textPrimary),
            headlineMedium: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            titleMedium: TextStyle(color: AppColors.textMuted),
            titleSmall: TextStyle(color: AppColors.textMuted),
          ),
        ),
        child: child!,
      );
    },
  );
}

/// Wrapper showDateRangePicker dengan dark theme yang konsisten
Future<DateTimeRange?> showAppDateRangePicker({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTimeRange? initialDateRange,
}) {
  return showDateRangePicker(
    context: context,
    firstDate: firstDate,
    lastDate: lastDate,
    initialDateRange: initialDateRange,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: Colors.black,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
            secondary: AppColors.accent,
            onSecondary: Colors.white,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
          dialogBackgroundColor: AppColors.surface,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.elevated,
            foregroundColor: AppColors.textPrimary,
            iconTheme: IconThemeData(color: AppColors.textPrimary),
            titleTextStyle: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        child: child!,
      );
    },
  );
}