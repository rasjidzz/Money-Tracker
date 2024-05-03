import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/helper/sql_helper.dart';
import 'package:money_tracker/model/category.dart';
import 'package:money_tracker/model/transaction.dart';

class HistoryPage extends StatefulWidget {
  final double saldo;
  final Function() onDeleteTransaction; // Tambahkan fungsi onDeleteTransaction
  HistoryPage({Key? key, this.saldo = 0, required this.onDeleteTransaction})
      : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<Transaction>> _futureTransactions = Future.value([]);
  late double _balance;

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
    _balance = widget.saldo;
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
      _futureTransactions = Future.value(transactions);
      _balance = totalAmount;
    });
  }

  void _deleteTransaction(String transactionId) async {
    final database = await sqlHelper.db();
    await database
        .delete('transactions', where: 'id = ?', whereArgs: [transactionId]);
    _fetchTransactions();
    widget.onDeleteTransaction();
  }

  void _showTransactionDetailsDialog(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Transaction Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Date: ${DateFormat.yMMMMd().format(transaction.date)}'),
              Text('Category: ${transaction.category}'),
              Text(
                  'Amount: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(transaction.amount)}'),
              Text('Note: ${transaction.note}'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Icon _getCategoryIcon(Transaction transaction) {
    IconData iconData = Icons.category;
    if (transaction.type == TransactionType.income) {
      for (var category in _categoriesIncome) {
        if (category.name == transaction.category) {
          iconData = category.icon;
          break;
        }
      }
    } else {
      for (var category in _categoriesExpense) {
        if (category.name == transaction.category) {
          iconData = category.icon;
          break;
        }
      }
    }
    return Icon(iconData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
        backgroundColor: Colors.blue, // warna AppBar
      ),
      body: FutureBuilder<List<Transaction>>(
        future: _futureTransactions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Balance: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(_balance)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Transaction transaction = snapshot.data![index];
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        tileColor: Colors.white, // warna latar belakang
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12.0), // membuat sudut terbulat
                        ),
                        leading: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey
                                    .withOpacity(0.5), // warna bayangan
                                spreadRadius:
                                    2, // seberapa jauh bayangan menyebar
                                blurRadius: 3, // seberapa kabur bayangan
                                offset: Offset(0, 2), // posisi bayangan
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundColor:
                                transaction.type == TransactionType.income
                                    ? Colors.green
                                    : Colors.red,
                            child: Icon(
                              transaction.type == TransactionType.income
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        title: Text(transaction.category),
                        subtitle: Text(
                          '${DateFormat.yMMMMd().format(transaction.date)} - ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(transaction.amount)}',
                        ),
                        trailing: _getCategoryIcon(transaction),
                        onTap: () {
                          _showTransactionDetailsDialog(transaction);
                        },
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Transaction'),
                              content: const Text(
                                  'Are you sure you want to delete ?'),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    _deleteTransaction(transaction.id);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Yes'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('No'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
