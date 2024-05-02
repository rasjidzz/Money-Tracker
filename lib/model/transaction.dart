class Transaction {
  final String id;
  final double amount;
  final DateTime date;
  final String category;
  final TransactionType type;
  final String note;

  Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    required this.note,
  });

  // Metode untuk mengonversi objek Transaction menjadi map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'type':
          type.toString().split('.').last, // Mengonversi enum menjadi string
      'note': note,
    };
  }

  // Metode untuk membuat objek Transaction dari map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      category: map['category'],
      type: map['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      note: map['note'],
    );
  }
}

enum TransactionType { income, expense }
