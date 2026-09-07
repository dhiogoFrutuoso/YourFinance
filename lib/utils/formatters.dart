import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Formatters {
  static final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _monthYearFormat = DateFormat('MM/yyyy');
  static final _monthNameYearFormat = DateFormat('MMMM yyyy', 'pt_BR');

  static String formatCurrency(double value) {
    return _currencyFormat.format(value);
  }

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatMonthRef(String monthRef) {
    // monthRef is YYYY-MM
    final parts = monthRef.split('-');
    if (parts.length != 2) return monthRef;
    return '${parts[1]}/${parts[0]}';
  }
}

class SnackBarUtils {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
