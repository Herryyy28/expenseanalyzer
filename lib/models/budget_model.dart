class BudgetModel {
  final double limit;

  BudgetModel({required this.limit});

  Map<String, dynamic> toMap() => {'limit': limit};

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(limit: map['limit']);
  }
}
