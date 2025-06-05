class Expense {
  final String id;
  final String categoryId;
  final double amount;
  final String description;
  final DateTime date;
  final String userId;

  Expense({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.date,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'userId': userId,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] ?? '',
      categoryId: map['categoryId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      userId: map['userId'] ?? '',
    );
  }
}
