class Length {
  int? number;
  String? unit;

  Length({this.number, this.unit});

  factory Length.fromJson(Map<String, dynamic> json) => Length(
        number: json['number'] as int?,
        unit: json['unit'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'number': number,
        'unit': unit,
      };
}
