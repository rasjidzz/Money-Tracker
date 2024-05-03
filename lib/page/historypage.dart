import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/helper/sql_helper.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
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
                        leading: Icon(
                          transaction.type == TransactionType.income
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: transaction.type == TransactionType.income
                              ? Colors.green
                              : Colors.red,
                        ),
                        title: Text(transaction.category),
                        subtitle: Text(
                            '${DateFormat.yMMMMd().format(transaction.date)} - ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(transaction.amount)}'),
                        // trailing: IconButton(
                        //   icon: Icon(Icons.delete),
                        //   onPressed: () {
                        //     _deleteTransaction(transaction.id);
                        //   },
                        // ),
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
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('More Information'),
                                );
                              });
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
