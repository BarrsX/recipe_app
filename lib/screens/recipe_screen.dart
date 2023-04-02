// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../utilities/keys.dart';

class RecipeScreen extends StatefulWidget {
  final int mealId;

  const RecipeScreen(this.mealId, {Key? key}) : super(key: key);

  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  late Map<String, dynamic> _recipe;
  bool _isLoading = true;
  bool _isError = false;

  Future<void> _getRecipe() async {
    try {
      final url = Uri.parse(
          'https://api.spoonacular.com/recipes/${widget.mealId}/information?apiKey=$SPOONACULAR_API_KEY');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _recipe = data;
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

  @override
  void initState() {
    _getRecipe();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe'),
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
                            Text(
                              _recipe['title'],
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 16),
                            Html(
                              data: _recipe['summary'],
                              style: {
                                'fontFamily': Style(fontFamily: 'Open Sans'),
                                'fontSize': Style(fontSize: const FontSize(16)),
                              },
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children: [
                                Text(
                                  'Ingredients',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Container(
                                  height: 400,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Expanded(
                                    child: ListView.builder(
                                      itemCount:
                                          _recipe['extendedIngredients'].length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        var ingredient =
                                            _recipe['extendedIngredients']
                                                [index];
                                        final hasImage =
                                            ingredient.containsKey('image');
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 2.0,
                                          ),
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
                                            itemCount:
                                                _recipe['analyzedInstructions']
                                                        [0]['steps']
                                                    .length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final step = _recipe[
                                                      'analyzedInstructions'][0]
                                                  ['steps'][index];
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
                          ],
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}
