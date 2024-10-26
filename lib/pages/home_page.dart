import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //text controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

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
          Widget_cancelButton()

          //save button
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: openNewExpenseBox,
        child: Icon(Icons.add),
      ),
    );
  }

  //CANCEL BUTTON
  Widget_cancelButton() {
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

  //SAVE BUTTON
  Widget_saveButton() {
    return MaterialButton(
      onPressed: () {
        //save only if there is something in the text fields to save
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          //pop the dialog
          Navigator.pop(context);

          //create a new expense
          Expense newExpense = Expense(
              name: nameController.text,
              amount: amountController.text,
              date: DateTime.now());

          //save to db

          //clear controllers
          nameController.clear();
          amountController.clear();
        }

        //pop the dialog
        Navigator.pop(context);

        //clear controllers
        nameController.clear();
        amountController.clear();
      },
      child: Text("Cancel"),
    );
  }
}
