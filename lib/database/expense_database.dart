import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  final List<Expense> _allExpenses = [];

  //SETUP

  //INITIALIZE db
  static Future<void> initialise() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

  //GETTERS

  List<Expense> get allExpenses => _allExpenses;

  //OPERATIONS
  //Create - add a new expense
  Future<void> createNewExpense(Expense newExpense) async {
    //add to db
    await isar.writeTxn(() => isar.expenses.put(newExpense));

    //re-read from db
    readExpenses();
  }

  //Read - expenses from db
  Future<void> readExpenses() async {
    //fetch from db
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();

    //give it to local list
    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpenses);

    //display in UI
    notifyListeners();
  }

  //Update - edit an expense in db
  Future<void> updateExpense(int id, Expense updatedExpense) async {
    //make sure new expense has same id as the existing one
    updatedExpense.id = id;

    //update in db
    await isar.writeTxn(() => isar.expenses.put(updatedExpense));

    //re-read from db
    await readExpenses();
  }

  //Delete - an expense
  Future<void> deleteExpense(int id) async {
    //delete from db
    await isar.writeTxn(() => isar.expenses.delete(id));

    //re-read from db
    await readExpenses();
  }

  //  HELPER

  //Calculate total expenses for each month
  Future<Map<String, double>> calculateMonthlyTotals() async {
    //ensure the expenses are read from the db
    await readExpenses();

    //create a map to keep track of total expenses per month, year
    Map<String, double> monthlyTotals = {};

    //iterate over all expenses
    for (var expense in _allExpenses) {
      //extract the year &  month from the date of the expense
      String yearMonth = "${expense.date.year}-${expense.date.month}";

      //if the year-month is not yet in the map, initializa to 0
      if (!monthlyTotals.containsKey(yearMonth)) {
        monthlyTotals[yearMonth] = 0;
      }

      //add the expense amount to the total for the month
      monthlyTotals[yearMonth] = monthlyTotals[yearMonth]! + expense.amount;
    }
    return monthlyTotals;
  }

  //calculate current month total
  Future<double> calculateCurrentMonthTotal() async {
    //ensure the expenses are read from the db
    await readExpenses();

    //get current month, year
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    //filter the expenses to include only those for this month this year
    List<Expense> currentMonthExpenses = _allExpenses.where((expense) {
      return expense.date.month == currentMonth &&
          expense.date.year == currentYear;
    }).toList();
    //calculate total amount for the current month
    double total =
        currentMonthExpenses.fold(0, (sum, expense) => sum + expense.amount);
    return total;
  }

  //Get start month
  int getStartMonth() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().month;
    }
    //sort the expenses by date
    _allExpenses.sort(
      (a, b) => a.date.compareTo(b.date),
    );

    return _allExpenses.first.date.month;
  }

  //Get start year
  int getStartYear() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().year;
    }
    //sort the expenses by date
    _allExpenses.sort(
      (a, b) => a.date.compareTo(b.date),
    );

    return _allExpenses.first.date.year;
  }
}
