// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'recipe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final String spoonacularApiKey = dotenv.env['SPOONACULAR_API_KEY']!;
  List<dynamic> _meals = [];
  bool _isLoading = true;
  bool _isError = false;
  bool _haveSearched = false;
  bool _ascendingOrder = true;

  Future<List<String>> _getSuggestionList(String query) async {
    final url = Uri.parse(
        'https://api.spoonacular.com/recipes/autocomplete?number=5&query=$query&apiKey=$spoonacularApiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final suggestions = data.map((obj) => obj['title'] as String).toList();

        return suggestions;
      } else {
        print('Error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return [];
  }

  Future<void> _loadOrSearchMeals([String query = '']) async {
    final url = query.isEmpty
        ? Uri.parse(
            'https://api.spoonacular.com/recipes/random?number=15&addRecipeInformation=true&apiKey=$spoonacularApiKey')
        : Uri.parse(
            'https://api.spoonacular.com/recipes/complexSearch?query=$query&addRecipeInformation=true&apiKey=$spoonacularApiKey');

    String mealKey = query.isEmpty ? 'recipes' : 'results';

    setState(() {
      _isLoading = true;
      _isError = false;
      _haveSearched = true;
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _meals = data[mealKey];
          _isLoading = false;
        });

        if (_ascendingOrder) {
          _meals.sort((a, b) {
            return a['readyInMinutes'].compareTo(b['readyInMinutes']);
          });
        } else {
          _meals.sort((a, b) {
            return b['readyInMinutes'].compareTo(a['readyInMinutes']);
          });
        }
      } else {
        print('Error: ${response.statusCode} ${response.body}');
        setState(() {
          _isLoading = false;
          _isError = true;
        });

        Fluttertoast.showToast(
            msg: 'Error: ${response.statusCode} ${response.reasonPhrase}',
            backgroundColor: Colors.red,
            toastLength: Toast.LENGTH_LONG);
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
        _isError = true;
      });

      Fluttertoast.showToast(
          msg: 'An error occurred',
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG);
    }
  }

  void _resetSearch() {
    _searchController.clear();
    _loadOrSearchMeals();
  }

  @override
  void initState() {
    _loadOrSearchMeals();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: _resetSearch,
        ),
        title: TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search meals',
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            onSubmitted: _loadOrSearchMeals,
          ),
          suggestionsCallback: _getSuggestionList,
          itemBuilder: (context, String suggestion) {
            return ListTile(
              title: Text(suggestion),
            );
          },
          onSuggestionSelected: (String suggestion) {
            _searchController.text = suggestion;
            _loadOrSearchMeals(suggestion);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              setState(() {
                _ascendingOrder = !_ascendingOrder;

                if (_ascendingOrder) {
                  _meals.sort((a, b) {
                    return a['readyInMinutes'].compareTo(b['readyInMinutes']);
                  });
                } else {
                  _meals.sort((a, b) {
                    return b['readyInMinutes'].compareTo(a['readyInMinutes']);
                  });
                }
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Visibility(
            visible: !_isLoading && !_isError,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: _meals.isEmpty && _haveSearched
                  ? const Center(child: Text('No Results Found'))
                  : ListView.builder(
                      itemCount: _meals.length,
                      itemBuilder: (context, index) {
                        final meal = _meals[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            leading: Container(
                              width: 80,
                              height: 80,
                              margin: const EdgeInsets.only(right: 16),
                              child: Image.network(
                                meal['image'],
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              meal['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                                'Ready in ${meal['readyInMinutes']} minutes'),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RecipeScreen(meal['id']),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
          Visibility(
            visible: _isLoading && !_isError,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          Visibility(
            visible: _isError,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'An error occurred',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _loadOrSearchMeals(_searchController.text);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
