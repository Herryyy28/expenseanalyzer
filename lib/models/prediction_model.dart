class PredictionModel {
  final String month;
  final double predictedAmount;

  PredictionModel({
    required this.month,
    required this.predictedAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'predictedAmount': predictedAmount,
    };
  }

  factory PredictionModel.fromMap(Map<String, dynamic> map) {
    return PredictionModel(
      month: map['month'],
      predictedAmount: map['predictedAmount'],
    );
  }
}
