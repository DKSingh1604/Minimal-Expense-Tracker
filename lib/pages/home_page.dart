// ignore_for_file: avoid_unnecessary_containers

import 'package:expense_tracker/bar%20graph/bar_graph.dart';
import 'package:expense_tracker/components/my_list_tile.dart';
import 'package:expense_tracker/database/expense_database.dart';
import 'package:expense_tracker/helper/helper_functions.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //text controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  //futures to load graph data & monthly total
  Future<Map<String, double>>? _monthlyTotalsFuture;
  Future<double>? _calculateCurrentMonthTotal;

  @override
  void initState() {
    //read db on initial startup
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();

    //load futures
    refreshData();

    super.initState();
  }

  //refresh graph data
  void refreshData() {
    _monthlyTotalsFuture = Provider.of<ExpenseDatabase>(context, listen: false)
        .calculateMonthlyTotals();

    _calculateCurrentMonthTotal =
        Provider.of<ExpenseDatabase>(context, listen: false)
            .calculateCurrentMonthTotal();
  }

  //open new expense Box
  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("New Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //user input -> expense name
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Name",
              ),
            ),

            //user input -> expense amount
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                hintText: "Amount",
              ),
            ),
          ],
        ),
        actions: [
          //cancel button
          _cancelButton(),

          //save button
          _createNewExpenseButton(),
        ],
      ),
    );
  }

  //open edit Box
  void openEditBox(Expense expense) {
    //pre-fill existing values into textfields
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //user input -> expense name
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: existingName,
              ),
            ),

            //user input -> expense amount
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                hintText: existingAmount,
              ),
            ),
          ],
        ),
        actions: [
          //cancel button
          _cancelButton(),

          //save button
          _editExpenseButton(expense),
        ],
      ),
    );
  }

  //open delete Box
  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Expense?"),
        actions: [
          //cancel button
          _cancelButton(),

          //delete button
          _deleteExpenseButton(expense.id),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, value, child) {
        //get dates
        int startMonth = value.getStartMonth();
        int startYear = value.getStartYear();
        int currentMonth = DateTime.now().month;
        int currentYear = DateTime.now().year;

        //calculate the number of months since the first month
        int monthCount = calculateMonthCount(
          startYear,
          startMonth,
          currentMonth,
          currentYear,
        );
        //only display the expenses for thr current month
        List<Expense> currentMonthExpenses = value.allExpenses.where((expense) {
          return expense.date.month == currentMonth &&
              expense.date.year == currentYear;
        }).toList();

        //return UI
        return Scaffold(
          backgroundColor: Colors.grey[350],
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: FutureBuilder(
              future: _calculateCurrentMonthTotal,
              builder: (context, snapshot) {
                //loaded
                if (snapshot.connectionState == ConnectionState.done) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //total amount
                      Text('₹' + snapshot.data!.toStringAsFixed(2)),

                      //current month name
                      Text(getCurrentMonthName()),
                    ],
                  );
                }

                //loading
                else {
                  return Text("Loading...");
                }
              },
            ),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: openNewExpenseBox,
            backgroundColor: Colors.green,
            child: Icon(Icons.add),
          ),
          body: Column(
            children: [
              //GRAPH UI
              Expanded(
                child: FutureBuilder(
                  future: _monthlyTotalsFuture,
                  builder: (context, snapshot) {
                    //data is loaded
                    if (snapshot.connectionState == ConnectionState.done) {
                      Map<String, double> monthlyTotals = snapshot.data ?? {};

                      //create the list of monthly summary
                      List<double> monthlySummary =
                          List.generate(monthCount, (index) {
                        //calculate year-month considering startMonth & index
                        int year = startYear + (startMonth + index) ~/ 12;
                        int month = (startMonth + index - 1) % 12 + 1;

                        //create the key int he format 'year-month

                        String yearMonthKey = "$year-$month";

                        //return the total
                        return monthlyTotals[yearMonthKey] ?? 0.0;
                      });

                      return MyBarGraph(
                          monthlySummary: monthlySummary,
                          startMonth: startMonth);
                    }

                    //loading...
                    else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),

              //EXPENSE LIST UI
              Expanded(
                child: ListView.builder(
                  itemCount: value.allExpenses.length,
                  itemBuilder: (context, index) {
                    //reverse the inedex to show the latest expense first
                    int reversedIndex = currentMonthExpenses.length - 1 - index;

                    //get individual expense
                    Expense individualExpense = value.allExpenses[index];

                    //return list tile UI
                    return MyListTile(
                      title: individualExpense.name,
                      trailing: formatAmount(individualExpense.amount),
                      onEditPressed: (context) =>
                          openEditBox(individualExpense),
                      onDeletePressed: (context) =>
                          openDeleteBox(individualExpense),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //CANCEL BUTTON
  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        //pop the dialog
        Navigator.pop(context);

        //clear controllers
        nameController.clear();
        amountController.clear();
      },
      child: Text("Cancel"),
    );
  }

  //SAVE BUTTON -> create new expense
  Widget _createNewExpenseButton() {
    return MaterialButton(
      onPressed: () async {
        //save only if there is something in the text fields to save
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          //pop the dialog
          Navigator.pop(context);

          //create a new expense
          Expense newExpense = Expense(
            name: nameController.text,
            amount: convertStringtoDouble(amountController.text),
            date: DateTime.now(),
          );

          //save to db
          await context.read<ExpenseDatabase>().createNewExpense(newExpense);

          // Refresh graph
          refreshData();

          //clear controllers
          nameController.clear();
          amountController.clear();
        }

        //clear controllers
        nameController.clear();
        amountController.clear();
      },
      child: Text("Save"),
    );
  }

  //SAVE BUTTON -> edit existing expense
  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        //save as long as at least one textfield is changed
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          //pop the box
          Navigator.pop(context);

          //create a new updated expense
          Expense updatedExpense = Expense(
            name: nameController.text.isNotEmpty
                ? nameController.text
                : expense.name,
            amount: amountController.text.isNotEmpty
                ? convertStringtoDouble(amountController.text)
                : expense.amount,
            date: DateTime.now(),
          );

          //old expense id
          int existingId = expense.id;

          //save to db
          await context
              .read<ExpenseDatabase>()
              .updateExpense(existingId, updatedExpense);

          // Refresh graph
          refreshData();

          //clear controllers
          nameController.clear();
          amountController.clear();
        }
        //clear controllers
        nameController.clear();
        amountController.clear();
      },
      child: const Text("Save"),
    );
  }

  //DELETE BUTTON
  Widget _deleteExpenseButton(int id) {
    return MaterialButton(
      onPressed: () async {
        //pop the box
        Navigator.pop(context);

        //delete the expense
        await context.read<ExpenseDatabase>().deleteExpense(id);

        // Refresh graph
        refreshData();

        //clear controllers
        nameController.clear();
        amountController.clear();
      },
      child: const Text("Delete"),
    );
  }
}
