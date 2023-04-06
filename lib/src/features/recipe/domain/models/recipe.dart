import 'analyzed_instruction.dart';
import 'extended_ingredient.dart';
import 'wine_pairing.dart';

class Recipe {
  bool? vegetarian;
  bool? vegan;
  bool? glutenFree;
  bool? dairyFree;
  bool? veryHealthy;
  bool? cheap;
  bool? veryPopular;
  bool? sustainable;
  bool? lowFodmap;
  int? weightWatcherSmartPoints;
  String? gaps;
  int? preparationMinutes;
  int? cookingMinutes;
  int? aggregateLikes;
  int? healthScore;
  String? creditsText;
  String? sourceName;
  double? pricePerServing;
  List<ExtendedIngredient>? extendedIngredients;
  int id;
  String? title;
  int? readyInMinutes;
  int? servings;
  String? sourceUrl;
  String? image;
  String? imageType;
  String? summary;
  List<dynamic>? cuisines;
  List<dynamic>? dishTypes;
  List<dynamic>? diets;
  List<dynamic>? occasions;
  WinePairing? winePairing;
  String? instructions;
  List<AnalyzedInstruction>? analyzedInstructions;
  dynamic originalId;
  Map<String, String>? summaryInfo;
  List<String>? relatedRecipes;
  List<int>? relatedRecipesIds;

  Recipe(
      {this.vegetarian,
      this.vegan,
      this.glutenFree,
      this.dairyFree,
      this.veryHealthy,
      this.cheap,
      this.veryPopular,
      this.sustainable,
      this.lowFodmap,
      this.weightWatcherSmartPoints,
      this.gaps,
      this.preparationMinutes,
      this.cookingMinutes,
      this.aggregateLikes,
      this.healthScore,
      this.creditsText,
      this.sourceName,
      this.pricePerServing,
      this.extendedIngredients,
      required this.id,
      this.title,
      this.readyInMinutes,
      this.servings,
      this.sourceUrl,
      this.image,
      this.imageType,
      this.summary,
      this.cuisines,
      this.dishTypes,
      this.diets,
      this.occasions,
      this.winePairing,
      this.instructions,
      this.analyzedInstructions,
      this.originalId,
      this.summaryInfo,
      this.relatedRecipes,
      this.relatedRecipesIds});

  factory Recipe.fromJson(Map<String, dynamic> json) {
    Map<String, String> summaryInfo = {};
    List<String> relatedRecipes = [];
    List<int> relatedRecipesIds = [];
    String? summary = json['summary'];
    if (summary != null) {
      summaryInfo = _buildSummaryInfo(summary);
      relatedRecipes = _separateRelatedRecipes(summary);
      relatedRecipesIds = _separateRelatedRecipesIds(summary);
    }

    return Recipe(
      vegetarian: json['vegetarian'] as bool?,
      vegan: json['vegan'] as bool?,
      glutenFree: json['glutenFree'] as bool?,
      dairyFree: json['dairyFree'] as bool?,
      veryHealthy: json['veryHealthy'] as bool?,
      cheap: json['cheap'] as bool?,
      veryPopular: json['veryPopular'] as bool?,
      sustainable: json['sustainable'] as bool?,
      lowFodmap: json['lowFodmap'] as bool?,
      weightWatcherSmartPoints: json['weightWatcherSmartPoints'] as int?,
      gaps: json['gaps'] as String?,
      preparationMinutes: json['preparationMinutes'] as int?,
      cookingMinutes: json['cookingMinutes'] as int?,
      aggregateLikes: json['aggregateLikes'] as int?,
      healthScore: json['healthScore'] as int?,
      creditsText: json['creditsText'] as String?,
      sourceName: json['sourceName'] as String?,
      pricePerServing: (json['pricePerServing'] as num?)?.toDouble(),
      extendedIngredients: (json['extendedIngredients'] as List<dynamic>?)
          ?.map((e) => ExtendedIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      id: json['id'] as int,
      title: json['title'] as String?,
      readyInMinutes: json['readyInMinutes'] as int?,
      servings: json['servings'] as int?,
      sourceUrl: json['sourceUrl'] as String?,
      image: json['image'] as String? ??
          'https://media.istockphoto.com/photos/food-for-healthy-brain-picture-id1299079243?b=1&k=20&m=1299079243&s=612x612&w=0&h=0nD8xtP3eNikgVuP955dLLwXw1Ch6l1uH4nqcYB8e9I=',
      imageType: json['imageType'] as String?,
      summary: json['summary'] as String?,
      cuisines: json['cuisines'] as List<dynamic>?,
      dishTypes: json['dishTypes'] as List<dynamic>?,
      diets: json['diets'] as List<dynamic>?,
      occasions: json['occasions'] as List<dynamic>?,
      winePairing: json['winePairing'] == null
          ? null
          : WinePairing.fromJson(json['winePairing'] as Map<String, dynamic>),
      instructions: json['instructions'] as String?,
      analyzedInstructions: (json['analyzedInstructions'] as List<dynamic>?)
          ?.map((e) => AnalyzedInstruction.fromJson(e as Map<String, dynamic>))
          .toList(),
      originalId: json['originalId'] as dynamic,
      summaryInfo: summaryInfo,
      relatedRecipes: relatedRecipes,
      relatedRecipesIds: relatedRecipesIds
    );
  }

  Map<String, dynamic> toJson() => {
        'vegetarian': vegetarian,
        'vegan': vegan,
        'glutenFree': glutenFree,
        'dairyFree': dairyFree,
        'veryHealthy': veryHealthy,
        'cheap': cheap,
        'veryPopular': veryPopular,
        'sustainable': sustainable,
        'lowFodmap': lowFodmap,
        'weightWatcherSmartPoints': weightWatcherSmartPoints,
        'gaps': gaps,
        'preparationMinutes': preparationMinutes,
        'cookingMinutes': cookingMinutes,
        'aggregateLikes': aggregateLikes,
        'healthScore': healthScore,
        'creditsText': creditsText,
        'sourceName': sourceName,
        'pricePerServing': pricePerServing,
        'extendedIngredients':
            extendedIngredients?.map((e) => e.toJson()).toList(),
        'id': id,
        'title': title,
        'readyInMinutes': readyInMinutes,
        'servings': servings,
        'sourceUrl': sourceUrl,
        'image': image,
        'imageType': imageType,
        'summary': summary,
        'cuisines': cuisines,
        'dishTypes': dishTypes,
        'diets': diets,
        'occasions': occasions,
        'winePairing': winePairing?.toJson(),
        'instructions': instructions,
        'analyzedInstructions':
            analyzedInstructions?.map((e) => e.toJson()).toList(),
        'originalId': originalId,
      };

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

    static List<int> _separateRelatedRecipesIds(String payload) {
    List<String> relatedRecipes = [];
    List<int> relatedRecipesIds = [];
    final regex = RegExp(r'<a(.*?)<\/a>');
    final matches = regex.allMatches(payload);
    final regexNum = RegExp(r'[^\d]');

    for (Match match in matches) {
      if (match.group(1) != null) {
        relatedRecipes.add(match.group(1)!);
        relatedRecipesIds.add(int.parse(match.group(1)!.replaceAll(regexNum, '')));
      }
    }
    
    return relatedRecipesIds;
  }
}
