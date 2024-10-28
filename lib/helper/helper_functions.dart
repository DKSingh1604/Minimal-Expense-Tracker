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

//calculate the number of months since the first month
int calculateMonthCount(int startYear, startMonth, currentMonth, currentYear) {
  int monthCount =
      (currentYear - startYear) * 12 + currentMonth - startMonth + 1;
  return monthCount;
}

//get current month name
String getCurrentMonthName() {
  DateTime now = DateTime.now();
  List<String> months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];
  return months[now.month - 1];
}
