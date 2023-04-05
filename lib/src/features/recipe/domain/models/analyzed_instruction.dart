import 'step.dart';

class AnalyzedInstruction {
  String? name;
  List<InstructionStep>? steps;

  AnalyzedInstruction({this.name, this.steps});

  factory AnalyzedInstruction.fromJson(Map<String, dynamic> json) {
    return AnalyzedInstruction(
      name: json['name'] as String?,
      steps: (json['steps'] as List<dynamic>?)
          ?.map((e) => InstructionStep.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'steps': steps?.map((e) => e.toJson()).toList(),
      };
}
