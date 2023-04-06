import 'measures.dart';

class ExtendedIngredient {
  int? id;
  String? aisle;
  String? image;
  String? consistency;
  String? name;
  String? nameClean;
  String? original;
  String? originalName;
  double? amount;
  String? unit;
  List<dynamic>? meta;
  Measures? measures;

  ExtendedIngredient({
    this.id,
    this.aisle,
    this.image,
    this.consistency,
    this.name,
    this.nameClean,
    this.original,
    this.originalName,
    this.amount,
    this.unit,
    this.meta,
    this.measures,
  });

  factory ExtendedIngredient.fromJson(Map<String, dynamic> json) {
    return ExtendedIngredient(
      id: json['id'] as int?,
      aisle: json['aisle'] as String?,
      image: json['image'] as String?,
      consistency: json['consistency'] as String?,
      name: json['name'] as String?,
      nameClean: json['nameClean'] as String?,
      original: json['original'] as String?,
      originalName: json['originalName'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      meta: json['meta'] as List<dynamic>?,
      measures: json['measures'] == null
          ? null
          : Measures.fromJson(json['measures'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'aisle': aisle,
        'image': image,
        'consistency': consistency,
        'name': name,
        'nameClean': nameClean,
        'original': original,
        'originalName': originalName,
        'amount': amount,
        'unit': unit,
        'meta': meta,
        'measures': measures?.toJson(),
      };
}
