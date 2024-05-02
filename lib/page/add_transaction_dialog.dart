import 'package:flutter/material.dart';
import 'package:money_tracker/helper/sql_helper.dart';
import 'package:money_tracker/model/category.dart';
import 'package:money_tracker/model/transaction.dart';
import 'package:uuid/uuid.dart';

class AddTransactionDialog extends StatefulWidget {
  final TransactionType type;

  const AddTransactionDialog({Key? key, required this.type}) : super(key: key);

  @override
  _AddTransactionDialogState createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  TextEditingController _amountController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  late Category _selectedCategory;

  List<Category> _categoriesIncome = [
    Category(id: '1', name: 'Salary', icon: Icons.work),
    Category(id: '2', name: 'Gift', icon: Icons.redeem),
  ];

  List<Category> _categoriesExpense = [
    Category(id: '4', name: 'Food', icon: Icons.restaurant),
    Category(id: '5', name: 'Others', icon: Icons.payment),
    Category(id: '6', name: 'Transportation', icon: Icons.train),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.type == TransactionType.income
        ? _categoriesIncome[0] // Memilih kategori pertama untuk pendapatan
        : _categoriesExpense[0]; // Memilih kategori pertama untuk pengeluaran
  }

  @override
  Widget build(BuildContext context) {
    List<Category> categories = widget.type == TransactionType.income
        ? _categoriesIncome
        : _categoriesExpense;

    return AlertDialog(
      title: Text(
          widget.type == TransactionType.income ? 'Add Income' : 'Add Expense'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount',
            ),
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<Category>(
            value: _selectedCategory,
            onChanged: (Category? newValue) {
              setState(() {
                _selectedCategory = newValue!;
              });
            },
            items:
                categories.map<DropdownMenuItem<Category>>((Category category) {
              return DropdownMenuItem<Category>(
                value: category,
                child: Row(
                  children: [
                    Icon(category.icon),
                    SizedBox(width: 8),
                    Text(category.name),
                  ],
                ),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: 'Category',
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'Note',
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            // Simpan transaksi baru dan tutup dialog
            Transaction newTransaction = Transaction(
              id: DateTime.now().toString(),
              amount: double.parse(_amountController.text),
              date: DateTime.now(),
              category: _selectedCategory.name,
              type: widget.type,
              note: _noteController.text,
            );
            _addTransaction();
            Navigator.pop(context, newTransaction);
          },
          child: Text('Add'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }

  Future<void> _addTransaction() async {
    final database = await sqlHelper.db();
    String transactionId =
        Uuid().v4(); // Generate a UUID for the transaction ID
    await database.insert('transactions', {
      'id': transactionId, // Use the generated UUID as the transaction ID
      'amount': double.parse(_amountController.text),
      'date': DateTime.now().toIso8601String(),
      'category': _selectedCategory.name,
      'type': widget.type.toString().split('.').last,
      'note': _noteController.text,
    });
    _amountController.clear();
    _noteController.clear();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
