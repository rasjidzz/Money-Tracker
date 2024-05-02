import 'package:money_tracker/model/transaction.dart';

class Wallet {
  final String id;
  double balance;
  final List<Transaction> transactions;

  Wallet({
    required this.id,
    required this.balance,
    required this.transactions,
  });
}
