import 'package:flutter/material.dart';
import 'package:money_tracker/helper/sql_helper.dart';
import 'package:money_tracker/model/wallet.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/model/transaction.dart';
import 'package:money_tracker/page/add_transaction_dialog.dart';
import 'package:money_tracker/page/historypage.dart';

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

  void _updateBalanceFromDatabase() async {
    await _fetchTransactions(); // Memperbarui saldo dari database
  }

  @override
  Widget build(BuildContext context) {
    String formattedBalance =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
            .format(wallet.balance);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Money Tracker',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Balance',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                // Panggil Navigator untuk berpindah halaman ke HistoryPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryPage(
                      saldo: wallet.balance,
                      onDeleteTransaction: _updateBalanceFromDatabase,
                    ),
                  ),
                );
              },
              child: Text(
                formattedBalance,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70, // Width of the IconButton
                  height: 70, // Height of the IconButton
                  decoration: BoxDecoration(
                    shape: BoxShape
                        .circle, // Shape of the container, you can change it to your preference
                    color: Colors.green, // Background color of the container
                  ),
                  child: IconButton(
                      onPressed: () async {
                        Transaction? newTransaction =
                            await showDialog<Transaction>(
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
                      icon: Icon(
                        Icons.add,
                        size: 30,
                        color: Colors.white,
                      )),
                ),
                SizedBox(width: 40),
                Container(
                  width: 70, // Width of the IconButton
                  height: 70, // Height of the IconButton
                  decoration: BoxDecoration(
                    shape: BoxShape
                        .circle, // Shape of the container, you can change it to your preference
                    color: Colors.red, // Background color of the container
                  ),
                  child: IconButton(
                      onPressed: () async {
                        Transaction? newTransaction =
                            await showDialog<Transaction>(
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
                      icon: Icon(
                        Icons.remove,
                        size: 30,
                        color: Colors.white,
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
