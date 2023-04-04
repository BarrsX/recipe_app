import 'package:recipe_app/src/features/recipe/domain/models/ingredient_model.dart';

class Recipe {
  final int id;
  final String title;
  final String imageUrl;
  final Map<String, String> summaryInfo;
  final List<String> relatedRecipes;
  final List<Ingredient> extendedIngredients;
  final List<Instruction> analyzedInstructions;

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.summaryInfo,
    required this.relatedRecipes,
    required this.extendedIngredients,
    required this.analyzedInstructions,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    Map<String, String> summaryInfo = {};
    List<String> relatedRecipes = [];
    List<Ingredient> extendedIngredients = [];
    List<Instruction> analyzedInstructions =
        []; // Extract summary info, related recipes, extended ingredients, and analyzed instructions from json data
    String? summary = json['summary'];
    if (summary != null) {
      summaryInfo = _buildSummaryInfo(summary);
      relatedRecipes = _separateRelatedRecipes(summary);
    }
    if (json.containsKey('extendedIngredients')) {
      var ing = json['extendedIngredients'];
      extendedIngredients =
          List<Ingredient>.from(ing.map((x) => Ingredient.fromJson(x)));
    }
    if (json.containsKey('analyzedInstructions')) {
      analyzedInstructions = List<Instruction>.from(json['analyzedInstructions']
              [0]['steps']
          .map((x) => Instruction.fromJson(x)));
    }

    return Recipe(
        id: json['id'],
        title: json['title'],
        imageUrl: json['image'],
        summaryInfo: summaryInfo,
        relatedRecipes: relatedRecipes,
        extendedIngredients: extendedIngredients,
        analyzedInstructions: analyzedInstructions);
  }

  static Map<String, String> _buildSummaryInfo(String payload) {
    Map<String, String> nutritionData = {};
    List<String> matchers = [
      'protein',
      'fat',
      'calories',
      '\$',
      'cents',
      'score',
      'dairy',
      'gluten',
      'keto'
    ];
    final regex = RegExp(r'<b>(.*?)<\/b>');
    final matches = regex.allMatches(payload);

    for (Match match in matches) {
      if (match.group(1) != null) {
        String? text = match.group(1);

        if (matchers.any((keyword) => text!.contains(keyword))) {
          nutritionData[matchers[matchers
              .indexWhere((keyword) => text!.contains(keyword))]] = text!;
        }
      }
    }

    return nutritionData;
  }

  static List<String> _separateRelatedRecipes(String payload) {
    List<String> relatedRecipes = [];
    final regex = RegExp(r'<a(.*?)<\/a>');
    final matches = regex.allMatches(payload);

    for (Match match in matches) {
      if (match.group(1) != null) {
        relatedRecipes.add(match.group(1)!);
      }
    }

    return relatedRecipes;
  }
}
