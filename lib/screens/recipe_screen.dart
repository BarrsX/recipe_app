// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class RecipeScreen extends StatefulWidget {
  final int mealId;

  const RecipeScreen(this.mealId, {Key? key}) : super(key: key);

  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final String spoonacularApiKey = dotenv.env['SPOONACULAR_API_KEY']!;
  late Map<String, dynamic> _recipe = {};
  late Map<String, String> _recipeSummary = {};
  late List<String> _relatedRecipes = [];
  bool _isLoading = true;
  bool _isError = false;

  Future<void> _getRecipe() async {
    try {
      final url = Uri.parse(
          'https://api.spoonacular.com/recipes/${widget.mealId}/information?apiKey=$spoonacularApiKey');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _recipe = data;
          _recipeSummary = _buildSummaryInfo(_recipe['summary']);
          _relatedRecipes = _separateRelatedRecipes(_recipe['summary']);
          _isLoading = false;
          _isError = false;
        });
      } else {
        print('Error: ${response.statusCode} ${response.body}');
        Fluttertoast.showToast(
            msg: 'Error: ${response.statusCode} ${response.reasonPhrase}',
            backgroundColor: Colors.red,
            toastLength: Toast.LENGTH_LONG);
        setState(() {
          _isLoading = false;
          _isError = true;
        });
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
          msg: 'An error occurred',
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG);
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }

  // ignore: todo
  // TODO: convert this to just use the following as Nutrition Facts:
  // https://spoonacular.com/food-api/docs#Nutrition-by-ID
  Map<String, String> _buildSummaryInfo(String payload) {
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

        // If regex matches, then add that to map, and use
        // 'matchers' index as the key
        if (matchers.any((keyword) => text!.contains(keyword))) {
          nutritionData[matchers[matchers
              .indexWhere((keyword) => text!.contains(keyword))]] = text!;
        }
      }
    }

    return nutritionData;
  }

  // Using regex again to avoid an extra API call
  List<String> _separateRelatedRecipes(String payload) {
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

  @override
  void initState() {
    _getRecipe();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_recipe['title'] ?? 'Recipe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'An error occurred',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _isError = false;
                          });
                          _getRecipe();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.network(
                        _recipe['image'],
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                _recipe['title'],
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Html(
                            //   data: _recipe['summary'],
                            //   style: {
                            //     'fontFamily': Style(fontFamily: 'Open Sans'),
                            //     'fontSize': Style(fontSize: const FontSize(16)),
                            //   },
                            // ),
                            // const SizedBox(height: 16),
                            Column(
                              children: [
                                Text(
                                  'Summary',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Center(
                                  child: SizedBox(
                                      child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text('')),
                                      DataColumn(label: Text('')),
                                    ],
                                    rows: _recipeSummary.entries
                                        .map(
                                          (entry) => DataRow(
                                            cells: [
                                              DataCell(Text(entry.key
                                                              .toLowerCase() ==
                                                          'cents' ||
                                                      entry.key.toLowerCase() ==
                                                          '\$'
                                                  ? 'PRICE'
                                                  : entry.key.toUpperCase())),
                                              DataCell(Text(
                                                  entry.value.toUpperCase())),
                                            ],
                                          ),
                                        )
                                        .toList(),
                                  )),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children: [
                                Text(
                                  'Ingredients',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                SizedBox(
                                  height: 400,
                                  child: ListView.builder(
                                    itemCount:
                                        _recipe['extendedIngredients'].length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      var ingredient =
                                          _recipe['extendedIngredients'][index];
                                      final hasImage =
                                          ingredient.containsKey('image');
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2.0),
                                        child: ListTile(
                                          leading: hasImage
                                              ? CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      'https://spoonacular.com/cdn/ingredients_100x100/${ingredient['image']}'),
                                                )
                                              : null,
                                          title: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ingredient['name'],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                            ],
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ingredient['original'],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children: [
                                Text(
                                  'Instructions:',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Container(
                                  height: 500,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: SizedBox(
                                          height: 500,
                                          child: ListView.builder(
                                            itemCount: _recipe[
                                                            'analyzedInstructions']
                                                        .toString() ==
                                                    '[]'
                                                ? 0
                                                : _recipe['analyzedInstructions']
                                                        [0]['steps']
                                                    .length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final step =
                                                  _recipe['analyzedInstructions']
                                                              .toString() ==
                                                          '[]'
                                                      ? 'N/A'
                                                      : _recipe[
                                                              'analyzedInstructions']
                                                          [0]['steps'][index];
                                              return ListTile(
                                                leading: CircleAvatar(
                                                  child: Text(
                                                    step['number'].toString(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                title: Text(
                                                  step['step'],
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children: [
                                Text(
                                  'Related Recipes:',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Container(
                                  height: 250,
                                  child: ListView.builder(
                                    itemCount: _relatedRecipes.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Html(
                                          data:
                                              '<a${_relatedRecipes[index]!}</a>',
                                          style: {
                                            'fontFamily':
                                                Style(fontFamily: 'Open Sans'),
                                            'fontSize': Style(
                                                fontSize: const FontSize(16)),
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}
