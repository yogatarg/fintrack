// lib/core/utils/date_formatter.dart

import 'package:intl/intl.dart';

class DateFormatter {
  static String toDisplay(String isoDate) {
    final date = DateTime.parse(isoDate);
    return DateFormat('d MMM yyyy', 'id_ID').format(date);
  }

  static String toApiFormat(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}