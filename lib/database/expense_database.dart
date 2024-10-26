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
  Future<Map<int, double>> calculateMonthTotals() async {
    //ensure
  }
  //Get start month

  //Get start year
}
