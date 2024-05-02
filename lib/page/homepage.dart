import 'package:flutter/material.dart';
import 'package:money_tracker/helper/sql_helper.dart';
import 'package:money_tracker/model/wallet.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/model/transaction.dart';
import 'package:money_tracker/page/add_transaction_dialog.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Wallet wallet = Wallet(id: '1', balance: 0, transactions: []);
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  // Future<void> _fetchTransactions() async {
  //   final database = await sqlHelper.db();
  //   List<Map<String, dynamic>> transactionMaps =
  //       await database.query('transactions');
  //   List<Transaction> transactions =
  //       transactionMaps.map((map) => Transaction.fromMap(map)).toList();
  //   setState(() {
  //     _transactions = transactions;
  //   });
  // }

  Future<void> _fetchTransactions() async {
    final database = await sqlHelper.db();
    List<Map<String, dynamic>> transactionMaps =
        await database.query('transactions');
    List<Transaction> transactions =
        transactionMaps.map((map) => Transaction.fromMap(map)).toList();

    double totalAmount = 0;
    transactions.forEach((transaction) {
      if (transaction.type == TransactionType.income) {
        totalAmount += transaction.amount;
      } else {
        totalAmount -= transaction.amount;
      }
    });

    setState(() {
      _transactions = transactions;
      wallet.balance = totalAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedBalance =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
            .format(wallet.balance);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Money Tracker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Saldo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              formattedBalance,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Transaction? newTransaction = await showDialog<Transaction>(
                      context: context,
                      builder: (context) {
                        return AddTransactionDialog(
                            type: TransactionType.income);
                      },
                    );
                    if (newTransaction != null) {
                      setState(() {
                        wallet.transactions.add(newTransaction);
                        wallet.balance += newTransaction.amount;
                      });
                    }
                  },
                  child: Text('+ Income'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () async {
                    Transaction? newTransaction = await showDialog<Transaction>(
                      context: context,
                      builder: (context) {
                        return AddTransactionDialog(
                            type: TransactionType.expense);
                      },
                    );
                    if (newTransaction != null) {
                      setState(() {
                        wallet.transactions.add(newTransaction);
                        wallet.balance -= newTransaction.amount;
                      });
                    }
                  },
                  child: Text('- Expense'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
