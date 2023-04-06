class Us {
  double? amount;
  String? unitShort;
  String? unitLong;

  Us({this.amount, this.unitShort, this.unitLong});

  factory Us.fromJson(Map<String, dynamic> json) => Us(
        amount: (json['amount'] as num?)?.toDouble(),
        unitShort: json['unitShort'] as String?,
        unitLong: json['unitLong'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'unitShort': unitShort,
        'unitLong': unitLong,
      };
}
