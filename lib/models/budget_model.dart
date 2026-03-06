class BudgetModel {
  final String id;
  final String userId;
  final String category; // 'All' for global budget or specific category name
  final double limitAmount;
  final DateTime startDate;
  final DateTime endDate;

  BudgetModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.limitAmount,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'category': category,
    'limitAmount': limitAmount,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
  };

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      category: map['category'] ?? 'All',
      limitAmount: (map['limitAmount'] ?? 0.0).toDouble(),
      startDate: DateTime.parse(
        map['startDate'] ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        map['endDate'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  double get progress => 0.0; // Dynamic calculation placeholder
}
