// lib/core/constants/app_constants.dart

import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'FinTrack';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}

class AppColors {
  // Base
  static const Color background  = Color(0xFF0D1117);
  static const Color surface     = Color(0xFF161B22);
  static const Color elevated    = Color(0xFF21262D);
  static const Color border      = Color(0xFF30363D);

  // Brand
  static const Color primary     = Color(0xFF3FB950);
  static const Color accent      = Color(0xFF58A6FF);

  // Semantic
  static const Color income      = Color(0xFF3FB950);
  static const Color expense     = Color(0xFFF85149);
  static const Color warning     = Color(0xFFD29922);

  // Text
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textMuted   = Color(0xFF7D8590);

  // Legacy aliases agar widget lama tidak break
  static const Color cardBackground = surface;
  static const Color textSecondary  = textMuted;
  static const Color riskLow        = primary;
  static const Color riskMedium     = warning;
  static const Color riskHigh       = Color(0xFFE3702A);
  static const Color riskOver       = expense;
}

class AppTextStyles {
  // Angka besar — hero di tiap screen
  static const TextStyle heroAmount = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
    height: 1.1,
  );

  // Angka medium — summary card
  static const TextStyle mediumAmount = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  // Label kecil di atas angka
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 0.4,
  );

  // Body text
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // Title section
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0.6,
  );
}

class AppSpacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;

  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 16);
}

class AppRadius {
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 20;
  static const double full = 100;
}