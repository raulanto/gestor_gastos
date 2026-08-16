import 'package:intl/intl.dart';
class CurrencyUtils {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
    locale: 'es_MX',
  );

  static final NumberFormat _currencyFormatNoDecimals = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 0,
    locale: 'es_MX',
  );

  static String formatAmount(double amount, {bool showDecimals = true}) {
    if (showDecimals) {
      return _currencyFormat.format(amount);
    } else {
      return _currencyFormatNoDecimals.format(amount);
    }
  }

  static String formatPercentage(double value, {int decimalDigits = 0}) {
    return '${value.toStringAsFixed(decimalDigits)}%';
  }
}
