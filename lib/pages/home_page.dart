import 'package:expense_tracker/components/my_list_tile.dart';
import 'package:expense_tracker/database/expense_database.dart';
import 'package:expense_tracker/helper/helper_functions.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();

    super.initState();
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
      builder: (context, value, child) => Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: openNewExpenseBox,
          child: Icon(Icons.add),
        ),
        body: ListView.builder(
          itemCount: value.allExpenses.length,
          itemBuilder: (context, index) {
            //get individual expense
            Expense individualExpense = value.allExpenses[index];

            //return list tile UI
            return MyListTile(
              title: individualExpense.name,
              trailing: formatAmount(individualExpense.amount),
              onEditPressed: (context) => openEditBox(individualExpense),
              onDeletePressed: (context) => openDeleteBox(individualExpense),
            );
          },
        ),
      ),
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

          // Refresh the list
          setState(() {});

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
        }
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
      },
      child: const Text("Delete"),
    );
  }
}
