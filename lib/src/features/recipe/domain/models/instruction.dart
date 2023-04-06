import 'analyzed_instruction.dart';

class Instruction {
  List<AnalyzedInstruction>? analyzedInstructions;

  Instruction({this.analyzedInstructions});

  factory Instruction.fromJson(Map<String, dynamic> json) => Instruction(
        analyzedInstructions: (json['analyzedInstructions'] as List<dynamic>?)
            ?.map(
                (e) => AnalyzedInstruction.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'analyzedInstructions':
            analyzedInstructions?.map((e) => e.toJson()).toList(),
      };
}
