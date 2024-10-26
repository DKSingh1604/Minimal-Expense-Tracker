import 'package:intl/intl.dart';

//Some helpful function used acreoss the app

double convertStringtoDouble(String string) {
  double? amount = double.tryParse(string);
  return amount ?? 0;
}

//fromat double amount into dollars and cents
String formatAmount(double amount) {
  final format =
      NumberFormat.currency(locale: "en_IN", symbol: "₹", decimalDigits: 2);
  return format.format(amount);
}
