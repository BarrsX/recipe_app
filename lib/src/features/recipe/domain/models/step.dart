import 'ingredient.dart';
import 'length.dart';

class InstructionStep {
  int? number;
  String? step;
  List<Ingredient>? ingredients;
  List<dynamic>? equipment;
  Length? length;

  InstructionStep({
    this.number,
    this.step,
    this.ingredients,
    this.equipment,
    this.length,
  });

  factory InstructionStep.fromJson(Map<String, dynamic> json) =>
      InstructionStep(
        number: json['number'] as int?,
        step: json['step'] as String?,
        ingredients: (json['ingredients'] as List<dynamic>?)
            ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
            .toList(),
        equipment: json['equipment'] as List<dynamic>?,
        length: json['length'] == null
            ? null
            : Length.fromJson(json['length'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'number': number,
        'step': step,
        'ingredients': ingredients?.map((e) => e.toJson()).toList(),
        'equipment': equipment,
        'length': length?.toJson(),
      };
}
